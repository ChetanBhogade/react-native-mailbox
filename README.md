# react-native-mailbox

Send SMTP mails with attachments from React Native

## Installation

```sh
npm install react-native-mailbox
```

## Usage

```js
import { sendMail } from 'react-native-mailbox';

// Configure mail settings
const mailConfig = {
  host: 'smtp.gmail.com',
  port: 587,
  username: 'your-email@gmail.com',
  password: 'your-app-specific-password',
  ssl: true,
  replyToAddress: 'reply-to@example.com',
};

// Send email
sendMail(
  mailConfig,
  'Email Subject',
  'Email Body Content',
  ['recipient@example.com'],
  ['bcc@example.com'], // optional
  ['path/to/attachment.pdf'], // optional
  ['attachment.pdf'] // optional attachment names
);
```

### Parameters

- `mailConfig`: Configuration object for SMTP settings
  - `host`: SMTP server host
  - `port`: SMTP server port
  - `username`: Email username/address
  - `password`: Email password or app-specific password
  - `ssl`: Enable/disable SSL (boolean)
  - `replyToAddress`: Reply-to email address
- `subject`: Email subject
- `body`: Email body content
- `recipients`: Array of recipient email addresses
- `bcc`: (Optional) Array of BCC email addresses
- `attachmentPaths`: (Optional) Array of file paths for attachments
- `attachmentNames`: (Optional) Array of custom names for attachments

## Note

The iOS implementation is currently in development and not thoroughly tested. Pull requests are welcome for any improvements, especially for the iOS implementation.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

## Author

[Chetan Bhogade](https://github.com/ChetanBhogade)

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
