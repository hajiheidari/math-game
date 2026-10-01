package com.adadi.game

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast

/** Shows a crash report from [AdadiApplication] with Copy / Share / Restart. */
class CrashActivity : Activity() {
    companion object {
        const val EXTRA_REPORT = "report"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val report = intent.getStringExtra(EXTRA_REPORT) ?: "No report"
        val pad = (16 * resources.displayMetrics.density).toInt()

        val title = TextView(this).apply {
            text = "Adadi crashed / عددی بسته شد\n" +
                "Please tap Copy or Share and send this to the developer.\n" +
                "لطفاً Copy یا Share را بزنید و این گزارش را برای سازنده بفرستید."
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.rgb(0xB3, 0x26, 0x1E))
            setPadding(pad, pad * 2, pad, pad)
            textSize = 15f
        }
        val body = TextView(this).apply {
            text = report
            typeface = Typeface.MONOSPACE
            textSize = 11f
            setTextIsSelectable(true)
            setPadding(pad, pad, pad, pad)
        }
        val scroll = ScrollView(this).apply { addView(body) }

        fun button(label: String, action: () -> Unit) = Button(this).apply {
            text = label
            setOnClickListener { action() }
            layoutParams = LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f)
        }
        val buttons = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(pad / 2, pad / 2, pad / 2, pad)
            addView(button("Copy") {
                val clipboard = getSystemService(CLIPBOARD_SERVICE) as ClipboardManager
                clipboard.setPrimaryClip(ClipData.newPlainText("Adadi crash", report))
                Toast.makeText(this@CrashActivity, "Copied", Toast.LENGTH_SHORT).show()
            })
            addView(button("Share") {
                startActivity(
                    Intent.createChooser(
                        Intent(Intent.ACTION_SEND).setType("text/plain")
                            .putExtra(Intent.EXTRA_TEXT, report),
                        "Send crash report",
                    ),
                )
            })
            addView(button("Restart") {
                startActivity(
                    Intent(this@CrashActivity, MainActivity::class.java)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK),
                )
                finish()
            })
        }

        setContentView(
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                setBackgroundColor(Color.WHITE)
                addView(title, LinearLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT))
                addView(scroll, LinearLayout.LayoutParams(MATCH_PARENT, 0, 1f))
                addView(buttons, LinearLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT))
            },
        )
    }
}
