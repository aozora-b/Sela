package com.echastel.sela

import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.MediaStore
import java.io.BufferedOutputStream
import java.io.IOException
import java.util.concurrent.ConcurrentHashMap
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class SelaGallery(private val context: Context) {
    private val dirUriCache = ConcurrentHashMap<String, Uri>()

    suspend fun writeImage(
        bytes: ByteArray,
        displayName: String,
        mimeType: String,
        subfolder: String? = null
    ): String = withContext(Dispatchers.IO) {
        val resolver = context.contentResolver

        // Check if subfolder uses SAF treeUri encoding: "saf|<treeUri>|<optionalVideoFolder>"
        if (subfolder != null && subfolder.startsWith("saf|")) {
            val parts = subfolder.split("|")
            val treeUriStr = parts.getOrNull(1) ?: ""
            val videoSub = parts.getOrNull(2)?.trim('/') ?: ""
            if (treeUriStr.isNotEmpty()) {
                val treeUri = Uri.parse(treeUriStr)
                // Check if this SAF tree is on primary Pictures/ or DCIM/ so MediaStore can index it directly
                val docId = try {
                    DocumentsContract.getTreeDocumentId(treeUri)
                } catch (_: Exception) {
                    ""
                }
                if (docId.startsWith("primary:")) {
                    val rel = docId.substringAfter("primary:").trim('/')
                    if (rel.startsWith("Pictures", ignoreCase = true) ||
                        rel.startsWith("DCIM", ignoreCase = true)
                    ) {
                        val combined = if (videoSub.isNotEmpty()) "$rel/$videoSub" else rel
                        return@withContext writeViaMediaStore(resolver, bytes, displayName, mimeType, combined)
                    }
                }
                return@withContext writeViaSaf(resolver, treeUri, videoSub, displayName, mimeType, bytes)
            }
        }

        val cleanSub = subfolder?.trim()?.trim('/') ?: "Sela"
        val relative = when {
            cleanSub.isEmpty() -> "Pictures/Sela"
            cleanSub.startsWith("Pictures/", ignoreCase = true) ||
                cleanSub.equals("Pictures", ignoreCase = true) ||
                cleanSub.startsWith("DCIM/", ignoreCase = true) ||
                cleanSub.equals("DCIM", ignoreCase = true) -> cleanSub
            else -> "Pictures/$cleanSub"
        }
        writeViaMediaStore(resolver, bytes, displayName, mimeType, relative)
    }

    private fun writeViaMediaStore(
        resolver: ContentResolver,
        bytes: ByteArray,
        displayName: String,
        mimeType: String,
        relativeFolder: String
    ): String {
        val relativeWithSlash = "${relativeFolder.trim('/')}/"
        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, displayName)
            put(MediaStore.Images.Media.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Images.Media.RELATIVE_PATH, relativeWithSlash)
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        }

        val uri: Uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
            ?: throw IOException("Failed to create MediaStore entry for $displayName")

        try {
            resolver.openOutputStream(uri)?.use { raw ->
                BufferedOutputStream(raw, 32 * 1024).use { stream ->
                    stream.write(bytes)
                    stream.flush()
                }
            } ?: throw IOException("Failed to open output stream for $uri")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                contentValues.clear()
                contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
                resolver.update(uri, contentValues, null, null)
            }

            return uri.toString()
        } catch (e: Exception) {
            try { resolver.delete(uri, null, null) } catch (_: Exception) {}
            throw e
        }
    }

    private fun writeViaSaf(
        resolver: ContentResolver,
        treeUri: Uri,
        videoSub: String,
        displayName: String,
        mimeType: String,
        bytes: ByteArray
    ): String {
        val rootDocId = DocumentsContract.getTreeDocumentId(treeUri)
        val rootDocUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, rootDocId)
        val targetDirUri = if (videoSub.isEmpty()) {
            rootDocUri
        } else {
            val cacheKey = "$treeUri|$videoSub"
            dirUriCache[cacheKey] ?: synchronized(dirUriCache) {
                dirUriCache[cacheKey] ?: getOrCreateSubfolder(resolver, treeUri, rootDocUri, videoSub).also {
                    dirUriCache[cacheKey] = it
                }
            }
        }

        val fileUri = DocumentsContract.createDocument(resolver, targetDirUri, mimeType, displayName)
            ?: throw IOException("Failed to create SAF document for $displayName")

        try {
            resolver.openOutputStream(fileUri, "w")?.use { raw ->
                BufferedOutputStream(raw, 32 * 1024).use { stream ->
                    stream.write(bytes)
                    stream.flush()
                }
            } ?: throw IOException("Failed to open SAF output stream for $fileUri")
            return fileUri.toString()
        } catch (e: Exception) {
            try { DocumentsContract.deleteDocument(resolver, fileUri) } catch (_: Exception) {}
            throw e
        }
    }

    private fun getOrCreateSubfolder(
        resolver: ContentResolver,
        treeUri: Uri,
        parentDocUri: Uri,
        subfolderName: String
    ): Uri {
        try {
            val parentDocId = DocumentsContract.getDocumentId(parentDocUri)
            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentDocId)
            val projection = arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                DocumentsContract.Document.COLUMN_MIME_TYPE
            )
            resolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
                val idCol = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                val nameCol = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                val mimeCol = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_MIME_TYPE)
                while (cursor.moveToNext()) {
                    val name = cursor.getString(nameCol)
                    val mime = cursor.getString(mimeCol)
                    if (name == subfolderName && mime == DocumentsContract.Document.MIME_TYPE_DIR) {
                        val childId = cursor.getString(idCol)
                        return DocumentsContract.buildDocumentUriUsingTree(treeUri, childId)
                    }
                }
            }
            return DocumentsContract.createDocument(
                resolver,
                parentDocUri,
                DocumentsContract.Document.MIME_TYPE_DIR,
                subfolderName
            ) ?: parentDocUri
        } catch (_: Exception) {
            return parentDocUri
        }
    }

    suspend fun exists(displayName: String, subfolder: String? = null): Boolean = withContext(Dispatchers.IO) {
        if (subfolder != null && subfolder.startsWith("saf|")) {
            // DocumentsContract automatically appends (1) on collision if needed, so avoid slow IPC scan
            return@withContext false
        }
        val resolver = context.contentResolver
        val cleanSub = subfolder?.trim()?.trim('/') ?: "Sela"
        val folderPrefix = when {
            cleanSub.isEmpty() -> "Pictures/Sela%"
            cleanSub.startsWith("Pictures/", ignoreCase = true) ||
                cleanSub.startsWith("DCIM/", ignoreCase = true) -> "$cleanSub%"
            else -> "Pictures/$cleanSub%"
        }
        val projection = arrayOf(MediaStore.Images.Media._ID)
        val selection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            "${MediaStore.Images.Media.DISPLAY_NAME} = ? AND ${MediaStore.Images.Media.RELATIVE_PATH} LIKE ?"
        } else {
            "${MediaStore.Images.Media.DISPLAY_NAME} = ?"
        }
        val selectionArgs = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            arrayOf(displayName, folderPrefix)
        } else {
            arrayOf(displayName)
        }

        try {
            resolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                null
            )?.use { cursor ->
                cursor.count > 0
            } ?: false
        } catch (_: Exception) {
            false
        }
    }

    fun openGallery(): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }
}
