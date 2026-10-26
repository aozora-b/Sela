package com.echastel.sela

import android.graphics.Bitmap
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.util.LruCache
import java.io.ByteArrayOutputStream
import kotlin.math.roundToInt

class SelaEngine {
    private var previewRetriever: MediaMetadataRetriever? = null
    private var thumbRetriever: MediaMetadataRetriever? = null
    private var currentPath: String? = null
    private val previewLock = Any()
    private val thumbLock = Any()
    private val cacheLock = Any()

    @Volatile
    private var cachedDurationUs: Long = 0L

    @Volatile
    private var cachedFrameDurationUs: Long = 33_333L

    // LRU cache capped at 120 frames (Guide §4 C.3)
    private val previewCache = object : LruCache<Long, ByteArray>(120) {}

    fun open(path: String) {
        close()
        synchronized(previewLock) {
            currentPath = path
            previewRetriever = createRetriever(path)
        }
        synchronized(thumbLock) {
            thumbRetriever = createRetriever(path)
        }
    }

    private fun createRetriever(path: String): MediaMetadataRetriever? {
        return try {
            MediaMetadataRetriever().apply { setDataSource(path) }
        } catch (_: Throwable) {
            null
        }
    }

    fun getMetadata(): Map<String, Any> = synchronized(previewLock) {
        val path = currentPath ?: throw IllegalStateException("Engine not opened")
        var r = previewRetriever
        if (r == null) {
            r = createRetriever(path)
            previewRetriever = r
        }
        val activeR = r ?: throw IllegalStateException("Engine not opened")

        val durMs = activeR.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0L
        val rawW = activeR.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toIntOrNull() ?: 1280
        val rawH = activeR.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toIntOrNull() ?: 720
        val rotation = activeR.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
        val w = if (rotation == 90 || rotation == 270) rawH else rawW
        val h = if (rotation == 90 || rotation == 270) rawW else rawH

        val countStr = activeR.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT)
        val containerFrameCount = countStr?.toIntOrNull()?.takeIf { it > 0 }
        val captureFps = activeR.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE)?.toDoubleOrNull()

        var extractorDurationUs = 0L
        var extractorFps: Double? = null
        var trackMime: String? = null

        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(path)
            for (i in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME) ?: continue
                if (mime.startsWith("video/")) {
                    trackMime = mime
                    if (format.containsKey(MediaFormat.KEY_DURATION)) {
                        extractorDurationUs = runCatching { format.getLong(MediaFormat.KEY_DURATION) }.getOrDefault(0L)
                    }
                    if (format.containsKey(MediaFormat.KEY_FRAME_RATE)) {
                        extractorFps = runCatching { format.getFloat(MediaFormat.KEY_FRAME_RATE).toDouble() }
                            .recoverCatching { format.getInteger(MediaFormat.KEY_FRAME_RATE).toDouble() }
                            .getOrNull()
                    }
                    break
                }
            }
        } catch (_: Throwable) {
        } finally {
            try { extractor.release() } catch (_: Throwable) {}
        }

        val durationUs = if (extractorDurationUs > 0L) extractorDurationUs else (durMs * 1000L)
        val durationS = (durationUs / 1_000_000.0).coerceAtLeast(0.0)

        // Single source of truth (Guide §4 B.1): avg_frame_rate = nb_frames / duration
        val frameCount: Int
        val fps: Double
        if (containerFrameCount != null && durationS > 0.0) {
            frameCount = containerFrameCount
            fps = (frameCount / durationS).coerceIn(1.0, 240.0)
        } else {
            val baseFps = (extractorFps ?: captureFps ?: 30.0).coerceIn(1.0, 240.0)
            frameCount = if (durationS > 0.0) (durationS * baseFps).roundToInt().coerceAtLeast(1) else 1
            fps = if (durationS > 0.0) (frameCount / durationS).coerceIn(1.0, 240.0) else baseFps
        }

        cachedDurationUs = durationUs
        cachedFrameDurationUs = (1_000_000.0 / fps).toLong().coerceAtLeast(1000L)

        val mimeType = trackMime ?: activeR.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE)
        val codec = when {
            mimeType?.contains("avc", ignoreCase = true) == true || mimeType?.contains("h264", ignoreCase = true) == true -> "h264"
            mimeType?.contains("hevc", ignoreCase = true) == true || mimeType?.contains("h265", ignoreCase = true) == true -> "h265"
            mimeType?.contains("vp9", ignoreCase = true) == true -> "vp9"
            mimeType?.contains("av01", ignoreCase = true) == true || mimeType?.contains("av1", ignoreCase = true) == true -> "av1"
            mimeType != null -> mimeType.substringAfter('/')
            else -> "h264"
        }

        return mapOf(
            "durationS" to durationS,
            "width" to w,
            "height" to h,
            "fps" to fps,
            "frameCount" to frameCount,
            "codec" to codec
        )
    }

    fun getFrame(
        timeMs: Long,
        exact: Boolean,
        width: Int? = null,
        height: Int? = null,
        format: String = "jpeg",
        quality: Int = 90
    ): ByteArray? {
        val isPreview = width != null && height != null
        val isThumb = width != null && width <= 160
        val cacheKey = if (isPreview) {
            ((timeMs / 10L) shl 17) or ((width and 0x7FFF).toLong() shl 2) or (if (exact) 1L else 0L)
        } else {
            -1L
        }

        if (isPreview && cacheKey != -1L) {
            val cached = synchronized(cacheLock) { previewCache.get(cacheKey) }
            if (cached != null) return cached
        }

        val targetLock = if (isThumb) thumbLock else previewLock
        val bytes = synchronized(targetLock) {
            val path = currentPath ?: return null
            var r = if (isThumb) thumbRetriever else previewRetriever
            if (r == null) {
                r = createRetriever(path)
                if (isThumb) thumbRetriever = r else previewRetriever = r
            }
            val activeR = r ?: return null

            val maxSafeUs = if (cachedDurationUs > 0L) {
                (cachedDurationUs - (cachedFrameDurationUs / 2)).coerceAtLeast(0L)
            } else {
                Long.MAX_VALUE
            }
            val timeUs = (timeMs * 1000L).coerceIn(0L, maxSafeUs)
            val option = if (exact) {
                MediaMetadataRetriever.OPTION_CLOSEST
            } else {
                MediaMetadataRetriever.OPTION_CLOSEST_SYNC
            }

            var bitmap: Bitmap? = try {
                if (width != null && height != null) {
                    activeR.getScaledFrameAtTime(timeUs, option, width, height)
                } else {
                    activeR.getFrameAtTime(timeUs, option)
                }
            } catch (_: Throwable) {
                val recovered = createRetriever(path)
                if (isThumb) thumbRetriever = recovered else previewRetriever = recovered
                null
            }

            if (bitmap == null) {
                val fallbackR = if (isThumb) thumbRetriever else previewRetriever
                if (fallbackR != null) {
                    bitmap = try {
                        if (width != null && height != null) {
                            fallbackR.getScaledFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST, width, height)
                        } else {
                            fallbackR.getFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST)
                        }
                    } catch (_: Throwable) {
                        null
                    }
                }
            }

            if (bitmap == null) return null

            val stream = ByteArrayOutputStream(if (isPreview) 32 * 1024 else 256 * 1024)
            val compressFormat = if (format.equals("png", ignoreCase = true)) {
                Bitmap.CompressFormat.PNG
            } else {
                Bitmap.CompressFormat.JPEG
            }
            bitmap.compress(compressFormat, quality.coerceIn(1, 100), stream)
            bitmap.recycle()
            stream.toByteArray()
        }

        if (isPreview && cacheKey != -1L && bytes != null) {
            synchronized(cacheLock) {
                previewCache.put(cacheKey, bytes)
            }
        }
        return bytes
    }

    fun close() {
        synchronized(previewLock) {
            try { previewRetriever?.release() } catch (_: Throwable) {}
            previewRetriever = null
            currentPath = null
        }
        synchronized(thumbLock) {
            try { thumbRetriever?.release() } catch (_: Throwable) {}
            thumbRetriever = null
        }
        synchronized(cacheLock) {
            previewCache.evictAll()
        }
    }
}
