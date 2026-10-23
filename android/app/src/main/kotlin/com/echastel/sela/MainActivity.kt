package com.echastel.sela

import android.net.Uri
import android.provider.OpenableColumns
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sela/frame_engine"
    private val engines = mutableMapOf<Int, SelaEngine>()

    private var pendingResult: MethodChannel.Result? = null
    private val openVideoLauncher = registerForActivityResult(
        ActivityResultContracts.OpenDocument()
    ) { uri: Uri? ->
        val result = pendingResult
        pendingResult = null
        handlePickedVideo(uri, result)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "open" -> {
                    val id = call.argument<Int>("id") ?: return@setMethodCallHandler result.error("INVALID_ARG", "id required", null)
                    val path = call.argument<String>("path") ?: return@setMethodCallHandler result.error("INVALID_ARG", "path required", null)
                    
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val engine = SelaEngine()
                            engine.open(path)
                            engines[id] = engine
                            val meta = engine.getMetadata()
                            withContext(Dispatchers.Main) {
                                result.success(meta)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("OPEN_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "getFrame" -> {
                    val id = call.argument<Int>("id") ?: return@setMethodCallHandler result.error("INVALID_ARG", "id required", null)
                    val timeMs = call.argument<Int>("timeMs")?.toLong() ?: return@setMethodCallHandler result.error("INVALID_ARG", "timeMs required", null)
                    val exact = call.argument<Boolean>("exact") ?: false
                    val width = call.argument<Int>("width")
                    val height = call.argument<Int>("height")
                    val format = call.argument<String>("format") ?: "jpeg"
                    val quality = call.argument<Int>("quality") ?: 90
                    
                    val engine = engines[id]
                    if (engine == null) {
                        result.error("ENGINE_NOT_FOUND", "Engine $id not opened", null)
                        return@setMethodCallHandler
                    }
                    
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val bytes = engine.getFrame(timeMs, exact, width, height, format, quality)
                            withContext(Dispatchers.Main) {
                                if (bytes != null) {
                                    result.success(bytes)
                                } else {
                                    result.error("FRAME_ERROR", "Failed to extract frame", null)
                                }
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("FRAME_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "close" -> {
                    val id = call.argument<Int>("id") ?: return@setMethodCallHandler result.error("INVALID_ARG", "id required", null)
                    engines[id]?.close()
                    engines.remove(id)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        val gallery = SelaGallery(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.echastel.sela/gallery").setMethodCallHandler { call, result ->
            when (call.method) {
                "writeImage" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                        ?: return@setMethodCallHandler result.error("INVALID_ARG", "bytes required", null)
                    val displayName = call.argument<String>("displayName")
                        ?: return@setMethodCallHandler result.error("INVALID_ARG", "displayName required", null)
                    val mimeType = call.argument<String>("mimeType") ?: "image/png"

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val uri = gallery.writeImage(bytes, displayName, mimeType)
                            withContext(Dispatchers.Main) {
                                result.success(uri)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("GALLERY_WRITE_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "exists" -> {
                    val displayName = call.argument<String>("displayName")
                        ?: return@setMethodCallHandler result.error("INVALID_ARG", "displayName required", null)
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val exists = gallery.exists(displayName)
                            withContext(Dispatchers.Main) {
                                result.success(exists)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("GALLERY_EXISTS_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "openGallery" -> {
                    val opened = gallery.openGallery()
                    result.success(opened)
                }
                else -> result.notImplemented()
            }
        }

        // Pemilih video native (SAF). Menyalin berkas terpilih ke cache agar
        // engine menerima path nyata, bukan URI content://.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "sela/video_picker"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickVideo" -> {
                    pendingResult = result
                    openVideoLauncher.launch(arrayOf("video/*"))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun handlePickedVideo(uri: Uri?, result: MethodChannel.Result?) {
        if (result == null) return
        if (uri == null) {
            result.success(null)
            return
        }
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val displayName = queryDisplayName(uri) ?: "video.mp4"
                val ext = displayName.substringAfterLast('.', "mp4")
                val outFile = File(cacheDir, "picked_${System.currentTimeMillis()}.$ext")
                contentResolver.openInputStream(uri)?.use { input: InputStream ->
                    FileOutputStream(outFile).use { output ->
                        input.copyTo(output)
                    }
                } ?: throw IllegalStateException("Tidak dapat membuka aliran video")
                withContext(Dispatchers.Main) {
                    result.success(
                        mapOf(
                            "path" to outFile.absolutePath,
                            "displayName" to displayName
                        )
                    )
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("PICK_ERROR", e.message, null)
                }
            }
        }
    }

    private fun queryDisplayName(uri: Uri): String? {
        val projection = arrayOf(OpenableColumns.DISPLAY_NAME)
        contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (idx >= 0) return cursor.getString(idx)
            }
        }
        return null
    }
}
