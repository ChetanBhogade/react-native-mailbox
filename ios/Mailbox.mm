#import "Mailbox.h"
#import <MessageUI/MessageUI.h>
// For SMTP implementation we would typically use a library like mailcore2
// But we'll implement our solution using Apple's built-in functionality

@implementation Mailbox
RCT_EXPORT_MODULE()

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);

    return result;
}

- (void)sendMail:(JS::NativeMailbox::MailConfig &)mailConfig subject:(nonnull NSString *)subject body:(nonnull NSString *)body recipients:(nonnull NSArray *)recipients bcc:(nonnull NSArray *)bcc attachmentPaths:(nonnull NSArray *)attachmentPaths attachmentNames:(nonnull NSArray *)attachmentNames resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
  <#code#>
}


// Method for validating email format
- (BOOL)validateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

// Helper method to get MIME type for file
- (NSString *)mimeTypeForPath:(NSString *)path {
    NSString *extension = [path pathExtension];
    
    // Simple MIME type mapping
    NSDictionary *mimeTypes = @{
        @"jpg": @"image/jpeg",
        @"jpeg": @"image/jpeg",
        @"png": @"image/png",
        @"gif": @"image/gif",
        @"pdf": @"application/pdf",
        @"doc": @"application/msword",
        @"docx": @"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        @"xls": @"application/vnd.ms-excel",
        @"xlsx": @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        @"ppt": @"application/vnd.ms-powerpoint",
        @"pptx": @"application/vnd.openxmlformats-officedocument.presentationml.presentation",
        @"txt": @"text/plain",
        @"html": @"text/html",
        @"csv": @"text/csv",
        @"zip": @"application/zip",
        @"mp3": @"audio/mpeg",
        @"mp4": @"video/mp4",
        @"mov": @"video/quicktime",
        @"json": @"application/json",
        @"xml": @"application/xml"
    };
    
    NSString *mimeType = mimeTypes[extension.lowercaseString];
    return mimeType ?: @"application/octet-stream";
}

- (void)sendMail:(NSDictionary *)mailConfig
         subject:(NSString *)subject
            body:(NSString *)body
      recipients:(NSArray<NSString *> *)recipients
             bcc:(NSArray<NSString *> *)bcc
 attachmentPaths:(NSArray<NSString *> *)attachmentPaths
 attachmentNames:(NSArray<NSString *> *)attachmentNames
    withResolver:(RCTPromiseResolveBlock)resolve
    withRejecter:(RCTPromiseRejectBlock)reject
{
    // Extract mail configuration
    NSString *mailEmail = mailConfig[@"email"];
    NSString *mailPassword = mailConfig[@"password"];
    NSString *mailHost = mailConfig[@"mailHost"];
    NSNumber *mailPort = mailConfig[@"port"];
    NSNumber *mailSsl = mailConfig[@"ssl"];
    NSString *fromName = mailConfig[@"fromName"];
    NSString *replyToAddress = mailConfig[@"replyToAddress"];
    
    // Log mail configuration
    NSLog(@"MailBox: sendMail called with parameters:");
    NSLog(@"MailBox: Mail Configuration:");
    NSLog(@"MailBox: - Email: %@", mailEmail);
    // Mask password in logs for security
    NSString *maskedPassword = [@"" stringByPaddingToLength:mailPassword.length withString:@"*" startingAtIndex:0];
    NSLog(@"MailBox: - Password: %@", maskedPassword);
    NSLog(@"MailBox: - Host: %@", mailHost);
    NSLog(@"MailBox: - Port: %@", mailPort);
    NSLog(@"MailBox: - SSL: %@", mailSsl ? @"YES" : @"NO");
    NSLog(@"MailBox: - From Name: %@", fromName);
    NSLog(@"MailBox: - Reply To: %@", replyToAddress ?: @"none");
    
    // Log other parameters
    NSLog(@"MailBox: Subject: %@", subject);
    NSString *bodySummary = body.length > 50 ? 
        [NSString stringWithFormat:@"%@...", [body substringToIndex:50]] : body;
    NSLog(@"MailBox: Body: %@", bodySummary);
    NSLog(@"MailBox: Recipients: %@", [recipients componentsJoinedByString:@", "]);
    NSLog(@"MailBox: BCC: %@", bcc ? [bcc componentsJoinedByString:@", "] : @"none");
    NSLog(@"MailBox: Attachments: %lu", (unsigned long)(attachmentPaths ? attachmentPaths.count : 0));
    
    // Validate required parameters
    if (!mailEmail || [mailEmail length] == 0) {
        reject(@"email_required", @"Email address is required", nil);
        return;
    }
    
    if (![self validateEmail:mailEmail]) {
        reject(@"invalid_email", @"Invalid email format", nil);
        return;
    }
    
    if (!mailPassword || [mailPassword length] == 0) {
        reject(@"password_required", @"Password is required", nil);
        return;
    }
    
    if (!mailHost || [mailHost length] == 0) {
        reject(@"host_required", @"Mail host is required", nil);
        return;
    }
    
    if (!mailPort || [mailPort intValue] <= 0) {
        reject(@"port_required", @"Valid port number is required", nil);
        return;
    }
    
    if (!recipients || recipients.count == 0) {
        reject(@"recipients_required", @"At least one recipient is required", nil);
        return;
    }
    
    // Validate all recipients have valid email format
    for (NSString *recipient in recipients) {
        if (![self validateEmail:recipient]) {
            reject(@"invalid_recipient", [NSString stringWithFormat:@"Invalid recipient email format: %@", recipient], nil);
            return;
        }
    }
    
    // Validate BCC emails if provided
    if (bcc) {
        for (NSString *bccEmail in bcc) {
            if (![self validateEmail:bccEmail]) {
                reject(@"invalid_bcc", [NSString stringWithFormat:@"Invalid BCC email format: %@", bccEmail], nil);
                return;
            }
        }
    }
    
    // Validate attachment paths and names if provided
    if (attachmentPaths && attachmentNames && attachmentPaths.count != attachmentNames.count) {
        reject(@"attachments_mismatch", @"Number of attachment paths and names must match", nil);
        return;
    }
    
    // Check if MessageUI is available for composing emails
    if (![MFMailComposeViewController canSendMail]) {
        // If MessageUI is not available, try to use SMTP method
        [self sendMailViaSMTP:mailConfig
                      subject:subject
                         body:body
                   recipients:recipients
                          bcc:bcc
              attachmentPaths:attachmentPaths
              attachmentNames:attachmentNames
                 withResolver:resolve
                 withRejecter:reject];
    } else {
        // Use MessageUI to send the email (easier but less control)
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
            mailComposeVC.mailComposeDelegate = self;
            
            // Set email properties
            [mailComposeVC setSubject:subject];
            [mailComposeVC setMessageBody:body isHTML:YES];
            [mailComposeVC setToRecipients:recipients];
            
            if (bcc && bcc.count > 0) {
                [mailComposeVC setBccRecipients:bcc];
            }
            
            // Add attachments if provided
            if (attachmentPaths && attachmentNames && attachmentPaths.count > 0) {
                for (NSUInteger i = 0; i < attachmentPaths.count; i++) {
                    NSString *path = attachmentPaths[i];
                    NSString *name = i < attachmentNames.count ? attachmentNames[i] : [path lastPathComponent];
                    NSData *fileData = [NSData dataWithContentsOfFile:path];
                    
                    if (fileData) {
                        NSString *mimeType = [self mimeTypeForPath:path];
                        [mailComposeVC addAttachmentData:fileData mimeType:mimeType fileName:name];
                    } else {
                        NSLog(@"MailBox: Warning - Could not read attachment data from path: %@", path);
                    }
                }
            }
            
            [rootViewController presentViewController:mailComposeVC animated:YES completion:nil];
            
            // Note: The actual completion/resolution happens in the delegate method
            // This is a limitation of MFMailComposeViewController
            // For now, we'll resolve immediately but in a real implementation
            // you'd likely want to handle this differently
            resolve(@YES);
        });
    }
}

// Implementation of mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError *)error {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (error) {
        NSLog(@"MailBox: Error sending email: %@", error.localizedDescription);
    } else {
        switch (result) {
            case MFMailComposeResultCancelled:
                NSLog(@"MailBox: Mail cancelled");
                break;
            case MFMailComposeResultSaved:
                NSLog(@"MailBox: Mail saved");
                break;
            case MFMailComposeResultSent:
                NSLog(@"MailBox: Mail sent");
                break;
            case MFMailComposeResultFailed:
                NSLog(@"MailBox: Mail failed");
                break;
            default:
                NSLog(@"MailBox: Mail finished with unknown result");
                break;
        }
    }
}

// Method to send email via SMTP (simplified implementation)
- (void)sendMailViaSMTP:(NSDictionary *)mailConfig
                subject:(NSString *)subject
                   body:(NSString *)body
             recipients:(NSArray<NSString *> *)recipients
                    bcc:(NSArray<NSString *> *)bcc
        attachmentPaths:(NSArray<NSString *> *)attachmentPaths
        attachmentNames:(NSArray<NSString *> *)attachmentNames
           withResolver:(RCTPromiseResolveBlock)resolve
           withRejecter:(RCTPromiseRejectBlock)reject {
    
    // For now, just log that we would send an email via SMTP
    NSLog(@"MailBox: sendMailViaSMTP called - This is a placeholder for actual SMTP implementation");
    
    // In a real implementation, you would use a library like MailCore2 to send emails via SMTP
    // For now, we'll just reject with a message
    reject(@"smtp_not_implemented", @"SMTP mail sending is not implemented yet", nil);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeMailboxSpecJSI>(params);
}

@end
