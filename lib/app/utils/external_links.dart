import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralized external links and safe launch helpers for Luma.
abstract final class ExternalLinks {
  static const privacyPolicyUrl = 'https://manmit-s.github.io/luma/';
  static const termsUrl = 'https://manmit-s.github.io/luma/';
  static const sourceCodeUrl = 'https://github.com/manmit-s/luma';
  static const githubProfileUrl = 'https://github.com/manmit-s';
  static const linkedinUrl = 'https://www.linkedin.com/in/manmit-samal';
  static const developerEmail = 'work.manmit.samal@zohomail.in';

  /// Launches an external URL using [LaunchMode.externalApplication].
  ///
  /// Displays a user-friendly [SnackBar] if opening the URL fails or if no
  /// compatible application is installed, preventing any unhandled exceptions.
  static Future<bool> openUrl(
    BuildContext context,
    String urlString, {
    String? failureMessage,
  }) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      if (context.mounted) {
        _showFailure(context, failureMessage ?? 'Invalid link: $urlString');
      }
      return false;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showFailure(
          context,
          failureMessage ?? 'Could not open link: $urlString',
        );
      }
      return launched;
    } catch (_) {
      if (context.mounted) {
        _showFailure(
          context,
          failureMessage ?? 'Could not open link: $urlString',
        );
      }
      return false;
    }
  }

  /// Opens the device's email composer with a `mailto:` URI.
  static Future<bool> openEmail(
    BuildContext context,
    String email, {
    String? subject,
  }) {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: subject != null ? 'subject=${Uri.encodeComponent(subject)}' : null,
    );
    return openUrl(
      context,
      uri.toString(),
      failureMessage: 'No email app available to compose message to $email.',
    );
  }

  static void _showFailure(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
