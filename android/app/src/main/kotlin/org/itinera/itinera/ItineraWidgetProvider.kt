package org.itinera.itinera

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.io.File
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit
import java.util.Locale
import kotlin.math.max
import kotlin.math.min

/**
 * Widget "Il mio viaggio": un solo widget che si adatta alla dimensione.
 * I dati li scrive l'app; il conto dei giorni si fa qui, cosi' resta giusto
 * anche quando l'app non viene aperta.
 *
 * Il poster, testi compresi, si disegna qui alla dimensione reale del widget:
 * i launcher ignorano i font dell'app e un ritaglio fisso finirebbe sotto le
 * scritte.
 */
class ItineraWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
    widgetData: SharedPreferences,
  ) {
    for (id in appWidgetIds) {
      val options = appWidgetManager.getAppWidgetOptions(id)
      appWidgetManager.updateAppWidget(id, build(context, widgetData, options))
    }
  }

  override fun onAppWidgetOptionsChanged(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
    newOptions: Bundle,
  ) {
    val data = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    appWidgetManager.updateAppWidget(appWidgetId, build(context, data, newOptions))
  }

  private fun build(context: Context, data: SharedPreferences, options: Bundle): RemoteViews {
    val state = WidgetState.read(data)
    val scene = decodeScene(data, state)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      // Android passa le dimensioni esatte e sceglie da solo la vista giusta.
      @Suppress("DEPRECATION")
      val sizes = options.getParcelableArrayList<SizeF>(AppWidgetManager.OPTION_APPWIDGET_SIZES)
      if (!sizes.isNullOrEmpty()) {
        return RemoteViews(
          sizes.distinct().take(MAX_SIZES).associateWith { size ->
            views(context, state, scene, size.width, size.height)
          },
        )
      }
    }
    val w = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 300)
    val h = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 160)
    return views(context, state, scene, w.toFloat(), h.toFloat())
  }

  private fun views(
    context: Context,
    state: WidgetState,
    scene: Bitmap?,
    widthDp: Float,
    heightDp: Float,
  ): RemoteViews {
    val large = heightDp >= LARGE_FROM_DP && widthDp >= WIDE_FROM_DP && state.tripId != null
    val v = RemoteViews(
      context.packageName,
      if (large) R.layout.widget_large else R.layout.widget_poster,
    )
    val posterHeight = if (large) heightDp - AGENDA_DP else heightDp
    val bitmap = PosterRenderer(context, state, scene).render(widthDp, posterHeight)
    v.setImageViewBitmap(R.id.widget_poster, bitmap)
    v.setContentDescription(R.id.widget_poster, state.description(context))
    v.setOnClickPendingIntent(R.id.widget_root, link(context, state.tripId, null))
    if (state.tripId != null && state.packing.isNotEmpty()) {
      v.setViewVisibility(R.id.widget_lower_tap, View.VISIBLE)
      v.setOnClickPendingIntent(R.id.widget_lower_tap, link(context, state.tripId, "packing"))
    } else {
      v.setViewVisibility(R.id.widget_lower_tap, View.GONE)
    }
    if (large) fillAgenda(context, v, state)
    return v
  }

  private fun fillAgenda(context: Context, v: RemoteViews, state: WidgetState) {
    v.setOnClickPendingIntent(R.id.widget_agenda, link(context, state.tripId, "itinerary"))
    val (title, rows) = state.agendaToShow()
    v.setTextViewText(R.id.widget_agenda_title, title)
    val slots = listOf(
      Triple(R.id.widget_row_1, R.id.widget_time_1, R.id.widget_title_1),
      Triple(R.id.widget_row_2, R.id.widget_time_2, R.id.widget_title_2),
      Triple(R.id.widget_row_3, R.id.widget_time_3, R.id.widget_title_3),
    )
    for ((i, slot) in slots.withIndex()) {
      val row = rows.getOrNull(i)
      v.setViewVisibility(slot.first, if (row == null) View.GONE else View.VISIBLE)
      if (row != null) {
        v.setTextViewText(slot.second, row.first)
        v.setTextViewText(slot.third, row.second)
      }
    }
    v.setViewVisibility(R.id.widget_agenda_empty, if (rows.isEmpty()) View.VISIBLE else View.GONE)
  }

  private fun link(context: Context, tripId: String?, section: String?): PendingIntent {
    val uri = if (tripId == null) {
      Uri.parse("itinera-widget://home")
    } else {
      Uri.parse("itinera-widget://trip/$tripId" + if (section == null) "" else "/$section")
    }
    val intent = Intent(context, WidgetLinkActivity::class.java).setData(uri)
    return PendingIntent.getActivity(
      context,
      0,
      intent,
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
  }

  private fun decodeScene(data: SharedPreferences, state: WidgetState): Bitmap? {
    if (state.tripId == null) return null
    val path = data.getString("poster_scene", null) ?: return null
    if (!File(path).exists()) return null
    return BitmapFactory.decodeFile(path)
  }

  private companion object {
    const val MAX_SIZES = 8
    const val LARGE_FROM_DP = 260f
    const val WIDE_FROM_DP = 230f

    /** Spazio che resta al programma nella versione grande. */
    const val AGENDA_DP = 132f
  }
}

/** Disegna poster e scritte alla dimensione reale del widget. */
private class PosterRenderer(
  private val context: Context,
  private val state: WidgetState,
  private val scene: Bitmap?,
) {
  private val density = context.resources.displayMetrics.density
  private val scaledDensity = density * context.resources.configuration.fontScale

  private fun font(id: Int): Typeface =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      context.resources.getFont(id)
    } else {
      Typeface.DEFAULT_BOLD
    }

  fun render(widthDp: Float, heightDp: Float): Bitmap {
    // Limite prudente: i bitmap dei widget passano per un canale di sistema.
    val scale = min(density, MAX_WIDTH_PX / max(widthDp, 1f))
    val w = max((widthDp * scale).toInt(), 1)
    val h = max((heightDp * scale).toInt(), 1)
    val out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(out)
    canvas.drawColor(state.background)

    // La scena e' ancorata in basso: della fascia piena sotto l'orizzonte resta
    // solo lo spazio per la riga in basso.
    val full = w / DESIGN_WIDTH
    val band = max(30f * full, 26f * scale)
    val horizon = h - band
    if (scene == null) {
      if (state.tripId == null) drawEmptyScene(canvas, w, horizon - HORIZON * full, full)
    } else {
      // I paesaggi alti arriverebbero sotto le scritte: si rimpiccioliscono a
      // destra. Quelli bassi restano interi (vedi FigCraft, pagina M).
      val textBottom = (if (widthDp < 200f) 74f else 90f) * scale
      val fits = state.lowScene || horizon - SKYLINE * full >= textBottom
      val s = if (fits) full else w * 0.62f / DESIGN_WIDTH
      val left = w - DESIGN_WIDTH * s
      val top = horizon - HORIZON * s
      val filter = Paint(Paint.FILTER_BITMAP_FLAG or Paint.ANTI_ALIAS_FLAG)
      canvas.drawBitmap(scene, null, RectF(left, top, w.toFloat(), top + DESIGN_HEIGHT * s), filter)
      if (!fits) {
        // Il terreno prosegue fino al bordo sinistro.
        val ground = Paint().apply { color = scene.getPixel(4, scene.height - 4) or (0xFF shl 24) }
        canvas.drawRect(0f, horizon, left + 1f, h.toFloat(), ground)
        if (state.cloudy) {
          // Le nuvole proseguono anche loro, invece di un blocco piatto.
          val r = 26f * scale
          var cx = 0f
          while (cx < left + r) {
            canvas.drawCircle(cx, horizon + r * 0.3f, r, ground)
            cx += r * 1.7f
          }
        } else if (state.hardEdge) {
          // Le case e i palazzi sfumano nel cielo invece di finire di netto.
          val width = w * 0.06f
          val fade = Paint().apply {
            shader = LinearGradient(
              left,
              0f,
              left + width,
              0f,
              state.background,
              state.background and 0x00FFFFFF,
              Shader.TileMode.CLAMP,
            )
          }
          canvas.drawRect(left - 1f, 0f, left + width, horizon, fade)
        }
      }
    }

    val pad = 16f * scale
    val compact = widthDp < 200f
    val nameSize = (if (compact) 14f else 17f) * scale * scaledDensity / density
    val paint = Paint(Paint.ANTI_ALIAS_FLAG)

    paint.typeface = font(R.font.bricolage_bold)
    paint.textSize = nameSize
    paint.color = state.foreground
    var y = pad + nameSize * 0.95f
    val nameText = state.nameOr(context)
    canvas.drawText(ellipsize(nameText, paint, w - 2 * pad), pad, y, paint)

    paint.typeface = font(R.font.bricolage_extrabold)
    paint.color = state.headlineColor
    val maxHead = if (compact) w - 2 * pad else w * 0.64f - pad
    val lines = fitLines(state.headlineOr(context), paint, maxHead, (if (compact) 26f else 34f) * scale, 16f * scale)
    y += 6f * scale
    for (line in lines) {
      y += paint.textSize * 1.02f
      canvas.drawText(line, pad, y, paint)
    }

    if (state.tripId != null && state.packing.isNotEmpty()) {
      paint.typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
      paint.textSize = 13f * scale * scaledDensity / density
      paint.color = state.lower
      canvas.drawText(state.packing, pad, h - band / 2f + paint.textSize * 0.35f, paint)
    }
    return out
  }

  private fun drawEmptyScene(canvas: Canvas, w: Int, top: Float, s: Float) {
    val drawable = context.getDrawable(R.drawable.widget_poster_empty) ?: return
    drawable.setBounds(0, top.toInt(), w, (top + DESIGN_HEIGHT * s).toInt())
    drawable.draw(canvas)
  }

  private fun ellipsize(text: String, paint: Paint, maxWidth: Float): String {
    if (paint.measureText(text) <= maxWidth) return text
    var end = text.length
    while (end > 1 && paint.measureText(text.substring(0, end) + "…") > maxWidth) end--
    return text.substring(0, end).trimEnd() + "…"
  }

  /** Riduce il testo fino a farlo stare; sotto il minimo va a capo in due righe. */
  private fun fitLines(text: String, paint: Paint, maxWidth: Float, start: Float, smallest: Float): List<String> {
    var size = start
    paint.textSize = size
    while (paint.measureText(text) > maxWidth && size > smallest) {
      size -= 1f
      paint.textSize = size
    }
    if (paint.measureText(text) <= maxWidth) return listOf(text)
    val words = text.split(' ')
    val first = StringBuilder()
    var i = 0
    while (i < words.size && paint.measureText((first.toString() + " " + words[i]).trim()) <= maxWidth) {
      first.append(' ').append(words[i])
      i++
    }
    val rest = words.drop(i).joinToString(" ")
    return listOf(first.toString().trim(), ellipsize(rest, paint, maxWidth)).filter { it.isNotEmpty() }
  }

  private companion object {
    const val MAX_WIDTH_PX = 900f
    const val DESIGN_WIDTH = 372f
    const val DESIGN_HEIGHT = 240f

    /** Dove finisce il paesaggio e comincia la fascia piena. */
    const val HORIZON = 150f

    /** Quanto salgono al massimo i paesaggi sopra l'orizzonte. */
    const val SKYLINE = 138f
  }
}

/** Dati del viaggio letti dalle preferenze condivise con l'app. */
internal class WidgetState(
  val tripId: String?,
  val name: String,
  private val type: String,
  private val start: LocalDate?,
  private val end: LocalDate?,
  val packing: String,
  val background: Int,
  val foreground: Int,
  val headlineColor: Int,
  val lower: Int,
  private val agenda: String,
) {

  /** Paesaggi che lasciano libero il cielo sotto le scritte. */
  val lowScene: Boolean get() = type == "sea" || type == "roadTrip" || type == "backpacking"

  /** Il poster generico finisce sulle nuvole. */
  val cloudy: Boolean get() = type == "generic"

  /** Scene che arrivano al bordo sinistro con un taglio verticale. */
  val hardEdge: Boolean get() = type == "city" || type == "business"

  fun nameOr(context: Context): String =
    if (tripId == null) context.getString(R.string.widget_empty_title) else name

  fun headlineOr(context: Context): String =
    if (tripId == null) context.getString(R.string.widget_empty_headline) else headline()

  fun description(context: Context): String =
    listOf(nameOr(context), headlineOr(context), if (tripId == null) "" else packing)
      .filter { it.isNotEmpty() }
      .joinToString(", ")

  /** "tra 9 giorni", "domani", "giorno 2 di 5"... */
  fun headline(today: LocalDate = LocalDate.now()): String {
    val s = start ?: return ""
    val e = end ?: s
    if (today.isBefore(s)) {
      val days = ChronoUnit.DAYS.between(today, s)
      return if (days == 1L) "domani" else "tra $days giorni"
    }
    if (today.isAfter(e)) return "concluso"
    val total = ChronoUnit.DAYS.between(s, e) + 1
    val current = ChronoUnit.DAYS.between(s, today) + 1
    return if (total == 1L) "oggi" else "giorno $current di $total"
  }

  /** Il programma di oggi, oppure del primo giorno se il viaggio non e' iniziato. */
  fun agendaToShow(today: LocalDate = LocalDate.now()): Pair<String, List<Pair<String, String>>> {
    val s = start ?: return "" to emptyList()
    val before = today.isBefore(s)
    val day = if (before) s else today
    val rows = mutableListOf<Pair<String, String>>()
    runCatching {
      val list = JSONObject(agenda).optJSONArray(day.toString())
      if (list != null) {
        for (i in 0 until minOf(list.length(), 3)) {
          val r = list.getJSONArray(i)
          rows.add(r.getString(0) to r.getString(1))
        }
      }
    }
    val title = if (before) {
      "Si parte " + day.format(DateTimeFormatter.ofPattern("EEE d MMM", Locale.ITALIAN))
    } else {
      "Oggi"
    }
    return title to rows
  }

  companion object {
    fun read(p: SharedPreferences): WidgetState {
      val id = p.getString("trip_id", "").orEmpty().ifEmpty { null }
      fun color(key: String, fallback: Int) = runCatching {
        Color.parseColor(p.getString(key, null))
      }.getOrDefault(fallback)
      fun date(key: String) = runCatching { LocalDate.parse(p.getString(key, "")) }.getOrNull()
      val noTrip = id == null
      return WidgetState(
        tripId = id,
        name = p.getString("trip_name", "").orEmpty(),
        type = p.getString("trip_type", "").orEmpty(),
        start = date("trip_start"),
        end = date("trip_end"),
        packing = p.getString("packing", "").orEmpty(),
        background = if (noTrip) Color.parseColor("#1B3FD8") else color("color_bg", Color.parseColor("#1B3FD8")),
        foreground = if (noTrip) Color.WHITE else color("color_fg", Color.WHITE),
        headlineColor = if (noTrip) Color.parseColor("#FFC21A") else color("color_headline", Color.WHITE),
        lower = color("color_lower", Color.WHITE),
        agenda = p.getString("agenda", "{}").orEmpty(),
      )
    }
  }
}
