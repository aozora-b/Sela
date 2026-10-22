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

    fun getFrame(timeMs: Long, exact: Boolean): ByteArray? {
        val r = retriever ?: throw IllegalStateException("Engine not opened")
        val option = if (exact) {
            MediaMetadataRetriever.OPTION_CLOSEST
        } else {
            MediaMetadataRetriever.OPTION_CLOSEST_SYNC
        }
        
        val bitmap = r.getFrameAtTime(timeMs * 1000L, option) ?: return null
        
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 90, stream)
        bitmap.recycle()
        return stream.toByteArray()
    }

    fun close() {
        retriever?.release()
        retriever = null
    }
}
