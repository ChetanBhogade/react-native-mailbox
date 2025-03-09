#import "generated/RNMailboxSpec/RNMailboxSpec.h"
#import <MessageUI/MessageUI.h>

@interface Mailbox : NSObject <NativeMailboxSpec, MFMailComposeViewControllerDelegate>

// Method for validating email format
- (BOOL)validateEmail:(NSString *)email;

// Method to send email via SMTP
- (void)sendMailViaSMTP:(NSDictionary *)mailConfig
                subject:(NSString *)subject
                   body:(NSString *)body
             recipients:(NSArray<NSString *> *)recipients
                    bcc:(NSArray<NSString *> *)bcc
        attachmentPaths:(NSArray<NSString *> *)attachmentPaths
        attachmentNames:(NSArray<NSString *> *)attachmentNames
           withResolver:(RCTPromiseResolveBlock)resolve
           withRejecter:(RCTPromiseRejectBlock)reject;

@end
