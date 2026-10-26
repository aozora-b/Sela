package com.echastel.sela

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.OpenableColumns
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class VideoPickerHandler(private val activity: Activity) {
    companion object {
        const val PICK_VIDEO_REQUEST = 1001
        const val PICK_FOLDER_REQUEST = 1002
        const val PICK_OUTPUT_DIR_REQUEST = 1003
        const val CHANNEL_NAME = "sela/video_picker"
    }

    private var pendingVideoResult: MethodChannel.Result? = null
    private var pendingFolderResult: MethodChannel.Result? = null
    private var pendingOutputDirResult: MethodChannel.Result? = null

    fun pickVideo(result: MethodChannel.Result) {
        pendingVideoResult?.error("CANCELLED", "Superseded by new pick request", null)
        pendingVideoResult = result
        val intent = createPhotoPickerIntent()
        activity.startActivityForResult(intent, PICK_VIDEO_REQUEST)
    }

    private fun createPhotoPickerIntent(): Intent {
        val pm = activity.packageManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val sysPicker = Intent(MediaStore.ACTION_PICK_IMAGES).apply {
                type = "video/*"
            }
            if (sysPicker.resolveActivity(pm) != null) return sysPicker
        }
        val gmsPicker = Intent("com.google.android.gms.provider.action.PICK_IMAGES").apply {
            type = "video/*"
        }
        if (gmsPicker.resolveActivity(pm) != null) return gmsPicker

        val galleryPicker = Intent(Intent.ACTION_PICK, MediaStore.Video.Media.EXTERNAL_CONTENT_URI).apply {
            type = "video/*"
        }
        if (galleryPicker.resolveActivity(pm) != null) return galleryPicker

        return Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "video/*"
        }
    }

    fun pickFolder(result: MethodChannel.Result) {
        pendingFolderResult?.error("CANCELLED", "Superseded by new pick request", null)
        pendingFolderResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        activity.startActivityForResult(intent, PICK_FOLDER_REQUEST)
    }

    fun pickOutputDirectory(result: MethodChannel.Result) {
        pendingOutputDirResult?.error("CANCELLED", "Superseded by new pick request", null)
        pendingOutputDirResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
            )
        }
        activity.startActivityForResult(intent, PICK_OUTPUT_DIR_REQUEST)
    }

    fun copyVideoUri(uriStr: String, result: MethodChannel.Result) {
        val uri = Uri.parse(uriStr)
        handlePickedVideo(uri, result)
    }

    fun onActivityResult(requestCode: Int, data: Intent?): Boolean {
        when (requestCode) {
            PICK_VIDEO_REQUEST -> {
                val result = pendingVideoResult
                pendingVideoResult = null
                handlePickedVideo(data?.data, result)
                return true
            }
            PICK_FOLDER_REQUEST -> {
                val result = pendingFolderResult
                pendingFolderResult = null
                handlePickedFolder(data?.data, result)
                return true
            }
            PICK_OUTPUT_DIR_REQUEST -> {
                val result = pendingOutputDirResult
                pendingOutputDirResult = null
                handlePickedOutputDir(data?.data, result)
                return true
            }
        }
        return false
    }

    private fun handlePickedOutputDir(treeUri: Uri?, result: MethodChannel.Result?) {
        if (result == null) return
        if (treeUri == null) {
            result.success(null)
            return
        }
        try {
            val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            activity.contentResolver.takePersistableUriPermission(treeUri, takeFlags)
        } catch (_: Exception) {}

        val docId = try {
            DocumentsContract.getTreeDocumentId(treeUri)
        } catch (_: Exception) {
            ""
        }
        val rawPath = docId.substringAfter(':', docId).trim('/')
        val displayPath = if (rawPath.isEmpty()) "Penyimpanan Internal" else rawPath

        result.success(
            mapOf(
                "treeUri" to treeUri.toString(),
                "displayPath" to displayPath
            )
        )
    }

    private fun handlePickedFolder(treeUri: Uri?, result: MethodChannel.Result?) {
        if (result == null) return
        if (treeUri == null) {
            result.success(null)
            return
        }
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val docId = DocumentsContract.getTreeDocumentId(treeUri)
                val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, docId)
                val projection = arrayOf(
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    DocumentsContract.Document.COLUMN_MIME_TYPE,
                    DocumentsContract.Document.COLUMN_SIZE
                )
                val videoList = mutableListOf<Map<String, Any>>()
                val videoExtensions = listOf(".mp4", ".mov", ".mkv", ".webm", ".avi", ".3gp", ".m4v", ".ts")

                activity.contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
                    val idCol = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                    val nameCol = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                    val mimeCol = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_MIME_TYPE)
                    val sizeCol = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_SIZE)

                    while (cursor.moveToNext()) {
                        val childDocId = cursor.getString(idCol)
                        val name = cursor.getString(nameCol) ?: "unknown"
                        val mime = cursor.getString(mimeCol) ?: ""
                        val size = if (sizeCol >= 0) cursor.getLong(sizeCol) else 0L

                        val isVideo = mime.startsWith("video/") || videoExtensions.any { name.endsWith(it, ignoreCase = true) }
                        if (isVideo) {
                            val fileUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, childDocId)
                            videoList.add(
                                mapOf(
                                    "uri" to fileUri.toString(),
                                    "name" to name,
                                    "size" to size
                                )
                            )
                        }
                    }
                }
                withContext(Dispatchers.Main) {
                    result.success(videoList)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("FOLDER_PICK_ERROR", e.message, null)
                }
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
                // Store active video in app filesDir (documents) so OS never purges it mid-session,
                // while cleaning previous picked copies so storage stays bounded.
                val pickedDir = File(activity.filesDir, "picked_videos")
                if (!pickedDir.exists()) {
                    pickedDir.mkdirs()
                } else {
                    pickedDir.listFiles()?.forEach {
                        try { it.delete() } catch (_: Exception) {}
                    }
                }
                val legacyCacheDir = File(activity.cacheDir, "picked_videos")
                legacyCacheDir.listFiles()?.forEach {
                    try { it.delete() } catch (_: Exception) {}
                }
                activity.cacheDir.listFiles()?.forEach {
                    if (it.name.startsWith("picked_") && it.isFile) {
                        try { it.delete() } catch (_: Exception) {}
                    }
                }

                val displayName = queryDisplayName(uri) ?: "video.mp4"
                val safeName = displayName.replace(Regex("[^a-zA-Z0-9._\\- ]"), "_").ifBlank { "video.mp4" }
                val outFile = File(pickedDir, safeName)
                activity.contentResolver.openInputStream(uri)?.use { input: InputStream ->
                    FileOutputStream(outFile).use { output ->
                        input.copyTo(output, bufferSize = 64 * 1024)
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
        activity.contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (idx >= 0) return cursor.getString(idx)
            }
        }
        return null
    }
}
