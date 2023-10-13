// import 'package:url_launcher/url_launcher_string.dart';

class Command {
  static final commands = [
    email,
    browser,
    launchUrl,
  ];

  static const email = 'write email', browser = 'open', launchUrl = 'go to';
}

class Utils {
  static String _executeCommand({
    required String text,
    required String command,
  }) {
    final commandIndex = text.indexOf(command);
    final finalIndex = commandIndex + command.length;

    if (commandIndex == -1) {
      return '';
    } else {
      return text.substring(finalIndex).trim();
    }
  }

  // static Future _launchUrl(String url) async {
  //   if (await canLaunchUrlString(url)) {
  //     await launchUrlString(url, mode: LaunchMode.externalApplication);
  //   }
  // }
  //
  // static Future openEmail(String body) async {
  //   final url = 'mailto: ?body=${Uri.encodeFull(body)}';
  //   await _launchUrl(url);
  // }
  //
  // static Future openLink(String url) async {
  //   if (url.trim().isEmpty) {
  //     await _launchUrl('https://google.com');
  //   } else {
  //     await _launchUrl('https://$url');
  //   }
  // }

  static void scanVoicedText(String voicedText) {
    // final text = voicedText.toLowerCase();
    //
    // if (text.contains(Command.email)) {
    //   final body = _executeCommand(text: text, command: Command.email);
    //
    //   openEmail(body);
    // } else if (text.contains(Command.browser)) {
    //   final url1 = _executeCommand(text: text, command: Command.browser);
    //   openLink(url1);
    // } else if (text.contains(Command.launchUrl)) {
    //   final url2 = _executeCommand(text: text, command: Command.launchUrl);
    //   openLink(url2);
    // }
  }
}
