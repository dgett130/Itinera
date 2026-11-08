package org.itinera.itinera

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "itinera/widget")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "takePendingLink" -> result.success(WidgetLinkActivity.takePending(this))
          // Spesa rapida aperta dal widget: finito, si torna alla Home.
          "moveToBack" -> result.success(moveTaskToBack(true))
          else -> result.notImplemented()
        }
      }
  }
}
