import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface MailConfig {
  fromName: string;
  email: string;
  password: string;
  mailHost: string;
  port: number;
  ssl: boolean;
  replyToAddress?: string;
}

export interface Spec extends TurboModule {
  multiply(a: number, b: number): number;
  sendMail(
    mailConfig: MailConfig,
    subject: string,
    body: string,
    recipients: string[],
    bcc?: string[],
    attachmentPaths?: string[],
    attachmentNames?: string[]
  ): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Mailbox');
