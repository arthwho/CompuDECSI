import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/pages/detail_page.dart';
import 'package:compudecsi/utils/variables.dart';

class EventSearchWidget extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> eventsStream;
  final String hintText;
  final Function(String) formatFirstAndLastName;

  const EventSearchWidget({
    super.key,
    required this.eventsStream,
    this.hintText = 'Buscar palestras',
    required this.formatFirstAndLastName,
  });

  // Method to search events
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _searchEvents(
    String query,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allEvents,
  ) {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    print('Searching for: "$lowercaseQuery"');
    print('Available events: ${allEvents.length}');

    final results = allEvents.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().toLowerCase();
      final speaker = (data['speaker'] ?? '').toString().toLowerCase();
      final description = (data['description'] ?? '').toString().toLowerCase();
      final local = (data['local'] ?? '').toString().toLowerCase();

      final matches =
          name.contains(lowercaseQuery) ||
          speaker.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery) ||
          local.contains(lowercaseQuery);

      if (matches) {
        print('Match found: $name');
      }

      return matches;
    }).toList();

    print('Search results: ${results.length}');
    return results;
  }

  void _navigateToEventDetails(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    try {
      print('Attempting navigation...');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            print('Building DetailsPage...');
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
      print('Navigation successful!');
    } catch (e, stackTrace) {
      print('=== NAVIGATION ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir detalhes: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: eventsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.md,
                    side: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                elevation: WidgetStatePropertyAll(0),
                hintText: 'Carregando...',
                controller: controller,
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (value) {
                  controller.openView();
                },
                leading: const Icon(Icons.search),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
                  return [
                    ListTile(
                      title: Text('Carregando eventos...'),
                      enabled: false,
                    ),
                  ];
                },
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.md,
                    side: BorderSide(color: Colors.grey),
                  ),
                ),
                elevation: WidgetStatePropertyAll(0),
                hintText: hintText,
                controller: controller,
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (value) {
                  controller.openView();
                },
                leading: const Icon(Icons.search),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
                  return [
                    ListTile(
                      title: Text('Nenhum evento disponível'),
                      enabled: false,
                    ),
                  ];
                },
          );
        }

        final allEvents = snapshot.data!.docs;

        return SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.md,
                  side: BorderSide(color: Colors.grey),
                ),
              ),
              elevation: WidgetStatePropertyAll(0),
              hintText: hintText,
              controller: controller,
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onTap: () {
                controller.openView();
              },
              onChanged: (value) {
                controller.openView();
              },
              leading: const Icon(Icons.search),
            );
          },
          suggestionsBuilder: (BuildContext context, SearchController controller) {
            final searchResults = _searchEvents(controller.text, allEvents);
            print('Search query: "${controller.text}"');
            print('Search results count: ${searchResults.length}');
            print('Total events available: ${allEvents.length}');

            if (searchResults.isEmpty && controller.text.isNotEmpty) {
              return [
                ListTile(
                  title: Text(
                    'Nenhuma palestra encontrada para "${controller.text}"',
                  ),
                  enabled: false,
                ),
              ];
            }

            // If search is empty, show all events
            if (searchResults.isEmpty && controller.text.isEmpty) {
              return allEvents.map((doc) {
                final data = doc.data();
                final name = data['name'] ?? 'Sem título';
                final speaker = data['speaker'] ?? '';
                final date = data['date'] ?? '';
                final time = data['time'] ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.btnPrimary,
                    child: Icon(Icons.event, color: Colors.white),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${formatFirstAndLastName(speaker)} • $date • $time',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    print('=== ALL EVENTS RESULT TAPPED ===');
                    print('Event name: $name');
                    print('Event ID: ${doc.id}');
                    print('Event data: $data');

                    // Close the search view first
                    controller.closeView(name);

                    // Use a delayed navigation to ensure the search view is closed
                    Future.delayed(Duration(milliseconds: 100), () {
                      _navigateToEventDetails(context, data, doc.id);
                    });
                  },
                );
              }).toList();
            }

            return searchResults.map((doc) {
              final data = doc.data();
              final name = data['name'] ?? 'Sem título';
              final speaker = data['speaker'] ?? '';
              final date = data['date'] ?? '';
              final time = data['time'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.btnPrimary,
                  child: Icon(Icons.event, color: Colors.white),
                ),
                title: Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${formatFirstAndLastName(speaker)} • $date • $time',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () {
                  print('=== SEARCH RESULT TAPPED ===');
                  print('Event name: ${data['name']}');
                  print('Event ID: ${doc.id}');
                  print('Event data: $data');

                  // Close the search view first
                  controller.closeView(name);

                  // Use a delayed navigation to ensure the search view is closed
                  Future.delayed(Duration(milliseconds: 100), () {
                    _navigateToEventDetails(context, data, doc.id);
                  });
                },
              );
            }).toList();
          },
        );
      },
    );
  }
}
