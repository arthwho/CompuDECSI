import 'package:flutter/material.dart';
import 'package:compudecsi/services/notification_service.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _pendingNotificationsWithTimes = [];

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          final role = userDoc.data()?['role'] as String?;
          setState(() {
            _isAdmin = role == 'admin';
          });
        }
      }
    } catch (e) {
      print('Error checking admin role: $e');
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final enabled = await _notificationService.areNotificationsEnabled();
      final pending = await _notificationService
          .getPendingNotificationsWithTimes();

      setState(() {
        _notificationsEnabled = enabled;
        _pendingNotificationsWithTimes = pending;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notification settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await _notificationService.initialize();
      await _loadNotificationSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissões de notificação atualizadas'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar permissões: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testNotification() async {
    try {
      await _notificationService.scheduleEventNotification(
        eventId: 'test_event_${DateTime.now().millisecondsSinceEpoch}',
        eventTitle: 'Teste de Notificação',
        eventLocation: 'Local de Teste',
        eventDateTime: DateTime.now().add(
          const Duration(minutes: 2),
        ), // 2 minutes from now
        eventDescription: 'Esta é uma notificação de teste',
      );

      await _loadNotificationSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notificação de teste agendada para 1 minuto e 30 segundos',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar notificação de teste: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testImmediateNotification() async {
    try {
      await _notificationService.showImmediateNotification(
        title: 'Teste Imediato',
        body: 'Esta é uma notificação de teste imediata!',
        payload: 'test_immediate',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação imediata enviada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar notificação imediata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      await _loadNotificationSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas as notificações foram canceladas'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar notificações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Configurações de Notificação'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Status Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _notificationsEnabled
                                    ? Icons.notifications_active
                                    : Icons.notifications_off,
                                color: _notificationsEnabled
                                    ? Colors.green
                                    : Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Status das Notificações',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _notificationsEnabled
                                ? 'As notificações estão ativadas. Você receberá lembretes 30 minutos antes dos eventos.'
                                : 'As notificações estão desativadas. Ative-as para receber lembretes dos eventos.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!_notificationsEnabled)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _requestNotificationPermission,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Ativar Notificações'),
                              ),
                            ),
                          const SizedBox(height: 12),
                          if (_isAdmin)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _testNotification,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Testar Notificação (1m30s)'),
                              ),
                            ),
                          const SizedBox(height: 8),
                          if (_isAdmin)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _testImmediateNotification,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: BorderSide(color: Colors.green),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Testar Notificação Imediata',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notification Types Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.settings,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Tipos de Notificação',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildNotificationTypeItem(
                            icon: Icons.event,
                            title: 'Lembretes de Eventos',
                            subtitle:
                                'Receba notificações 30 minutos antes dos eventos',
                            enabled: true,
                          ),
                          const Divider(),
                          _buildNotificationTypeItem(
                            icon: Icons.info_outline,
                            title: 'Atualizações do App',
                            subtitle:
                                'Receba notificações sobre novas funcionalidades',
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Scheduled Notifications Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Notificações Agendadas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_pendingNotificationsWithTimes.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.notifications_none,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Nenhuma notificação agendada',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'As notificações aparecerão aqui quando você se inscrever em eventos',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: [
                                ..._pendingNotificationsWithTimes.map(
                                  (notificationData) =>
                                      _buildScheduledNotificationItem(
                                        notificationData['notification'],
                                        notificationData['scheduledTime'],
                                      ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: _cancelAllNotifications,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancelar Todas as Notificações',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Information Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Como funcionam as notificações',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Você receberá uma notificação 30 minutos antes de cada evento\n'
                          '• As notificações incluem o nome do evento e local\n'
                          '• Você pode cancelar notificações individuais ou todas de uma vez\n'
                          '• As notificações são agendadas automaticamente quando você se inscreve em um evento',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationTypeItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled ? AppColors.primary : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: null, // Disabled for now
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledNotificationItem(
    PendingNotificationRequest notification,
    String scheduledTime,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title ?? 'Notificação',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (notification.body != null)
                  Text(
                    notification.body!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  'Evento: $scheduledTime',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () async {
              await _notificationService.cancelEventNotification(
                notification.id.toString(),
              );
              await _loadNotificationSettings();
            },
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}
