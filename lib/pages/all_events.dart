import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/pages/detail_page.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/widgets/event_search_widget.dart';
import 'package:compudecsi/services/category_service.dart';
import 'package:compudecsi/services/event_service.dart';
import 'package:intl/intl.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? eventStream;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allEvents = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredEvents = [];

  // Filter states
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedCategory;
  bool isFilterActive = false;
  bool isFiltersExpanded = false;

  // Categories
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadCategories();
  }

  void _loadEvents() {
    eventStream = FirebaseFirestore.instance.collection('events').snapshots();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await CategoryService.getCategories();
      print('Debug: Loaded ${categoriesData.length} categories from database');
      for (var cat in categoriesData) {
        print('Category: ${cat['name']} (${cat['value']})');
      }

      if (mounted) {
        setState(() {
          categories = categoriesData;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback to default categories
      if (mounted) {
        setState(() {
          categories = [
            {'name': 'Data Science', 'value': 'data_science'},
            {'name': 'Criptografia', 'value': 'cryptography'},
            {'name': 'Robótica', 'value': 'robotics'},
            {'name': 'Inteligência Artificial', 'value': 'ai'},
            {'name': 'Software', 'value': 'software'},
            {'name': 'Computação', 'value': 'computing'},
            {'name': 'Eletrônica', 'value': 'electronics'},
            {'name': 'Telecomunicações', 'value': 'telecom'},
          ];
        });
      }
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
        isFilterActive =
            selectedDate != null ||
            selectedTime != null ||
            selectedCategory != null;
      });
      _applyFilters();
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        selectedTime = time;
        isFilterActive =
            selectedDate != null ||
            selectedTime != null ||
            selectedCategory != null;
      });
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      selectedDate = null;
      selectedTime = null;
      selectedCategory = null;
      isFilterActive = false;
      _filteredEvents = _allEvents;
    });
  }

  void _toggleFilters() {
    setState(() {
      isFiltersExpanded = !isFiltersExpanded;
    });
  }

  void _applyFilters() {
    if (!isFilterActive) {
      _filteredEvents = _allEvents;
      return;
    }

    _filteredEvents = _allEvents.where((doc) {
      final data = doc.data();
      final eventDate = data['date'] as String?;
      final eventTime = data['time'] as String?;
      final eventCategory = data['category'] as String?;

      bool dateMatches = true;
      bool timeMatches = true;
      bool categoryMatches = true;

      // Check date filter
      if (selectedDate != null && eventDate != null) {
        try {
          final parts = eventDate.split('/');
          final eventDateTime = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
          dateMatches =
              eventDateTime.year == selectedDate!.year &&
              eventDateTime.month == selectedDate!.month &&
              eventDateTime.day == selectedDate!.day;
        } catch (e) {
          dateMatches = false;
        }
      }

      // Check time filter
      if (selectedTime != null && eventTime != null) {
        try {
          final timeParts = eventTime.split(':');
          final eventHour = int.parse(timeParts[0]);
          final eventMinute = int.parse(timeParts[1]);
          timeMatches =
              eventHour == selectedTime!.hour &&
              eventMinute == selectedTime!.minute;
        } catch (e) {
          timeMatches = false;
        }
      }

      // Check category filter
      if (selectedCategory != null && eventCategory != null) {
        categoryMatches = eventCategory == selectedCategory;
      }

      return dateMatches && timeMatches && categoryMatches;
    }).toList();
  }

  void _navigateToEventDetails(Map<String, dynamic> data, String docId) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return DetailsPage(
              image: data['image'] ?? '',
              name: data['name'] ?? '',
              local: data['local'] ?? '',
              date: data['date'] ?? '',
              time: data['time'] ?? '',
              description: data['description'] ?? '',
              speaker: data['speaker'] ?? '',
              speakerImage: data['speakerImage'] ?? '',
              eventId: docId,
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir detalhes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Build: categories.length = ${categories.length}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Todas as Palestras'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Search Widget
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.viewPortSide),
            child: EventSearchWidget(
              eventsStream: eventStream!,
              formatFirstAndLastName: formatFirstAndLastName,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Filters Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.viewPortSide),
            child: Column(
              children: [
                // Filter Toggle Button
                InkWell(
                  onTap: _toggleFilters,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 20,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Filtros',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        if (isFilterActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Ativo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        SizedBox(width: 8),
                        Icon(
                          isFiltersExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                // Collapsible Filters Content
                if (isFiltersExpanded) ...[
                  SizedBox(height: 12),
                  Column(
                    children: [
                      // First row: Date and Time filters
                      Row(
                        children: [
                          // Date Filter
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                      color: AppColors.grey,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        selectedDate != null
                                            ? DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(selectedDate!)
                                            : 'Data',
                                        style: TextStyle(
                                          color: selectedDate != null
                                              ? Colors.black
                                              : AppColors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),

                          // Time Filter
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: _selectTime,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 20,
                                      color: AppColors.grey,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        selectedTime != null
                                            ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                            : 'Hora',
                                        style: TextStyle(
                                          color: selectedTime != null
                                              ? Colors.black
                                              : AppColors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Clear Filters Button
                          if (isFilterActive) ...[
                            SizedBox(width: 12),
                            InkWell(
                              onTap: _clearFilters,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.destructive,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Second row: Category filter
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 48, // Match the height of time filter
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.grey,
                            ),
                            hint: Row(
                              children: [
                                Icon(
                                  Icons.category,
                                  size: 20,
                                  color: AppColors.grey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Categoria',
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('Todas as categorias'),
                              ),
                              ...categories.map((category) {
                                print(
                                  'Creating dropdown item: ${category['name']} (${category['value']})',
                                );
                                return DropdownMenuItem<String>(
                                  value: category['value'] as String,
                                  child: Text(category['name'] as String),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                                isFilterActive =
                                    selectedDate != null ||
                                    selectedTime != null ||
                                    selectedCategory != null;
                              });
                              _applyFilters();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Events List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: eventStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: AppColors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma palestra encontrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Update events list
                _allEvents = snapshot.data!.docs;
                if (!isFilterActive) {
                  _filteredEvents = _allEvents;
                } else {
                  _applyFilters();
                }

                if (_filteredEvents.isEmpty && isFilterActive) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_off,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma palestra encontrada\ncom os filtros aplicados',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _clearFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Limpar Filtros'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.viewPortSide,
                  ),
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    final doc = _filteredEvents[index];
                    final data = doc.data();
                    final name = data['name'] ?? 'Sem título';
                    final speaker = data['speaker'] ?? '';
                    final date = data['date'] ?? '';
                    final time = data['time'] ?? '';
                    final local = data['local'] ?? '';
                    final description = data['description'] ?? '';
                    final isFinished = EventService().isFinished(data);

                    return Container(
                      margin: EdgeInsets.only(bottom: 2),
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.border),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _navigateToEventDetails(data, doc.id),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            formatFirstAndLastName(speaker),
                                            style: TextStyle(
                                              color: AppColors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isFinished
                                            ? Colors.grey
                                            : AppColors.accent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isFinished ? 'Finalizada' : 'Agendada',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      date,
                                      style: TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                if (local.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: AppColors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          local,
                                          style: TextStyle(
                                            color: AppColors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (description.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
