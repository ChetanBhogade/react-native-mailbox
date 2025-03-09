import {
  Text,
  View,
  StyleSheet,
  TextInput,
  Button,
  ScrollView,
  Alert,
  Switch,
} from 'react-native';
import { multiply, sendMail, type MailConfig } from 'react-native-mailbox';
import { useState } from 'react';

const result = multiply(3, 8);

export default function App() {
  // Form states
  const [subject, setSubject] = useState('');
  const [body, setBody] = useState('');
  const [fromName, setFromName] = useState('');
  const [email, setEmail] = useState('your-email@example.com');
  const [password, setPassword] = useState('your-password');
  const [mailHost, setMailHost] = useState('smtp.example.com');
  const [port, setPort] = useState('587');
  const [ssl, setSsl] = useState(true);
  const [replyToAddress, setReplyToAddress] = useState('');
  const [recipientsText, setRecipientsText] = useState('');
  const [bccText, setBccText] = useState('');
  const [attachmentPathsText, setAttachmentPathsText] = useState('');
  const [attachmentNamesText, setAttachmentNamesText] = useState('');

  const handleSendMail = () => {
    // Convert comma-separated text inputs to arrays
    const recipients = recipientsText.split(',').map((mail) => mail.trim());
    const bcc = bccText.split(',').map((mail) => mail.trim());
    const attachmentPaths = attachmentPathsText
      ? attachmentPathsText.split(',').map((path) => path.trim())
      : [];
    const attachmentNames = attachmentNamesText
      ? attachmentNamesText.split(',').map((name) => name.trim())
      : [];

    const mailConfig: MailConfig = {
      fromName,
      email,
      password,
      mailHost,
      port: parseInt(port, 10),
      ssl,
      replyToAddress,
    };

    try {
      sendMail(
        mailConfig,
        subject,
        body,
        recipients,
        bcc,
        attachmentPaths,
        attachmentNames
      );

      Alert.alert('Success', 'Email sent successfully!');

      // Reset form after successful submission
      resetForm();
    } catch (error) {
      Alert.alert(
        'Error',
        'Failed to send email: ' +
          (error instanceof Error ? error.message : String(error))
      );
    }
  };

  const resetForm = () => {
    setSubject('');
    setBody('');
    setFromName('');
    setReplyToAddress('');
    setRecipientsText('');
    setBccText('');
    setAttachmentPathsText('');
    setAttachmentNamesText('');
    // Don't reset email configuration fields
  };

  return (
    <ScrollView contentContainerStyle={styles.scrollContainer}>
      <View style={styles.container}>
        <Text style={styles.title}>Send Email</Text>

        <Text style={styles.sectionTitle}>Mail Server Configuration</Text>

        <Text style={styles.label}>Email:</Text>
        <TextInput
          style={styles.input}
          value={email}
          onChangeText={setEmail}
          placeholder="Your email address"
          keyboardType="email-address"
        />

        <Text style={styles.label}>Password:</Text>
        <TextInput
          style={styles.input}
          value={password}
          onChangeText={setPassword}
          placeholder="Your password"
          secureTextEntry
        />

        <Text style={styles.label}>Mail Host:</Text>
        <TextInput
          style={styles.input}
          value={mailHost}
          onChangeText={setMailHost}
          placeholder="SMTP server (e.g., smtp.gmail.com)"
        />

        <Text style={styles.label}>Port:</Text>
        <TextInput
          style={styles.input}
          value={port}
          onChangeText={setPort}
          placeholder="Port (e.g., 587)"
          keyboardType="number-pad"
        />

        <View style={styles.switchContainer}>
          <Text style={styles.label}>Use SSL:</Text>
          <Switch value={ssl} onValueChange={setSsl} />
        </View>

        <Text style={styles.sectionTitle}>Email Content</Text>

        <Text style={styles.label}>Subject:</Text>
        <TextInput
          style={styles.input}
          value={subject}
          onChangeText={setSubject}
          placeholder="Email subject"
        />

        <Text style={styles.label}>From Name:</Text>
        <TextInput
          style={styles.input}
          value={fromName}
          onChangeText={setFromName}
          placeholder="Sender name"
        />

        <Text style={styles.label}>Reply-To Address:</Text>
        <TextInput
          style={styles.input}
          value={replyToAddress}
          onChangeText={setReplyToAddress}
          placeholder="Reply-to email address"
          keyboardType="email-address"
        />

        <Text style={styles.label}>Recipients (comma-separated):</Text>
        <TextInput
          style={styles.input}
          value={recipientsText}
          onChangeText={setRecipientsText}
          placeholder="recipient1@example.com, recipient2@example.com"
          keyboardType="email-address"
        />

        <Text style={styles.label}>BCC (comma-separated):</Text>
        <TextInput
          style={styles.input}
          value={bccText}
          onChangeText={setBccText}
          placeholder="bcc1@example.com, bcc2@example.com"
          keyboardType="email-address"
        />

        <Text style={styles.label}>Attachment Paths (comma-separated):</Text>
        <TextInput
          style={styles.input}
          value={attachmentPathsText}
          onChangeText={setAttachmentPathsText}
          placeholder="/path/to/file1, /path/to/file2"
        />

        <Text style={styles.label}>Attachment Names (comma-separated):</Text>
        <TextInput
          style={styles.input}
          value={attachmentNamesText}
          onChangeText={setAttachmentNamesText}
          placeholder="file1.pdf, file2.jpg"
        />

        <Text style={styles.label}>Body:</Text>
        <TextInput
          style={[styles.input, styles.bodyInput]}
          value={body}
          onChangeText={setBody}
          placeholder="Email body"
          multiline
          numberOfLines={4}
        />

        <View style={styles.buttonContainer}>
          <Button
            title="Send Email"
            onPress={handleSendMail}
            disabled={
              !subject ||
              !body ||
              !fromName ||
              !email ||
              !password ||
              !mailHost ||
              !port ||
              !recipientsText
            }
          />
        </View>

        <Text style={styles.multiplierText}>Multiply Result: {result}</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scrollContainer: {
    flexGrow: 1,
  },
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
    marginTop: 15,
    textAlign: 'center',
  },
  label: {
    fontSize: 16,
    marginBottom: 5,
    fontWeight: '500',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 5,
    padding: 10,
    marginBottom: 15,
    backgroundColor: '#f9f9f9',
  },
  bodyInput: {
    height: 100,
    textAlignVertical: 'top',
  },
  buttonContainer: {
    marginVertical: 15,
  },
  multiplierText: {
    marginTop: 20,
    textAlign: 'center',
    color: '#666',
  },
  switchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
    justifyContent: 'space-between',
  },
});
