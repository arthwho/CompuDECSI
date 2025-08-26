import 'package:flutter/material.dart';
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/services/category_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Agendado';
      case 'live':
        return 'Ao Vivo';
      case 'finished':
        return 'Finalizado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'live':
        return Colors.green;
      case 'finished':
        return Colors.grey;
      default:
        return Colors.black;
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
            selectedStatusFilter == 'all' || status == selectedStatusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    // Ensure categories are loaded
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carregando categorias...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final nameController = TextEditingController(text: event['name']);
    final descriptionController = TextEditingController(
      text: event['description'],
    );
    final localController = TextEditingController(text: event['local']);
    final speakerController = TextEditingController(
      text: event['speaker'] ?? '',
    );
    final timeController = TextEditingController(text: event['time']);

    // Validate category value exists in categories list
    String? selectedCategory = event['category'];
    if (selectedCategory != null) {
      final categoryExists = categories.any(
        (cat) => cat['value'] == selectedCategory,
      );
      if (!categoryExists) {
        selectedCategory = null; // Reset if category doesn't exist
      }
    }

    String selectedStatus = event['status'] ?? 'scheduled';
    DateTime? selectedDate;

    // Parse the date if it exists
    if (event['date'] != null) {
      try {
        final parts = event['date'].split('/');
        selectedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (e) {
        selectedDate = DateTime.now();
      }
    } else {
      selectedDate = DateTime.now();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Editar Evento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Evento',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: localController,
                      decoration: const InputDecoration(labelText: 'Local'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: speakerController,
                      decoration: const InputDecoration(
                        labelText: 'Palestrante',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Horário (HH:MM)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        'Data: ${selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'Selecione uma data'}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: [
                        // Add a default option if no category is selected
                        if (selectedCategory == null)
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Selecione uma categoria'),
                          ),
                        ...categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['value'] as String,
                            child: Text(category['name'] as String),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: [
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
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        localController.text.isNotEmpty &&
                        selectedDate != null &&
                        selectedCategory != null) {
                      final eventData = {
                        'name': nameController.text,
                        'description': descriptionController.text,
                        'local': localController.text,
                        'speaker': speakerController.text,
                        'time': timeController.text,
                        'date': DateFormat('dd/MM/yyyy').format(selectedDate!),
                        'category': selectedCategory,
                        'status': selectedStatus,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      final success = await DatabaseMethods().updateEvent(
                        event['id'],
                        eventData,
                      );

                      if (success) {
                        Navigator.of(context).pop();
                        _reloadEventsWithRole();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Evento atualizado com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erro ao atualizar evento'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadEventsWithRole,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar eventos...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    _filterEvents();
                  },
                ),
                const SizedBox(height: 12),
                // Status filter
                Row(
                  children: [
                    const Text('Status: '),
                    const SizedBox(width: 8),
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
                  ],
                ),
              ],
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
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            event['name'] ?? 'Sem nome',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                event['description'] ?? 'Sem descrição',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event['local'] ?? 'Local não definido',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${event['date'] ?? 'Data não definida'} às ${event['time'] ?? 'Horário não definido'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.category, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getCategoryName(event['category'] ?? ''),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    event['status'] ?? 'scheduled',
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(
                                    event['status'] ?? 'scheduled',
                                  ),
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      event['status'] ?? 'scheduled',
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: _canEditEvent(event)
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () =>
                                          _showEditEventDialog(event),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _showDeleteConfirmation(event),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
