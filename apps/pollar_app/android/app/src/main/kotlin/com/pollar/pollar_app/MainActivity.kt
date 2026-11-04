package com.pollar.pollar_app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import java.io.File

class PollarUpdateFileProvider : FileProvider()

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.pollar/app_updates")
            .setMethodCallHandler { call, result ->
                if (call.method != "installUpdate") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    val path = call.argument<String>("path") ?: error("Missing package")
                    val apk = File(path).canonicalFile
                    val root = File(cacheDir, "pollar-updates").canonicalFile
                    require(apk.path.startsWith(root.path + File.separator) && apk.isFile && apk.extension == "apk")
                    @Suppress("DEPRECATION")
                    val archive = packageManager.getPackageArchiveInfo(apk.path, PackageManager.GET_SIGNATURES)
                        ?: error("Invalid package")
                    @Suppress("DEPRECATION")
                    val current = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
                    require(archive.packageName == packageName)
                    @Suppress("DEPRECATION")
                    val newer = if (Build.VERSION.SDK_INT >= 28) archive.longVersionCode > current.longVersionCode
                        else archive.versionCode > current.versionCode
                    require(newer)
                    @Suppress("DEPRECATION")
                    require(archive.signatures?.toSet() == current.signatures?.toSet() && !current.signatures.isNullOrEmpty())
                    if (Build.VERSION.SDK_INT >= 26 && !packageManager.canRequestPackageInstalls()) {
                        startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName")))
                        result.success("permissionRequired")
                    } else {
                        val uri = FileProvider.getUriForFile(this, "$packageName.updates", apk)
                        startActivity(Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(uri, "application/vnd.android.package-archive")
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        })
                        result.success("installerOpened")
                    }
                } catch (exception: Exception) {
                    result.error("UPDATE_INSTALL_FAILED", "Unable to open verified Pollar update", null)
                }
            }
    }
}
