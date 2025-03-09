#import "Mailbox.h"

@implementation Mailbox
RCT_EXPORT_MODULE()

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);

    return result;
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
    
    // TODO: Implement actual email sending functionality using the mail configuration
    // E.g. set up MessageUI or a third-party SMTP library with the provided settings
    
    // For now, we'll just return success
    resolve(@YES);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeMailboxSpecJSI>(params);
}

@end
