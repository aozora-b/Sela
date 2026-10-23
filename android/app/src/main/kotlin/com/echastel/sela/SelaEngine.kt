package com.echastel.sela

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import java.io.ByteArrayOutputStream

class SelaEngine {
    private var retriever: MediaMetadataRetriever? = null

    fun open(path: String) {
        close()
        retriever = MediaMetadataRetriever().apply {
            setDataSource(path)
        }
    }

    fun getMetadata(): Map<String, Any> {
        val r = retriever ?: throw IllegalStateException("Engine not opened")
        val durMs = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0L
        val w = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toIntOrNull() ?: 1280
        val h = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toIntOrNull() ?: 720
        val fpsStr = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CAPTURE_FRAMERATE)
        val fps = fpsStr?.toDoubleOrNull() ?: 30.0
        val durationS = durMs / 1000.0
        val frameCount = (durationS * fps).toInt().coerceAtLeast(1)
        val mimeType = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE)
        val codec = when {
            mimeType?.contains("avc", ignoreCase = true) == true || mimeType?.contains("h264", ignoreCase = true) == true -> "h264"
            mimeType?.contains("hevc", ignoreCase = true) == true || mimeType?.contains("h265", ignoreCase = true) == true -> "hevc"
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
        val r = retriever ?: throw IllegalStateException("Engine not opened")
        val option = if (exact) {
            MediaMetadataRetriever.OPTION_CLOSEST
        } else {
            MediaMetadataRetriever.OPTION_CLOSEST_SYNC
        }
        
        val bitmap: Bitmap? = if (width != null && height != null) {
            r.getScaledFrameAtTime(timeMs * 1000L, option, width, height) as Bitmap?
        } else {
            r.getFrameAtTime(timeMs * 1000L, option) as Bitmap?
        }
        if (bitmap == null) return null
        
        val stream = ByteArrayOutputStream()
        val compressFormat = if (format.equals("png", ignoreCase = true)) {
            Bitmap.CompressFormat.PNG
        } else {
            Bitmap.CompressFormat.JPEG
        }
        bitmap.compress(compressFormat, quality.coerceIn(1, 100), stream)
        bitmap.recycle()
        return stream.toByteArray()
    }

    fun close() {
        retriever?.release()
        retriever = null
    }
}
