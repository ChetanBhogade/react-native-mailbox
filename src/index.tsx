import Mailbox from './NativeMailbox';
import type { MailConfig } from './NativeMailbox';

export function sendMail(
  mailConfig: MailConfig,
  subject: string,
  body: string,
  recipients: string[],
  bcc?: string[],
  attachmentPaths?: string[],
  attachmentNames?: string[]
) {
  return Mailbox.sendMail(
    mailConfig,
    subject,
    body,
    recipients,
    bcc || [],
    attachmentPaths || [],
    attachmentNames || []
  );
}

// Re-export the MailConfig interface for consumers
export type { MailConfig };
