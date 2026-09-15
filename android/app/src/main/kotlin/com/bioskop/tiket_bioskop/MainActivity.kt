package com.bioskop.tiket_bioskop

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.bioskop.tiket_bioskop/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveImageToGallery") {
                val bytes = call.argument<ByteArray>("bytes")
                val filename = call.argument<String>("filename") ?: "QR_${System.currentTimeMillis()}.png"
                if (bytes != null) {
                    val savedPath = saveToGallery(bytes, filename)
                    if (savedPath != null) {
                        result.success(savedPath)
                    } else {
                        result.error("SAVE_FAILED", "Failed to save image to Gallery", null)
                    }
                } else {
                    result.error("INVALID_ARGS", "Bytes data is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveToGallery(bytes: ByteArray, filename: String): String? {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val values = ContentValues().apply {
                    put(MediaStore.Images.Media.DISPLAY_NAME, filename)
                    put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                    put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/Kenticket")
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }
                val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                if (uri != null) {
                    contentResolver.openOutputStream(uri)?.use { stream ->
                        stream.write(bytes)
                    }
                    values.clear()
                    values.put(MediaStore.Images.Media.IS_PENDING, 0)
                    contentResolver.update(uri, values, null, null)
                    return uri.toString()
                }
            } else {
                val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                val kenticketDir = File(picturesDir, "Kenticket").apply { if (!exists()) mkdirs() }
                val imageFile = File(kenticketDir, filename)
                FileOutputStream(imageFile).use { it.write(bytes) }
                MediaScannerConnection.scanFile(this, arrayOf(imageFile.absolutePath), arrayOf("image/png"), null)
                return imageFile.absolutePath
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }
}
