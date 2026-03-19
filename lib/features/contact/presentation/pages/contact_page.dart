import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/section_title.dart';
import '../widgets/contact_link_tile.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _launch(BuildContext context, String uriString) async {
    try {
      await launchUrl(
        Uri.parse(uriString),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.contactErrorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: AppStrings.sectionContact),
                  const SizedBox(height: 24),
                  ContactLinkTile(
                    icon: Icons.email,
                    title: AppStrings.contactEmail,
                    onTap: () => _launch(context, AppStrings.contactEmailUri),
                  ),
                  ContactLinkTile(
                    icon: Icons.code,
                    title: AppStrings.contactGitHub,
                    onTap: () => _launch(context, AppStrings.contactGitHubUri),
                  ),
                  ContactLinkTile(
                    icon: Icons.link,
                    title: AppStrings.contactLinkedIn,
                    onTap: () => _launch(context, AppStrings.contactLinkedInUri),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
