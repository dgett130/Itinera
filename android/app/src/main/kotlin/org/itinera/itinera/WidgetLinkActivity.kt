package org.itinera.itinera

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle

/**
 * Riceve il tocco sul widget, annota dove andare e apre l'app.
 *
 * Il collegamento non passa da MainActivity: Android conserva l'intent con cui
 * un'attivita' e' partita e lo ripropone anche agli avvii successivi, che
 * riaprirebbero ogni volta l'ultimo punto toccato. Qui viene consegnato una
 * volta sola, tramite [takePending].
 */
class WidgetLinkActivity : Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    intent?.dataString?.let { link ->
      getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString(KEY, link).apply()
    }
    startActivity(
      Intent(this, MainActivity::class.java)
        .setAction(Intent.ACTION_MAIN)
        .addCategory(Intent.CATEGORY_LAUNCHER)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED),
    )
    finish()
  }

  companion object {
    private const val PREFS = "ItineraWidgetLink"
    private const val KEY = "pending"

    /** Il collegamento in attesa, che viene anche cancellato. */
    fun takePending(context: Context): String? {
      val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
      val link = prefs.getString(KEY, null)
      if (link != null) prefs.edit().remove(KEY).apply()
      return link
    }
  }
}
