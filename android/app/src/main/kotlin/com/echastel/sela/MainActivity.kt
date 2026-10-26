package com.echastel.sela

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicInteger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sela/frame_engine"
    private val engines = ConcurrentHashMap<Int, SelaEngine>()
    private val videoPicker = VideoPickerHandler(this)
    private val decodeExecutor = Executors.newSingleThreadExecutor()
    private val thumbExecutor = Executors.newSingleThreadExecutor()
    private val previewSeq = AtomicInteger(0)
    private val thumbSeq = AtomicInteger(0)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "open" -> {
                    val id = call.argument<Number>("id")?.toInt()
                        ?: return@setMethodCallHandler result.error("INVALID_ARG", "id required", null)
                    val path = call.argument<String>("path")
                        ?: return@setMethodCallHandler result.error("INVALID_ARG", "path required", null)

                    previewSeq.incrementAndGet()
                    thumbSeq.incrementAndGet()
                    decodeExecutor.execute {
                        try {
                            // Release any previously opened engines so native codecs never leak across sessions
                            val oldEngines = engines.values.toList()
                            engines.clear()
                            oldEngines.forEach {
                                try { it.close() } catch (_: Throwable) {}
                            }

                            val engine = SelaEngine()
                            engine.open(path)
                            engines[id] = engine
                            val meta = engine.getMetadata()
                            runOnUiThread { result.success(meta) }
                        } catch (e: Throwable) {
                            runOnUiThread { result.error("OPEN_ERROR", e.message, null) }
                        }
                    }
                }
                "getFrame" -> {
                    val id = call.argument<Number>("id")?.toInt()
                        ?: return@setMethodCallHandler result.error("INVALID_ARG", "id required", null)
                    val timeMs = call.argument<Number>("timeMs")?.toLong()
                        ?: return@setMethodCallHandler result.error("INVALID_ARG", "timeMs required", null)
                    val exact = call.argument<Boolean>("exact") ?: false
                    val width = call.argument<Number>("width")?.toInt()
                    val height = call.argument<Number>("height")?.toInt()
                    val format = call.argument<String>("format") ?: "jpeg"
                    val quality = call.argument<Number>("quality")?.toInt() ?: 90

                    val engine = engines[id]
                    if (engine == null) {
                        result.error("ENGINE_NOT_FOUND", "Engine $id not opened", null)
                        return@setMethodCallHandler
                    }

                    val isFullExtraction = width == null && height == null
                    val isThumb = width != null && width <= 160
                    val isScrubPreview = !isFullExtraction && !isThumb

                    if (isThumb) {
                        val myThumbEpoch = thumbSeq.get()
                        thumbExecutor.execute {
                            if (myThumbEpoch != thumbSeq.get()) {
                                runOnUiThread {
                                    result.error("SKIPPED", "Superseded by newer seek epoch", null)
                                }
                                return@execute
                            }
                            try {
                                val bytes = engine.getFrame(timeMs, exact, width, height, format, quality)
                                runOnUiThread {
                                    if (bytes != null) {
                                        result.success(bytes)
                                    } else {
                                        result.error("FRAME_ERROR", "Failed to extract frame", null)
                                    }
                                }
                            } catch (e: Throwable) {
                                runOnUiThread {
                                    result.error("FRAME_ERROR", e.message, null)
                                }
                            }
                        }
                    } else {
                        if (isScrubPreview) {
                            // Advance thumbSeq only when user seeks to a new main preview position
                            thumbSeq.incrementAndGet()
                        }
                        val mySeq = previewSeq.incrementAndGet()
                        decodeExecutor.execute {
                            if (isScrubPreview && mySeq != previewSeq.get()) {
                                runOnUiThread {
                                    result.error("SKIPPED", "Superseded by newer frame request", null)
                                }
                                return@execute
                            }
                            try {
                                val bytes = engine.getFrame(timeMs, exact, width, height, format, quality)
                                runOnUiThread {
                                    if (bytes != null) {
                                        result.success(bytes)
                                    } else {
                                        result.error("FRAME_ERROR", "Failed to extract frame", null)
                                    }
                                }
                            } catch (e: Throwable) {
                                runOnUiThread {
                                    result.error("FRAME_ERROR", e.message, null)
                                }
                            }
                        }
                    }
                }
                "close" -> {
                    val id = call.argument<Number>("id")?.toInt()
                        ?: return@setMethodCallHandler result.error("INVALID_ARG", "id required", null)
                    previewSeq.incrementAndGet()
                    thumbSeq.incrementAndGet()
                    val engine = engines.remove(id)
                    decodeExecutor.execute {
                        try { engine?.close() } catch (_: Throwable) {}
                    }
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
                    val subfolder = call.argument<String>("subfolder")

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val uri = gallery.writeImage(bytes, displayName, mimeType, subfolder)
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
                    val subfolder = call.argument<String>("subfolder")

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val exists = gallery.exists(displayName, subfolder)
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
                "shareImages" -> {
                    val paths = call.argument<List<String>>("paths")
                    if (paths.isNullOrEmpty()) {
                        result.error("EMPTY", "No paths to share", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val uris = ArrayList<Uri>()
                        for (p in paths) {
                            val f = File(p)
                            if (f.exists()) {
                                val uri = FileProvider.getUriForFile(this, "${packageName}.fileprovider", f)
                                uris.add(uri)
                            }
                        }
                        if (uris.isEmpty()) {
                            result.error("NOT_FOUND", "Files do not exist", null)
                            return@setMethodCallHandler
                        }
                        val intent = if (uris.size == 1) {
                            Intent(Intent.ACTION_SEND).apply {
                                type = "image/*"
                                putExtra(Intent.EXTRA_STREAM, uris.first())
                                clipData = android.content.ClipData.newUri(contentResolver, "image", uris.first())
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }
                        } else {
                            Intent(Intent.ACTION_SEND_MULTIPLE).apply {
                                type = "image/*"
                                putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris)
                                val clip = android.content.ClipData.newUri(contentResolver, "image", uris.first())
                                for (i in 1 until uris.size) {
                                    clip.addItem(android.content.ClipData.Item(uris[i]))
                                }
                                clipData = clip
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }
                        }
                        val chooser = Intent.createChooser(intent, "Bagikan Foto").apply {
                            clipData = intent.clipData
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(chooser)
                        result.success(true)
                    } catch (e: Exception) {
                        android.util.Log.e("SelaShare", "Error sharing: ", e)
                        result.error("SHARE_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VideoPickerHandler.CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickVideo" -> videoPicker.pickVideo(result)
                    "pickFolder" -> videoPicker.pickFolder(result)
                    "pickOutputDirectory" -> videoPicker.pickOutputDirectory(result)
                    "copyVideoUri" -> {
                        val uri = call.argument<String>("uri")
                            ?: return@setMethodCallHandler result.error("INVALID_ARG", "uri required", null)
                        videoPicker.copyVideoUri(uri, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        videoPicker.onActivityResult(requestCode, data)
    }

    override fun onDestroy() {
        previewSeq.incrementAndGet()
        thumbSeq.incrementAndGet()
        val oldEngines = engines.values.toList()
        engines.clear()
        decodeExecutor.execute {
            oldEngines.forEach {
                try { it.close() } catch (_: Throwable) {}
            }
        }
        decodeExecutor.shutdown()
        thumbExecutor.shutdown()
        super.onDestroy()
    }
}
