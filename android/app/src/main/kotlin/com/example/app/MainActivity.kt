package com.example.app

import android.app.role.RoleManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The launcher's platform side: opening other apps, and this app's standing as
 * the phone's home app.
 *
 * Kept to those two jobs deliberately. Everything a senior sees is drawn in
 * Flutter, and anything decided here cannot be covered by `flutter test`.
 */
class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "open" -> result.success(
                        open(
                            call.argument<String>("packageName"),
                            call.argument<String>("intent"),
                            call.argument<String>("fallbackUrl"),
                        )
                    )
                    "isDefaultHome" -> result.success(isDefaultHome())
                    "openHomeSettings" -> {
                        openHomeSettings()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    /**
     * Pressing Home while the senior is inside 설정 or SOS delivers a new HOME
     * intent to this already-running task rather than starting an activity, so
     * without this the home key looks broken from anywhere but the home screen.
     */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.hasCategory(Intent.CATEGORY_HOME)) {
            channel?.invokeMethod("goHome", null)
        }
    }

    /**
     * Package first, then the system category, then the web. Returns false when
     * none of them resolved — the caller says so in the senior's own words
     * instead of leaving them tapping a tile that does nothing.
     */
    private fun open(packageName: String?, intent: String?, fallbackUrl: String?): Boolean {
        if (packageName != null) {
            packageManager.getLaunchIntentForPackage(packageName)?.let { if (start(it)) return true }
        }
        intentFor(intent)?.let { if (start(it)) return true }
        if (fallbackUrl != null) {
            return start(Intent(Intent.ACTION_VIEW, Uri.parse(fallbackUrl)))
        }
        return false
    }

    /**
     * Asked for by category rather than by package, so each phone opens the
     * dialer, messenger and gallery its owner already uses.
     *
     * `dial` is ACTION_DIAL and never ACTION_CALL: `06_PERMISSION_AND_POLICY`
     * requires that the user press call themselves, and that holds for the 전화
     * button exactly as it does for SOS.
     */
    private fun intentFor(name: String?): Intent? = when (name) {
        "dial" -> Intent(Intent.ACTION_DIAL)
        "messaging" -> appIntent(Intent.CATEGORY_APP_MESSAGING)
        "gallery" -> appIntent(Intent.CATEGORY_APP_GALLERY)
        "browser" -> appIntent(Intent.CATEGORY_APP_BROWSER)
        "camera" -> Intent(MediaStore.INTENT_ACTION_STILL_IMAGE_CAMERA)
        else -> null
    }

    private fun appIntent(category: String): Intent =
        Intent(Intent.ACTION_MAIN).addCategory(category)

    /**
     * Caught rather than checked with resolveActivity: under Android 11's
     * package visibility rules resolveActivity can answer null for something
     * that would in fact start, and a tile that silently refuses is worse than
     * one that tries.
     */
    private fun start(intent: Intent): Boolean = try {
        startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        true
    } catch (e: ActivityNotFoundException) {
        false
    } catch (e: SecurityException) {
        false
    }

    private fun isDefaultHome(): Boolean {
        val home = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        val resolved = packageManager.resolveActivity(home, PackageManager.MATCH_DEFAULT_ONLY)
        return resolved?.activityInfo?.packageName == packageName
    }

    /**
     * Android 10 and up can ask inside the app through the HOME role, which is
     * one dialog rather than a trip into Settings — worth the branch, since the
     * senior is the one who has to complete it.
     */
    private fun openHomeSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roles = getSystemService(RoleManager::class.java)
            if (roles != null &&
                roles.isRoleAvailable(RoleManager.ROLE_HOME) &&
                !roles.isRoleHeld(RoleManager.ROLE_HOME)
            ) {
                if (start(roles.createRequestRoleIntent(RoleManager.ROLE_HOME))) return
            }
        }
        start(Intent(Settings.ACTION_HOME_SETTINGS))
    }

    private companion object {
        const val CHANNEL = "jalboine/launcher"
    }
}
