import 'package:flutter/material.dart';
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/services/category_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/utils/app_theme.dart';

class EditEventPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController localController;
  late TextEditingController timeController;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> users = [];
  String? selectedCategory;
  String selectedStatus = 'scheduled';
  DateTime? selectedDate;
  TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 0);
  Map<String, dynamic>? selectedSpeaker;
  String? currentUserRole;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCategories();
    _loadUsers();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: widget.event['name']);
    descriptionController = TextEditingController(
      text: widget.event['description'],
    );
    localController = TextEditingController(text: widget.event['local']);

    // Set initial values
    selectedStatus = widget.event['status'] ?? 'scheduled';

    // Parse the date if it exists
    if (widget.event['date'] != null) {
      try {
        final parts = widget.event['date'].split('/');
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

    // Parse the time if it exists
    if (widget.event['time'] != null) {
      try {
        final timeParts = widget.event['time'].split(':');
        if (timeParts.length == 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      } catch (e) {
        selectedTime = TimeOfDay(hour: 10, minute: 0);
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await CategoryService.getCategories();
      print('Debug: Loaded ${categoriesData.length} categories');
      for (var cat in categoriesData) {
        print(
          'Debug: Category - name: "${cat['name']}", value: "${cat['value']}", icon: "${cat['icon']}"',
        );
      }

      setState(() {
        categories = categoriesData;
        // Set the selected category only if it exists in the loaded categories
        final eventCategory = widget.event['category'];
        print('Debug: Event category: "$eventCategory"');

        if (eventCategory != null) {
          final categoryExists = categoriesData.any(
            (cat) => cat['value'] == eventCategory,
          );
          print('Debug: Category exists: $categoryExists');

          if (categoryExists) {
            selectedCategory = eventCategory;
          } else {
            selectedCategory = null;
          }
        } else {
          selectedCategory = null;
        }
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      // Filter users to only include admin and speaker roles, and include document ID
      List<Map<String, dynamic>> allUsers = snapshot.docs
          .map(
            (doc) => {
              ...doc.data() as Map<String, dynamic>,
              'uid': doc.id, // Include the document ID as uid
            },
          )
          .toList();

      List<Map<String, dynamic>> eligibleSpeakers = allUsers.where((user) {
        String? role = user['role'] as String?;
        return role == 'admin' || role == 'speaker';
      }).toList();

      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Find current user in the eligible speakers list
        final currentUserData = eligibleSpeakers.firstWhere(
          (user) => user['uid'] == currentUser.uid,
          orElse: () => <String, dynamic>{},
        );

        // Set current user role
        if (currentUserData.isNotEmpty) {
          currentUserRole = currentUserData['role'] as String?;
        }
      }

      // Set the selected speaker based on the event's speaker name
      final eventSpeakerName = widget.event['speaker'];
      if (eventSpeakerName != null && eventSpeakerName.isNotEmpty) {
        final speakerUser = eligibleSpeakers.firstWhere(
          (user) => user['Name'] == eventSpeakerName,
          orElse: () => <String, dynamic>{},
        );
        if (speakerUser.isNotEmpty) {
          selectedSpeaker = speakerUser;
        }
      }

      setState(() {
        users = eligibleSpeakers;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final eventData = {
        'name': nameController.text,
        'description': descriptionController.text,
        'local': localController.text,
        'speaker': selectedSpeaker != null ? selectedSpeaker!['Name'] : '',
        'speakerImage': selectedSpeaker != null
            ? selectedSpeaker!['Image']
            : '',
        'time': formatTimeOfDay(selectedTime),
        'date': DateFormat('dd/MM/yyyy').format(selectedDate!),
        'category': selectedCategory,
        'status': selectedStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final success = await DatabaseMethods().updateEvent(
        widget.event['id'],
        eventData,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Evento'),
        actions: [
          if (isSaving)
            Padding(
              padding: EdgeInsets.all(AppSpacing.viewPortSide),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: context.customBorder, height: 1.0),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: AppSpacing.viewPortSide,
                  right: AppSpacing.viewPortSide,
                  top: AppSpacing.viewPortSide,
                  bottom: AppSpacing.viewPortBottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Event Name
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Evento *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome do evento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Descrição *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira a descrição do evento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Location
                      TextFormField(
                        controller: localController,
                        decoration: InputDecoration(
                          labelText: 'Local *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o local do evento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Speaker Selection
                      const Text(
                        'Palestrante',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.customBorder),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: currentUserRole == 'speaker'
                            ? // Read-only display for speakers
                              Row(
                                children: [
                                  selectedSpeaker?["Image"] != null &&
                                          selectedSpeaker!["Image"]
                                              .toString()
                                              .isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            selectedSpeaker!["Image"],
                                          ),
                                          radius: 16,
                                        )
                                      : const CircleAvatar(
                                          radius: 16,
                                          child: Icon(Icons.person),
                                        ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      selectedSpeaker?["Name"] ?? "Você",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ],
                              )
                            : // Dropdown for admins
                              DropdownButtonHideUnderline(
                                child: DropdownButton<Map<String, dynamic>>(
                                  isExpanded: true,
                                  value: selectedSpeaker,
                                  items: users.map((user) {
                                    return DropdownMenuItem<
                                      Map<String, dynamic>
                                    >(
                                      value: user,
                                      child: Row(
                                        children: [
                                          user["Image"] != null &&
                                                  user["Image"]
                                                      .toString()
                                                      .isNotEmpty
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                    user["Image"],
                                                  ),
                                                  radius: 16,
                                                )
                                              : const CircleAvatar(
                                                  radius: 16,
                                                  child: Icon(Icons.person),
                                                ),
                                          const SizedBox(width: 10),
                                          Text(user["Name"] ?? "Sem nome"),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSpeaker = value;
                                    });
                                  },
                                  hint: const Text(
                                    'Selecione o palestrante (apenas admins e palestrantes)',
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Date and Time Selection Row
                      Row(
                        children: [
                          // Time Selection
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Horário *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _selectTime,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: context.customBorder,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            formatTimeOfDay(selectedTime),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Date Selection
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Data *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: context.customBorder,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            selectedDate != null
                                                ? DateFormat(
                                                    'dd/MM/yyyy',
                                                  ).format(selectedDate!)
                                                : 'Selecione',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Categoria *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        items: [
                          // Always include a placeholder option
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Selecione uma categoria'),
                          ),
                          // Add all categories
                          ...categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['value'] as String,
                              child: Text(category['name'] as String),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione uma categoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.customBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'scheduled',
                            child: Text('Agendado'),
                          ),
                          DropdownMenuItem(
                            value: 'live',
                            child: Text('Ao Vivo'),
                          ),
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
                      const SizedBox(height: 30),

                      // Save Button
                      FilledButton(
                        onPressed: isSaving ? null : _saveEvent,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSaving
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Salvando...'),
                                ],
                              )
                            : const Text(
                                'Salvar Alterações',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Cancel Button
                      OutlinedButton(
                        onPressed: isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
