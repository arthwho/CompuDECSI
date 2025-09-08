import 'package:flutter/material.dart';
import 'package:compudecsi/utils/app_theme.dart' as theme;
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/services/category_service.dart';
import 'package:compudecsi/services/event_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/admin/edit_event_page.dart';
import 'package:compudecsi/admin/upload_event.dart';
import 'package:compudecsi/services/feedback_service.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedStatusFilter = 'all';
  String? userRole;
  String? currentUserId;
  String? currentUserName;

  @override
  void initState() {
    super.initState();
    _reloadEventsWithRole();
    _loadCategories();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            userRole = userData['role'] ?? 'student';
            // Store user name for speaker filtering
            currentUserName = userData['Name'] ?? '';
          });
        }
      } catch (e) {
        print('Error loading user role: $e');
        setState(() {
          userRole = 'student';
        });
      }
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final eventsData = await DatabaseMethods().getAllEventsList();

      // Filter events based on user role
      List<Map<String, dynamic>> filteredEventsData = eventsData;

      if (userRole == 'speaker') {
        // Speakers can only see events they are lecturing
        if (currentUserName != null && currentUserName!.isNotEmpty) {
          filteredEventsData = eventsData.where((event) {
            return event['speaker'] == currentUserName;
          }).toList();

          // Debug: Print events and filtering info
          print('Current user name: $currentUserName');
          print('Total events: ${eventsData.length}');
          print('Filtered events: ${filteredEventsData.length}');
          for (var event in eventsData) {
            print('Event: ${event['name']}, Speaker: ${event['speaker']}');
          }
        } else {
          // If user name is not loaded yet, show no events
          filteredEventsData = [];
          print('User name not loaded yet, showing no events');
        }
      }
      // Admins can see all events (no filtering needed)

      setState(() {
        events = filteredEventsData;
        filteredEvents = filteredEventsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar eventos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reloadEventsWithRole() async {
    await _loadUserRole();
    await _loadEvents();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await CategoryService.getCategories();
      setState(() {
        categories = categoriesData;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  String _getCategoryName(String categoryValue) {
    try {
      final category = categories.firstWhere(
        (cat) => cat['value'] == categoryValue,
      );
      return category['name'] as String;
    } catch (e) {
      return categoryValue;
    }
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'analytics':
        return Icons.analytics;
      case 'security':
        return Icons.security;
      case 'smart_toy':
        return Icons.smart_toy;
      case 'psychology':
        return Icons.psychology;
      case 'code':
        return Icons.code;
      case 'computer':
        return Icons.computer;
      case 'electric_bolt':
        return Icons.electric_bolt;
      case 'signal_cellular_alt':
        return Icons.signal_cellular_alt;
      default:
        return Icons.category;
    }
  }

  IconData _getCategoryIcon(String categoryValue) {
    try {
      final category = categories.firstWhere(
        (cat) => cat['value'] == categoryValue,
      );
      return _getIconForCategory(category['icon'] as String);
    } catch (e) {
      return Icons.category;
    }
  }

  String _getStatusText(Map<String, dynamic> event) {
    // Use EventService to determine if event is finished
    final isFinished = EventService().isFinished(event);
    final status = event['status'] ?? 'scheduled';

    if (isFinished) {
      return 'Finalizado';
    }

    switch (status) {
      case 'live':
        return 'Ao Vivo';
      case 'finished':
        return 'Finalizado';
      case 'scheduled':
      default:
        return 'Agendado';
    }
  }

  Color _getStatusColor(Map<String, dynamic> event) {
    // Use EventService to determine if event is finished
    final isFinished = EventService().isFinished(event);
    final status = event['status'] ?? 'scheduled';

    if (isFinished) {
      return context.customGrey;
    }

    switch (status) {
      case 'live':
        return Theme.of(context).extension<theme.CustomColors>()?.success ??
            Colors.green;
      case 'finished':
        return context.customGrey;
      case 'scheduled':
      default:
        return context.customBlue;
    }
  }

  bool _canEditEvent(Map<String, dynamic> event) {
    if (userRole == 'admin') {
      return true; // Admins can edit all events
    }

    if (userRole == 'speaker' && currentUserName != null) {
      // Speakers can only edit events they are lecturing
      return event['speaker'] == currentUserName;
    }

    return false; // Students cannot edit events
  }

  void _filterEvents() {
    setState(() {
      filteredEvents = events.where((event) {
        final name = (event['name'] ?? '').toString().toLowerCase();
        final description = (event['description'] ?? '')
            .toString()
            .toLowerCase();
        final speaker = (event['speaker'] ?? '').toString().toLowerCase();
        final local = (event['local'] ?? '').toString().toLowerCase();
        final status = event['status'] ?? '';

        // Search filter
        final matchesSearch =
            searchQuery.isEmpty ||
            name.contains(searchQuery.toLowerCase()) ||
            description.contains(searchQuery.toLowerCase()) ||
            speaker.contains(searchQuery.toLowerCase()) ||
            local.contains(searchQuery.toLowerCase());

        // Status filter
        final matchesStatus =
            selectedStatusFilter == 'all' ||
            (selectedStatusFilter == 'finished' &&
                EventService().isFinished(event)) ||
            (selectedStatusFilter == 'scheduled' &&
                !EventService().isFinished(event) &&
                status != 'live') ||
            (selectedStatusFilter == 'live' && status == 'live');

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => EditEventPage(event: event)),
        )
        .then((result) {
          // Reload events if the edit was successful
          if (result == true) {
            _reloadEventsWithRole();
          }
        });
  }

  void _showDeleteConfirmation(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir o evento "${event['name']}"?\n\nEsta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await DatabaseMethods().deleteEvent(
                  event['id'],
                );

                if (success) {
                  Navigator.of(context).pop();
                  _reloadEventsWithRole();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evento excluído com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao excluir evento'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEventFeedback(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _EventFeedbackList(
          eventId: event['id'],
          title: event['name'] ?? 'Evento',
        ),
      ),
    );
  }

  Future<void> _syncEventStatuses() async {
    try {
      setState(() {
        isLoading = true;
      });

      await EventService().syncStatuses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status dos eventos sincronizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload events to show updated statuses
      await _reloadEventsWithRole();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sincronizar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gerenciar Eventos'),
            if (userRole != null)
              Text(
                userRole == 'admin'
                    ? 'Visualizando todos os eventos'
                    : 'Visualizando apenas seus eventos',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          if (userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _syncEventStatuses,
              tooltip: 'Sincronizar status dos eventos',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadEventsWithRole,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: context.customBorder, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // Search section
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar eventos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        Theme.of(
                          context,
                        ).extension<theme.CustomColors>()?.borderColor ??
                        Colors.grey,
                  ),
                  borderRadius: AppBorderRadius.md,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _filterEvents();
              },
            ),
          ),

          // Events list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredEvents.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum evento encontrado',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return Center(
                        child: Card(
                          color: Theme.of(context).cardColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: context.customBorder),
                          ),
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: InkWell(
                            onTap: () {
                              // Optional: Add tap functionality if needed
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // Card Header
                                ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          event['name'] ?? 'Sem nome',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _getStatusColor(event),
                                          ),
                                          color: _getStatusColor(
                                            event,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          _getStatusText(event),
                                          style: TextStyle(
                                            color: _getStatusColor(event),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        event['date'] ?? 'Data não definida',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme
                                              .CustomColors
                                              .light
                                              .highlightedText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme
                                              .CustomColors
                                              .light
                                              .highlightedText,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Text(
                                        event['time'] ?? 'Horário não definido',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme
                                              .CustomColors
                                              .light
                                              .highlightedText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme
                                              .CustomColors
                                              .light
                                              .highlightedText,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Text(
                                        event['local'] ?? 'Local não definido',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme
                                              .CustomColors
                                              .light
                                              .highlightedText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Event details
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        event['description'] ?? 'Sem descrição',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: AppSpacing.sm),
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            event['speaker'] ??
                                                'Palestrante não definido',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: AppSpacing.sm),
                                      Row(
                                        children: [
                                          Icon(
                                            _getCategoryIcon(
                                              event['category'] ?? '',
                                            ),
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            _getCategoryName(
                                              event['category'] ?? '',
                                            ),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: AppSpacing.md),
                                      if (_canEditEvent(event))
                                        IntrinsicHeight(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Theme.of(context)
                                                      .extension<
                                                        theme.CustomColors
                                                      >()
                                                      ?.error,
                                                ),
                                                onPressed: () =>
                                                    _showDeleteConfirmation(
                                                      event,
                                                    ),
                                                tooltip: 'Excluir evento',
                                              ),
                                              VerticalDivider(),
                                              if (userRole == 'admin' ||
                                                  userRole == 'speaker')
                                                IconButton(
                                                  icon: Icon(Icons.feedback),
                                                  onPressed: () =>
                                                      _showEventFeedback(event),
                                                  tooltip:
                                                      'Ver feedback do evento',
                                                ),
                                              VerticalDivider(),
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () =>
                                                    _showEditEventDialog(event),
                                                tooltip: 'Editar evento',
                                              ),
                                            ],
                                          ),
                                        ),

                                      // Feedback button for admins and speakers
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Criar evento'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadEvent()),
        ),
        icon: Icon(Icons.add),
        elevation: 0,
        tooltip: 'Criar evento',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.customBorder, width: 1),
          ),
        ),
        child: BottomAppBar(
          color: Theme.of(context).cardColor,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Status: '),
                SizedBox(width: AppSpacing.sm),
                DropdownButton<String>(
                  value: selectedStatusFilter,
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(
                      value: 'scheduled',
                      child: Text('Agendado'),
                    ),
                    DropdownMenuItem(value: 'live', child: Text('Ao Vivo')),
                    DropdownMenuItem(
                      value: 'finished',
                      child: Text('Finalizado'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatusFilter = value!;
                    });
                    _filterEvents();
                  },
                ),
                const Spacer(),
                if (userRole == 'admin') ...[
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventFeedbackList extends StatelessWidget {
  final String eventId;
  final String title;
  const _EventFeedbackList({required this.eventId, required this.title});

  @override
  Widget build(BuildContext context) {
    final service = FeedbackService();
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback — $title'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: context.customBorder, height: 1.0),
        ),
      ),
      body: StreamBuilder(
        stream: service.watchEventFeedback(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = (snapshot.data as List?) ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('Sem feedbacks ainda.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = items[index];
              return ListTile(
                leading: Icon(Icons.star, color: Colors.amber[700]),
                title: Text('Nota: ${entry.rating}'),
                subtitle: Text(entry.comment ?? '-'),
                dense: true,
              );
            },
          );
        },
      ),
    );
  }
}
