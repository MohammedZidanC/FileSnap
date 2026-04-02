import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About FileSnap")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor, width: 4),
                image: const DecorationImage(
                  image: NetworkImage("https://mohammedzidanc.vercel.app/me.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Mohammed Zidan C", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            
            // Portfolio
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(LucideIcons.globe),
                title: const Text("Portfolio", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("mohammedzidanc.vercel.app"),
                trailing: const Icon(LucideIcons.externalLink),
                onTap: () => _launchURL("https://mohammedzidanc.vercel.app/"),
              ),
            ),
            const SizedBox(height: 24),
            
            // Contact
            const Align(alignment: Alignment.centerLeft, child: Text("CONTACT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
            ListTile(
              leading: const Icon(LucideIcons.mail),
              title: const Text("mohammedzidanc@gmail.com"),
              onTap: () => _launchURL("mailto:mohammedzidanc@gmail.com"),
            ),
            ListTile(
              leading: const Icon(LucideIcons.phone),
              title: const Text("+91 8590919142"),
              onTap: () => _launchURL("tel:8590919142"),
            ),
            const SizedBox(height: 24),
            
            // Socials
            const Align(alignment: Alignment.centerLeft, child: Text("SOCIALS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(LucideIcons.linkedin), onPressed: () {}),
                IconButton(icon: const Icon(LucideIcons.github), onPressed: () {}),
                IconButton(icon: const Icon(LucideIcons.instagram), onPressed: () {}),
                IconButton(icon: const Icon(LucideIcons.facebook), onPressed: () {}),
                IconButton(icon: const Icon(LucideIcons.messageCircle), onPressed: () {}), // WhatsApp
              ],
            )
          ],
        ),
      ),
    );
  }
}
