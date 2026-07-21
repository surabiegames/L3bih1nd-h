package com.example.wipel5

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MethodChannel penyimpanan ke MediaStore — supaya folder backup
 * `tirtawening/backup` TERLIHAT di Galeri/File tanpa izin runtime.
 *
 * Di Android 10+ (API 29, scoped storage) aplikasi boleh menulis ke koleksi
 * publik Pictures/Download lewat MediaStore TANPA izin apa pun, dan berkasnya
 * langsung terindeks (bisa dibuka Galeri) — beda dari Android/data yang tak
 * terindeks (akar keluhan "susah terlihat / tak terbaca galeri"). Di bawah
 * API 29 method mengembalikan false (fallback ke penyimpanan app-external
 * yang sudah ada) supaya tidak butuh WRITE_EXTERNAL_STORAGE.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "id.tirtawening/galeri"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "simpanKeMediaStore" -> {
                        try {
                            val bytes = call.argument<ByteArray>("bytes")
                            val displayName = call.argument<String>("displayName")
                            val relativePath = call.argument<String>("relativePath")
                            val mime = call.argument<String>("mime")
                            val isImage = call.argument<Boolean>("isImage") ?: true
                            if (bytes == null || displayName == null || relativePath == null || mime == null) {
                                result.error("ARG", "Argumen tidak lengkap", null)
                            } else {
                                result.success(simpanKeMediaStore(bytes, displayName, relativePath, mime, isImage))
                            }
                        } catch (e: Exception) {
                            result.error("GAGAL", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** true = tersimpan/sudah ada; false = tidak didukung (API < 29) atau gagal. */
    private fun simpanKeMediaStore(
        bytes: ByteArray,
        displayName: String,
        relativePath: String,
        mime: String,
        isImage: Boolean,
    ): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return false
        val resolver = contentResolver
        val collection: Uri = if (isImage) {
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        } else {
            MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        }
        val rel = if (relativePath.endsWith("/")) relativePath else "$relativePath/"

        // Idempoten: lewati bila berkas dengan nama+path sama sudah ada
        // (ekspor berulang tidak menggandakan entri galeri).
        val proj = arrayOf(MediaStore.MediaColumns._ID)
        val sel = "${MediaStore.MediaColumns.DISPLAY_NAME}=? AND ${MediaStore.MediaColumns.RELATIVE_PATH}=?"
        resolver.query(collection, proj, sel, arrayOf(displayName, rel), null)?.use { cur ->
            if (cur.count > 0) return true
        }

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, displayName)
            put(MediaStore.MediaColumns.MIME_TYPE, mime)
            put(MediaStore.MediaColumns.RELATIVE_PATH, rel)
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val uri = resolver.insert(collection, values) ?: return false
        try {
            resolver.openOutputStream(uri)?.use { it.write(bytes) } ?: run {
                resolver.delete(uri, null, null)
                return false
            }
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            return false
        }
        values.clear()
        values.put(MediaStore.MediaColumns.IS_PENDING, 0)
        resolver.update(uri, values, null, null)
        return true
    }
}
