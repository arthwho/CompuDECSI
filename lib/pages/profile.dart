import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/services/shared_pref.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/pages/onboarding_page.dart';
import 'package:compudecsi/pages/privacy_policy_page.dart';
import 'package:compudecsi/pages/terms_of_use_page.dart';
import 'package:compudecsi/pages/notification_settings_page.dart';
import 'package:animated_emoji/animated_emoji.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser;
  String? userName;
  String? userEmail;
  String? userImage;
  String? userRole;
  String selectedEmoji = 'alienMonster'; // Default emoji

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      // Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        setState(() {
          userName = userData['Name'] ?? 'Usuário';
          userEmail = userData['Email'] ?? user!.email ?? '';
          userImage = userData['Image'] ?? '';
          userRole = userData['role'] ?? 'student';
        });
      } else {
        // Fallback to Firebase Auth data
        setState(() {
          userName = user!.displayName ?? 'Usuário';
          userEmail = user!.email ?? '';
          userImage = user!.photoURL ?? '';
          userRole = 'student';
        });
      }
    }

    // Load emoji preference
    await _loadEmojiPreference();
  }

  Future<void> _loadEmojiPreference() async {
    final emoji = await SharedpreferenceHelper().getUserEmoji();
    if (emoji != null && emoji.isNotEmpty) {
      setState(() {
        selectedEmoji = emoji;
      });
    }
  }

  Future<void> _saveEmojiPreference(String emoji) async {
    await SharedpreferenceHelper().saveUserEmoji(emoji);
    setState(() {
      selectedEmoji = emoji;
    });
  }

  void _showEmojiSelectionDialog() {
    final List<Map<String, dynamic>> availableEmojis = [
      {'name': 'Alien Monster', 'value': 'alienMonster'},
      {'name': 'Rocket', 'value': 'rocket'},
      {'name': 'Robot', 'value': 'robot'},
      {'name': 'Fire', 'value': 'fire'},
      {'name': 'Thumbs Up', 'value': 'thumbsUp'},
      {'name': 'Party Popper', 'value': 'partyPopper'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Escolher Emoji'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: availableEmojis.length,
              itemBuilder: (context, index) {
                final emoji = availableEmojis[index];
                final isSelected = selectedEmoji == emoji['value'];

                return InkWell(
                  onTap: () {
                    _saveEmojiPreference(emoji['value']);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Emoji alterado para ${emoji['name']}!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedEmoji(
                          _getAnimatedEmoji(emoji['value']),
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          emoji['name'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  AnimatedEmojiData _getAnimatedEmoji(String emojiValue) {
    switch (emojiValue) {
      case 'alienMonster':
        return AnimatedEmojis.alienMonster;
      case 'rocket':
        return AnimatedEmojis.rocket;
      case 'robot':
        return AnimatedEmojis.robot;
      case 'fire':
        return AnimatedEmojis.fire;
      case 'thumbsUp':
        return AnimatedEmojis.thumbsUp;
      case 'partyPopper':
        return AnimatedEmojis.partyPopper;
      default:
        return AnimatedEmojis.alienMonster;
    }
  }

  String _getRoleDisplayName(String? role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'speaker':
        return 'Palestrante';
      case 'student':
      default:
        return 'Estudante';
    }
  }

  String formatFirstAndLastName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return _capitalize(parts[0]);
    } else {
      return _capitalize(parts.first) + ' ' + _capitalize(parts.last);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Future<void> _logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigation is now handled automatically by AuthWrapper
      // No need to manually navigate here
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('Confirmar Logout'),
          content: const Text('Tem certeza que deseja sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: Text('Faça login para ver seu perfil')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: userImage != null && userImage!.isNotEmpty
                  ? NetworkImage(userImage!)
                  : null,
              child: userImage == null || userImage!.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),

            const SizedBox(height: 20),

            // User Name
            Text(
              formatFirstAndLastName(userName) != ''
                  ? formatFirstAndLastName(userName)
                  : 'Usuário',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: AppSpacing.sm),

            // User Email
            Text(
              userEmail ?? '',
              style: TextStyle(fontSize: 16, color: AppColors.grey),
            ),

            SizedBox(height: AppSpacing.md),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getRoleDisplayName(userRole),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Profile Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  /* ListTile(
                    leading: Icon(
                      Icons.person_outline,
                      color: AppColors.purpleDark,
                    ),
                    title: const Text('Editar Perfil'),
                    subtitle: const Text('Atualizar informações pessoais'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement edit profile functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade em desenvolvimento'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1), */
                  ListTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.purpleDark,
                    ),
                    title: const Text('Notificações'),
                    subtitle: const Text('Configurar preferências'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),
                  /* const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: AppColors.purpleDark,
                    ),
                    title: const Text('Ajuda'),
                    subtitle: const Text('Suporte e FAQ'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement help section
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade em desenvolvimento'),
                        ),
                      );
                    },
                  ), */
                  const Divider(height: 1),
                  ListTile(
                    leading: AnimatedEmoji(
                      _getAnimatedEmoji(selectedEmoji),
                      size: 24,
                    ),
                    title: const Text('Alterar Emoji'),
                    subtitle: const Text('Personalizar emoji do perfil'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showEmojiSelectionDialog();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Política de Privacidade',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: AppColors.grey.withValues(alpha: 0.3),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsOfUsePage(),
                      ),
                    );
                  },
                  child: Text(
                    'Termos de Uso',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showLogoutDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                  side: BorderSide(color: AppColors.destructive, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sair da Conta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
