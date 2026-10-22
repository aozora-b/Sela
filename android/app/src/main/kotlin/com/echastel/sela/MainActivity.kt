package com.echastel.sela

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sela/frame_engine"
    private val engines = mutableMapOf<Int, SelaEngine>()

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
                    
                    val engine = engines[id]
                    if (engine == null) {
                        result.error("ENGINE_NOT_FOUND", "Engine $id not opened", null)
                        return@setMethodCallHandler
                    }
                    
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val bytes = engine.getFrame(timeMs, exact, width, height)
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
    }
}
