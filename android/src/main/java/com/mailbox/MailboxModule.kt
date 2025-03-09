package com.mailbox

import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = MailboxModule.NAME)
class MailboxModule(reactContext: ReactApplicationContext) :
  NativeMailboxSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  override fun sendMail(
    mailConfig: ReadableMap,
    subject: String?,
    body: String?,
    recipients: ReadableArray?,
    bcc: ReadableArray?,
    attachmentPaths: ReadableArray?,
    attachmentNames: ReadableArray?,
    promise: Promise
  ) {
    // Log mail configuration
    val mailUsername = mailConfig.getString("email")
    val mailPassword = mailConfig.getString("password")
    val mailHost = mailConfig.getString("mailHost")
    val mailPort = mailConfig.getInt("port")
    val mailSsl = mailConfig.getBoolean("ssl")
    val fromName = mailConfig.getString("fromName")
    val replyToAddress = if (mailConfig.hasKey("replyToAddress")) mailConfig.getString("replyToAddress") else null
    
    Log.d("MailBox", "sendMail called with parameters:")
    Log.d("MailBox", "Mail Configuration:")
    Log.d("MailBox", "- Email: $mailUsername")
    Log.d("MailBox", "- Password: ${mailPassword?.replace(Regex("."), "*")}")
    Log.d("MailBox", "- Host: $mailHost")
    Log.d("MailBox", "- Port: $mailPort")
    Log.d("MailBox", "- SSL: $mailSsl")
    Log.d("MailBox", "- From Name: $fromName")
    Log.d("MailBox", "- Reply To: $replyToAddress")
    
    // Log other parameters
    Log.d("MailBox", "Subject: $subject")
    Log.d("MailBox", "Body: ${body?.take(50)}${if (body != null && body.length > 50) "..." else ""}")
    Log.d("MailBox", "Recipients: ${recipients.toString()}")
    Log.d("MailBox", "BCC: ${bcc?.toString() ?: "none"}")
    Log.d("MailBox", "Attachments: ${attachmentPaths?.size() ?: 0}")

    // TODO: Implement actual email sending functionality using the mail configuration
    // E.g. set up JavaMail with the provided SMTP settings

    // For now, we'll just return success
    promise.resolve(true)
  }

  companion object {
    const val NAME = "Mailbox"
  }
}
