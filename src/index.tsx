import Mailbox from './NativeMailbox';
import type { MailConfig } from './NativeMailbox';

export function multiply(a: number, b: number): number {
  return Mailbox.multiply(a, b);
}

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
