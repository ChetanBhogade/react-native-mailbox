package com.mailbox

import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import java.util.Properties
import javax.mail.Authenticator
import javax.mail.Message
import javax.mail.MessagingException
import javax.mail.PasswordAuthentication
import javax.mail.Session
import javax.mail.Transport
import javax.mail.internet.InternetAddress
import javax.mail.internet.MimeBodyPart
import javax.mail.internet.MimeMessage
import javax.mail.internet.MimeMultipart
import java.io.File
import java.util.Date
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

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
    
    // Log recipients
    val recipientsLog = StringBuilder("Recipients: [")
    if (recipients != null) {
      for (i in 0 until recipients.size()) {
        if (i > 0) recipientsLog.append(", ")
        recipientsLog.append("\"${recipients.getString(i)}\"")
      }
    }
    recipientsLog.append("]")
    Log.d("MailBox", recipientsLog.toString())
    
    // Log BCC
    val bccLog = StringBuilder("BCC: [")
    if (bcc != null) {
      for (i in 0 until bcc.size()) {
        if (i > 0) bccLog.append(", ")
        bccLog.append("\"${bcc.getString(i)}\"")
      }
    }
    bccLog.append("]")
    Log.d("MailBox", bccLog.toString())
    
    // Log attachments
    Log.d("MailBox", "Attachments: ${attachmentPaths?.size() ?: 0}")
    if (attachmentPaths != null && attachmentPaths.size() > 0) {
      for (i in 0 until attachmentPaths.size()) {
        val attachmentPath = attachmentPaths.getString(i)
        val attachmentName = if (attachmentNames != null && i < attachmentNames.size()) 
          attachmentNames.getString(i) else null
        Log.d("MailBox", "- Attachment $i: Path=$attachmentPath, Name=$attachmentName")
      }
    }

    // Use coroutines to send email in the background thread
    CoroutineScope(Dispatchers.Main).launch {
      try {
        val result = withContext(Dispatchers.IO) {
          sendMailImplementation(
            mailUsername, 
            mailPassword, 
            mailHost, 
            mailPort, 
            mailSsl, 
            fromName, 
            replyToAddress,
            subject, 
            body, 
            recipients, 
            bcc, 
            attachmentPaths, 
            attachmentNames
          )
        }
        promise.resolve(result)
      } catch (e: Exception) {
        Log.e("MailBox", "Error sending email", e)
        promise.reject("SEND_MAIL_ERROR", "Failed to send email: ${e.message}", e)
      }
    }
  }
  
  /**
   * Implementation of email sending functionality using JavaMail
   */
  private fun sendMailImplementation(
    username: String?,
    password: String?,
    host: String?,
    port: Int,
    useSsl: Boolean,
    fromName: String?,
    replyToAddress: String?,
    subject: String?,
    body: String?,
    recipients: ReadableArray?,
    bcc: ReadableArray?,
    attachmentPaths: ReadableArray?,
    attachmentNames: ReadableArray?
  ): Boolean {
    if (username.isNullOrBlank() || password.isNullOrBlank() || host.isNullOrBlank()) {
      throw IllegalArgumentException("Email, password, and host are required and cannot be empty")
    }
    
    if (recipients == null || recipients.size() == 0) {
      throw IllegalArgumentException("At least one recipient is required")
    }

    // Set mail properties
    val props = Properties()
    props["mail.smtp.host"] = host
    props["mail.smtp.port"] = port.toString()
    props["mail.smtp.auth"] = "true"
    
    if (useSsl) {
      props["mail.smtp.socketFactory.port"] = port.toString()
      props["mail.smtp.socketFactory.class"] = "javax.net.ssl.SSLSocketFactory"
      props["mail.smtp.ssl.enable"] = "true"
    } else {
      // If not using SSL, check if starttls should be used (common for ports like 587)
      if (port == 587) {
        props["mail.smtp.starttls.enable"] = "true"
      }
    }

    // Create mail session with authentication
    val session = Session.getInstance(props, object : Authenticator() {
      override fun getPasswordAuthentication(): PasswordAuthentication {
        return PasswordAuthentication(username, password)
      }
    })
    
    // For debugging purposes
    // session.debug = true

    // Create message
    val message = MimeMessage(session)
    
    // Set from address with display name
    val fromDisplayName = fromName ?: username
    message.setFrom(InternetAddress(username, fromDisplayName))
    
    // Set reply-to address if provided
    if (!replyToAddress.isNullOrBlank()) {
      message.replyTo = arrayOf(InternetAddress(replyToAddress))
    }
    
    // Set recipients
    val recipientsList = mutableListOf<InternetAddress>()
    for (i in 0 until recipients.size()) {
      val recipient = recipients.getString(i)
      if (!recipient.isNullOrBlank()) {
        recipientsList.add(InternetAddress(recipient))
      } else {
        Log.w("MailBox", "Skipping empty recipient email at index $i")
      }
    }
    
    if (recipientsList.isEmpty()) {
      Log.e("MailBox", "No valid recipient emails provided")
      throw IllegalArgumentException("At least one valid recipient email is required")
    }
    
    message.setRecipients(
      Message.RecipientType.TO,
      recipientsList.toTypedArray()
    )
    
    // Set BCC recipients if provided
    if (bcc != null && bcc.size() > 0) {
      val bccList = mutableListOf<InternetAddress>()
      for (i in 0 until bcc.size()) {
        val bccRecipient = bcc.getString(i)
        if (!bccRecipient.isNullOrBlank()) {
          bccList.add(InternetAddress(bccRecipient))
        } else {
          Log.w("MailBox", "Skipping empty BCC email at index $i")
        }
      }
      
      if (bccList.isNotEmpty()) {
        message.setRecipients(
          Message.RecipientType.BCC,
          bccList.toTypedArray()
        )
        Log.d("MailBox", "Added ${bccList.size} BCC recipients")
      } else {
        Log.d("MailBox", "No valid BCC recipients to add")
      }
    }
    
    // Set subject
    message.subject = subject ?: ""
    
    // Create multipart message
    val multipart = MimeMultipart()
    
    // Add text part (body)
    val textPart = MimeBodyPart()
    // Check if body is HTML
    val isHtml = body?.startsWith("<html") == true || body?.contains("<body") == true || 
                 body?.contains("<div") == true || body?.contains("<p>") == true
    
    if (isHtml) {
      textPart.setContent(body, "text/html; charset=utf-8")
    } else {
      textPart.setText(body ?: "")
    }
    multipart.addBodyPart(textPart)
    
    // Add attachments if provided
    if (attachmentPaths != null && attachmentPaths.size() > 0) {
      var attachmentCount = 0
      for (i in 0 until attachmentPaths.size()) {
        val attachmentPath = attachmentPaths.getString(i)
        if (attachmentPath.isNullOrBlank()) {
          Log.w("MailBox", "Skipping empty attachment path at index $i")
          continue
        }
        
        val file = File(attachmentPath)
        
        if (file.exists()) {
          val attachmentPart = MimeBodyPart()
          attachmentPart.attachFile(file)
          
          // Set custom filename if provided
          var customFilename = file.name
          if (attachmentNames != null && i < attachmentNames.size()) {
            val customName = attachmentNames.getString(i)
            if (!customName.isNullOrBlank()) {
              attachmentPart.fileName = customName
              customFilename = customName
            }
          }
          
          multipart.addBodyPart(attachmentPart)
          attachmentCount++
          Log.d("MailBox", "Added attachment: $customFilename (${file.length()} bytes)")
        } else {
          Log.w("MailBox", "Attachment not found: $attachmentPath")
        }
      }
      Log.d("MailBox", "Total attachments added: $attachmentCount")
    }
    
    // Set content
    message.setContent(multipart)
    
    // Set sent date
    message.sentDate = Date()
    
    // Send message
    Transport.send(message)
    
    Log.d("MailBox", "Email sent successfully")
    return true
  }

  companion object {
    const val NAME = "Mailbox"
  }
}
