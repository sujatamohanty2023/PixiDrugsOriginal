package com.medico.pixidrugs

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "whatsapp_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "sendFileToNumber") {
                val filePath = call.argument<String>("filePath")
                val phone = call.argument<String>("phone")
                val msg = call.argument<String>("message")
                if (filePath != null && phone != null && msg != null) {
                    sendFileToNumber(filePath, phone,msg)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing filePath or phone", null)
                }
            }
        }
    }

    private fun sendFileToNumber(filePath: String, phoneNumber: String,message:String) {
        val file = File(filePath)
        val uri: Uri = FileProvider.getUriForFile(
            this,
            "$packageName.provider",
            file
        )

        val intent = Intent(Intent.ACTION_SEND)
        intent.type = "application/pdf" // adjust for other file types
        intent.putExtra(Intent.EXTRA_STREAM, uri)
        intent.putExtra(Intent.EXTRA_TEXT, message)
        intent.setPackage("com.whatsapp")
        intent.putExtra("jid", "$phoneNumber@s.whatsapp.net") // NOTE: this is undocumented

        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startActivity(intent)
    }
}