package com.adadi.game

import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import java.io.PrintWriter
import java.io.StringWriter
import kotlin.system.exitProcess

/**
 * Catches native crashes (including ones before Flutter starts) and shows
 * them in [CrashActivity], which runs in its own ":crash" process, so a tester
 * sees the stack trace instead of the app silently closing.
 */
class AdadiApplication : Application() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        if (isCrashProcess()) return
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, error ->
            try {
                startActivity(
                    Intent(this, CrashActivity::class.java)
                        .putExtra(CrashActivity.EXTRA_REPORT, report(thread, error))
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK),
                )
                Process.killProcess(Process.myPid())
                exitProcess(10)
            } catch (_: Throwable) {
                previous?.uncaughtException(thread, error)
            }
        }
    }

    private fun isCrashProcess(): Boolean =
        Build.VERSION.SDK_INT >= 28 && getProcessName().endsWith(":crash")

    private fun report(thread: Thread, error: Throwable): String {
        val trace = StringWriter().also { error.printStackTrace(PrintWriter(it)) }
        val version = try {
            packageManager.getPackageInfo(packageName, 0).versionName
        } catch (_: Throwable) {
            "?"
        }
        return buildString {
            appendLine("Adadi native crash report")
            appendLine("App $version, Android ${Build.VERSION.RELEASE} (SDK ${Build.VERSION.SDK_INT})")
            appendLine("Device ${Build.MANUFACTURER} ${Build.MODEL}")
            appendLine("Thread ${thread.name}")
            appendLine()
            append(trace)
        }
    }
}
