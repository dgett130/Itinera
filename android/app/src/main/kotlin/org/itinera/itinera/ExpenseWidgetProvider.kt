package org.itinera.itinera

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.util.SizeF
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import kotlin.math.max
import kotlin.math.min

/**
 * Widget "Spesa rapida": dalla Home si fissa una spesa sul viaggio in corso
 * (o sul prossimo) in due tocchi. Le categorie aprono l'app direttamente sul
 * tastierino; i dati (viaggio e totale speso) li scrive l'app.
 *
 * Le scritte in Bricolage si disegnano in un bitmap, come nel widget del
 * poster: i launcher ignorano i font dell'app. Vedi FigCraft, pagina N.
 */
class ExpenseWidgetProvider : HomeWidgetProvider() {

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
    val state = ExpenseState.read(data)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      @Suppress("DEPRECATION")
      val sizes = options.getParcelableArrayList<SizeF>(AppWidgetManager.OPTION_APPWIDGET_SIZES)
      if (!sizes.isNullOrEmpty()) {
        return RemoteViews(
          sizes.distinct().take(MAX_SIZES).associateWith { size ->
            views(context, state, size.width, size.height)
          },
        )
      }
    }
    val w = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 300)
    val h = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 180)
    return views(context, state, w.toFloat(), h.toFloat())
  }

  private fun views(context: Context, state: ExpenseState, widthDp: Float, heightDp: Float): RemoteViews {
    val renderer = HeaderRenderer(context)
    val innerW = widthDp - 2 * PAD_DP
    val tripId = state.tripId
    if (tripId == null) {
      val v = RemoteViews(context.packageName, R.layout.widget_expense_empty)
      val headerH = max(heightDp - 2 * PAD_DP - BUTTON_DP - 8f, 40f)
      v.setImageViewBitmap(R.id.expense_header, renderer.empty(innerW, headerH))
      v.setContentDescription(R.id.expense_header, context.getString(R.string.expense_widget_empty))
      v.setOnClickPendingIntent(R.id.expense_root, link(context, "itinera-widget://home"))
      v.setOnClickPendingIntent(R.id.expense_new_trip, link(context, "itinera-widget://new-trip"))
      return v
    }
    val trip = "itinera-widget://trip/$tripId"
    val description = context.getString(R.string.expense_widget_title) + ", " + state.name + ", " +
      state.spent + " " + context.getString(R.string.expense_widget_spent)
    val large = widthDp >= LARGE_WIDTH_DP && heightDp >= LARGE_HEIGHT_DP
    if (large) {
      val v = RemoteViews(context.packageName, R.layout.widget_expense)
      v.setImageViewBitmap(R.id.expense_header, renderer.large(innerW, HEADER_DP, state))
      v.setContentDescription(R.id.expense_header, description)
      v.setOnClickPendingIntent(R.id.expense_root, link(context, "$trip/transport"))
      v.setOnClickPendingIntent(R.id.expense_cat_food, link(context, "$trip/expense?category=food"))
      v.setOnClickPendingIntent(R.id.expense_cat_activity, link(context, "$trip/expense?category=activity"))
      v.setOnClickPendingIntent(R.id.expense_cat_taxi, link(context, "$trip/expense?category=taxi"))
      v.setOnClickPendingIntent(R.id.expense_cat_other, link(context, "$trip/expense?pick=1"))
      return v
    }
    val v = RemoteViews(context.packageName, R.layout.widget_expense_small)
    val headerH = max(heightDp - 2 * PAD_DP - BUTTON_DP - 8f, 36f)
    v.setImageViewBitmap(R.id.expense_header, renderer.small(innerW, headerH, state))
    v.setContentDescription(R.id.expense_header, description)
    v.setOnClickPendingIntent(R.id.expense_root, link(context, "$trip/transport"))
    v.setOnClickPendingIntent(R.id.expense_add, link(context, "$trip/expense"))
    return v
  }

  private fun link(context: Context, uri: String): PendingIntent {
    val intent = Intent(context, WidgetLinkActivity::class.java).setData(Uri.parse(uri))
    return PendingIntent.getActivity(
      context,
      0,
      intent,
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
  }

  private companion object {
    const val MAX_SIZES = 8
    const val PAD_DP = 16f
    const val HEADER_DP = 52f
    const val BUTTON_DP = 48f
    const val LARGE_WIDTH_DP = 250f
    const val LARGE_HEIGHT_DP = 150f
  }
}

/** Quello che l'app ha scritto per il widget. */
private data class ExpenseState(val tripId: String?, val name: String, val spent: String) {
  companion object {
    fun read(p: SharedPreferences) = ExpenseState(
      tripId = p.getString("trip_id", "").orEmpty().ifEmpty { null },
      name = p.getString("trip_name", "").orEmpty(),
      spent = p.getString("spent", "").orEmpty(),
    )
  }
}

/** Disegna titoli e totale alla dimensione reale della testata. */
private class HeaderRenderer(private val context: Context) {
  private val density = context.resources.displayMetrics.density
  private val ink = Color.parseColor("#11153A")

  private fun font(id: Int): Typeface =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) context.resources.getFont(id) else Typeface.DEFAULT_BOLD

  private val medium = Typeface.create("sans-serif-medium", Typeface.NORMAL)

  private fun canvas(widthDp: Float, heightDp: Float): Triple<Bitmap, Canvas, Float> {
    // Limite prudente: i bitmap dei widget passano per un canale di sistema.
    val scale = min(density, MAX_WIDTH_PX / max(widthDp, 1f))
    val bmp = Bitmap.createBitmap(
      max((widthDp * scale).toInt(), 1),
      max((heightDp * scale).toInt(), 1),
      Bitmap.Config.ARGB_8888,
    )
    return Triple(bmp, Canvas(bmp), scale)
  }

  private fun paint(typeface: Typeface, sizeDp: Float, scale: Float) = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
    this.typeface = typeface
    textSize = sizeDp * scale
    color = ink
  }

  /** 4x2: "Spesa rapida" e viaggio a sinistra, totale a destra. */
  fun large(widthDp: Float, heightDp: Float, state: ExpenseState): Bitmap {
    val (bmp, c, s) = canvas(widthDp, heightDp)
    val w = bmp.width.toFloat()
    val total = paint(font(R.font.bricolage_extrabold), 26f, s)
    val spent = paint(medium, 12f, s)
    total.textAlign = Paint.Align.RIGHT
    spent.textAlign = Paint.Align.RIGHT
    val totalW = max(total.measureText(state.spent), spent.measureText(SPENT))
    c.drawText(state.spent, w, 25f * s, total)
    c.drawText(SPENT, w, 42f * s, spent)

    val textW = w - totalW - 12f * s
    val label = paint(medium, 13f, s)
    c.drawText(ellipsize(context.getString(R.string.expense_widget_title), label, textW), 0f, 14f * s, label)
    val name = paint(font(R.font.bricolage_bold), 17f, s)
    c.drawText(ellipsize(state.name, name, textW), 0f, 36f * s, name)
    return bmp
  }

  /** 2x2: viaggio su due righe e totale sotto. */
  fun small(widthDp: Float, heightDp: Float, state: ExpenseState): Bitmap {
    val (bmp, c, s) = canvas(widthDp, heightDp)
    val w = bmp.width.toFloat()
    val name = paint(font(R.font.bricolage_bold), 15f, s)
    val lines = if (heightDp >= 58f) twoLines(state.name, name, w) else listOf(ellipsize(state.name, name, w))
    var y = 0f
    for (line in lines) {
      y += 18f * s
      c.drawText(line, 0f, y - 4f * s, name)
    }
    val spent = paint(medium, 13f, s)
    c.drawText(ellipsize("${state.spent} $SPENT", spent, w), 0f, y + 14f * s, spent)
    return bmp
  }

  /** Nessun viaggio: titolo e, se c'e' spazio, due parole di spiegazione. */
  fun empty(widthDp: Float, heightDp: Float): Bitmap {
    val (bmp, c, s) = canvas(widthDp, heightDp)
    val w = bmp.width.toFloat()
    val label = paint(medium, 13f, s)
    c.drawText(context.getString(R.string.expense_widget_title), 0f, 14f * s, label)
    val title = paint(font(R.font.bricolage_bold), 17f, s)
    c.drawText(ellipsize(context.getString(R.string.expense_widget_empty), title, w), 0f, 36f * s, title)
    if (heightDp >= 74f) {
      val body = paint(Typeface.DEFAULT, 14f, s)
      val text = context.getString(R.string.expense_widget_empty_body)
      val layout = StaticLayout.Builder.obtain(text, 0, text.length, body, bmp.width)
        .setAlignment(Layout.Alignment.ALIGN_NORMAL)
        .setMaxLines(if (heightDp >= 96f) 2 else 1)
        .setEllipsize(android.text.TextUtils.TruncateAt.END)
        .build()
      c.save()
      c.translate(0f, 46f * s)
      layout.draw(c)
      c.restore()
    }
    return bmp
  }

  private fun ellipsize(text: String, paint: Paint, maxWidth: Float): String {
    if (paint.measureText(text) <= maxWidth) return text
    var end = text.length
    while (end > 1 && paint.measureText(text.substring(0, end) + "…") > maxWidth) end--
    return text.substring(0, end).trimEnd() + "…"
  }

  private fun twoLines(text: String, paint: Paint, maxWidth: Float): List<String> {
    if (paint.measureText(text) <= maxWidth) return listOf(text)
    val words = text.split(' ')
    val first = StringBuilder()
    var i = 0
    while (i < words.size && paint.measureText((first.toString() + " " + words[i]).trim()) <= maxWidth) {
      first.append(' ').append(words[i])
      i++
    }
    if (i == 0) return listOf(ellipsize(text, paint, maxWidth))
    val rest = words.drop(i).joinToString(" ")
    return listOf(first.toString().trim(), ellipsize(rest, paint, maxWidth)).filter { it.isNotEmpty() }
  }

  private companion object {
    const val MAX_WIDTH_PX = 900f
    const val SPENT = "spesi"
  }
}
