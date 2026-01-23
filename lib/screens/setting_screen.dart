import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/movie_provider.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate('setting', currentLang)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.5, -0.7),
            radius: 1.5,
            colors: [Color(0xFF3D0808), Colors.black],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- SEKSI AKUN ---
            Text(AppLocalizations.translate('account', currentLang),
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.person, color: Colors.white)),
              title: Text(user?.email ?? "User",
                  style: const TextStyle(color: Colors.white)),
              subtitle: const Text("Email Address",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white54),
                onPressed: () => _showEditProfileDialog(context, user),
              ),
            ),
            const Divider(color: Colors.white10),

            // --- SEKSI UMUM ---
            const SizedBox(height: 20),
            Text(AppLocalizations.translate('general', currentLang),
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            
            // FITUR NOTIFIKASI
            ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.white),
              title: const Text("Notifications", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Check for app updates", style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                _showUpdateNotification(context);
              },
            ),

            // FITUR BAHASA
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: Text(AppLocalizations.translate('language', currentLang),
                  style: const TextStyle(color: Colors.white)),
              trailing: DropdownButton<String>(
                value: currentLang,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en-US', child: Text("English")),
                  DropdownMenuItem(value: 'id-ID', child: Text("Indonesia")),
                ],
                onChanged: (val) {
                  if (val != null) ref.read(languageProvider.notifier).state = val;
                },
              ),
            ),
            const Divider(color: Colors.white10),

            // --- SEKSI INFO ---
            const SizedBox(height: 20),
            const Text("About", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const ListTile(
              leading: Icon(Icons.info_outline, color: Colors.white),
              title: Text("App Version", style: TextStyle(color: Colors.white)),
              trailing: Text("1.0.1", // Versi sudah diupdate ke 1.0.1
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
            
            // --- TOMBOL LOGOUT ---
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(AppLocalizations.translate('logout', currentLang),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi Simulasi Notifikasi Update
  void _showUpdateNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("System Update", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "Your app has been updated to version 1.0.1.\n\nNew Features:\n- Multi-language support\n- Watch Now (Trailer integration)\n- Bug fixes in Watchlist",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Awesome!", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // Fungsi Edit Profile
  void _showEditProfileDialog(BuildContext context, User? user) {
    final controller = TextEditingController(text: user?.email);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Update Profile", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "New Email/Username",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(email: controller.text),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile Updated! Check email to confirm.")));
              } catch (e) {
                print(e);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}