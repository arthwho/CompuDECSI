import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compudecsi/admin/admin_panel.dart';
import 'package:compudecsi/pages/detail_page.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:compudecsi/services/shared_pref.dart';
import 'package:animated_emoji/animated_emoji.dart';

enum CardInfo {
  dataScience('Data Science', 'Data Science', Icons.analytics),
  cryptography('Criptografia', 'Criptografia', Icons.security),
  robotics('Robótica', 'Robótica', Icons.smart_toy),
  ai('Inteligência\n Artificial', 'Inteligência Artificial', Icons.psychology),
  software('Software', 'Software', Icons.code),
  computing('Computação', 'Computação', Icons.computer),
  electronics('Eletrônica', 'Eletrônica', Icons.electric_bolt),
  telecom('Redes', 'Redes', Icons.signal_cellular_alt);

  const CardInfo(this.label, this.value, this.icon);
  final String label; // Texto para UI
  final String value; // Valor canônico salvo no Firestore (category)
  final IconData icon;

  final Color color = const Color(0xff841e73);
  final Color backgroundColor = const Color(0xffF9E6F3);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? eventStream;
  String? selectedCategoryValue; // slug canônico (ex.: "ai")
  String? userName;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allEvents =
      []; // Store all events for search

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

  Future<void> onTheLoad() async {
    eventStream = FirebaseFirestore.instance.collection('events').snapshots();
    userName = await SharedpreferenceHelper().getUserName();

    // Debug: Print all valid category values
    print('=== VALID CATEGORY VALUES ===');
    for (final cardInfo in CardInfo.values) {
      print('${cardInfo.label} -> ${cardInfo.value}');
    }

    if (mounted) setState(() {});
  }

  // Method to search events
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _searchEvents(
    String query,
  ) {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    print('Searching for: "$lowercaseQuery"');
    print('Available events: ${_allEvents.length}');

    final results = _allEvents.where((doc) {
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

  String labelFor(String value) {
    return CardInfo.values
        .firstWhere((c) => c.value == value)
        .label
        .replaceAll('\n', ' ');
  }

  void _applyFilter(String? value) {
    print('=== APPLYING FILTER ===');
    print('Current filter: $selectedCategoryValue');
    print('New filter value: $value');

    // If tapping the same category, clear the filter
    if (selectedCategoryValue == value) {
      print('Same category tapped - clearing filter');
      value = null;
    }

    if (value != null) {
      print('Filter label: ${labelFor(value)}');
    }

    setState(() {
      selectedCategoryValue = value;
      eventStream = (value == null)
          ? FirebaseFirestore.instance.collection('events').snapshots()
          : FirebaseFirestore.instance
                .collection('events')
                .where('category', isEqualTo: value)
                .snapshots();
    });

    if (!mounted) return;
    final msg = value == null
        ? 'Filtro limpo: mostrando todas as palestras'
        : 'Filtrando por "${labelFor(value)}"';
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(milliseconds: 900), content: Text(msg)),
    );
  }

  @override
  void initState() {
    onTheLoad();
    super.initState();
  }

  Widget allEvents() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey(selectedCategoryValue ?? 'all'),
      stream: eventStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          final sem = 'Nenhuma palestra encontrada';
          final comp = (selectedCategoryValue != null)
              ? ' para "${labelFor(selectedCategoryValue!)}"'
              : '';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: Text(sem + comp)),
          );
        }

        // Update the all events list for search functionality
        _allEvents = snapshot.data!.docs;
        final docs = snapshot.data!.docs;
        print('Updated _allEvents with ${_allEvents.length} events');
        if (_allEvents.isNotEmpty) {
          print('First event: ${_allEvents.first.data()['name']}');

          // Debug: Print all events and their categories
          print('=== ALL EVENTS DEBUG ===');
          for (int i = 0; i < docs.length; i++) {
            final event = docs[i];
            final data = event.data();
            print(
              'Event ${i + 1}: ${data['name']} - Category: ${data['category']}',
            );
          }
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final ds = docs[index];
            return Center(
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.border),
                ),
                clipBehavior:
                    Clip.antiAlias, // Ensures the image respects card corners
                child: InkWell(
                  onTap: () {
                    print('=== MAIN EVENT CARD TAPPED ===');
                    print('Event name: ${ds["name"]}');
                    print('Event ID: ${ds.id}');

                    try {
                      print('Attempting navigation from main card...');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            print('Building DetailsPage from main card...');
                            return DetailsPage(
                              image: ds["image"] ?? '',
                              name: ds["name"] ?? '',
                              local: ds["local"] ?? '',
                              date: ds["date"] ?? '',
                              time: ds["time"] ?? '',
                              description: ds["description"] ?? '',
                              speaker: ds["speaker"] ?? '',
                              eventId: ds.id,
                            );
                          },
                        ),
                      );
                      print('Navigation from main card successful!');
                    } catch (e, stackTrace) {
                      print('=== MAIN CARD NAVIGATION ERROR ===');
                      print('Error: $e');
                      print('Stack trace: $stackTrace');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao abrir detalhes: $e'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Card Header
                      ListTile(
                        title: Text(
                          ds["name"] ?? "Sem título",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Row(
                          children: [
                            Text(
                              ds["date"],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.btnPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.btnPrimary,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              ds["time"],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.btnPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.btnPrimary,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              ds["local"],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.btnPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Event image
                      // ds["image"] != null &&
                      //         ds["image"].toString().isNotEmpty
                      //     ? Image.network(
                      //         ds["image"],
                      //         height: 200,
                      //         width: double.infinity,
                      //         fit: BoxFit.cover,
                      //       )
                      //     : Image.asset(
                      //         'assets/icea.png',
                      //         height: 200,
                      //         width: double.infinity,
                      //         fit: BoxFit.cover,
                      //       ),
                      // Event details
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                // ds["speakerImage"] != null &&
                                //     ds["speakerImage"].toString().isNotEmpty
                                // ? CircleAvatar(
                                //     backgroundImage: NetworkImage(
                                //       ds["speakerImage"],
                                //     ),
                                //     radius: 20,
                                //   )
                                Icon(Icons.account_circle, size: 40),
                                SizedBox(width: 8),
                                Text(
                                  formatFirstAndLastName(ds["speaker"]),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: AppSpacing.viewPortTop,
            left: AppSpacing.viewPortSide,
            right: AppSpacing.viewPortSide,
            bottom: AppSpacing.viewPortBottom,
          ),
          width: MediaQuery.of(context).size.width,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Olá, ${formatFirstAndLastName(userName)}! ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AnimatedEmoji(AnimatedEmojis.alienMonster, size: 32),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              SearchAnchor(
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
                    hintText: 'Pesquisar palestras',
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
                  final searchResults = _searchEvents(controller.text);
                  print('Search query: "${controller.text}"');
                  print('Search results count: ${searchResults.length}');
                  print('Total events available: ${_allEvents.length}');

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
                    return _allEvents.map((doc) {
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
                                      eventId: doc.id,
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
                                    eventId: doc.id,
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
                        });
                      },
                    );
                  }).toList();
                },
              ),
              SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: CardInfo.values.length,
                  itemBuilder: (context, index) {
                    final info = CardInfo.values[index];
                    final isActive = selectedCategoryValue == info.value;
                    print(
                      'Building carousel item: ${info.label} (${info.value}) - Active: $isActive',
                    );
                    return Container(
                      width: 120,
                      margin: EdgeInsets.only(right: 12),
                      child: Material(
                        elevation: 0,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            print('=== CAROUSEL ITEM TAPPED ===');
                            print('Tapped category: ${info.label}');
                            print('Category value: ${info.value}');
                            _applyFilter(info.value);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: info.backgroundColor,
                              borderRadius: BorderRadius.circular(24),
                              border: isActive
                                  ? Border.all(color: info.color, width: 2)
                                  : null,
                            ),
                            padding: EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(info.icon, color: info.color, size: 32.0),
                                SizedBox(height: 8),
                                Text(
                                  info.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: info.color,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  softWrap: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Próximas palestras',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _applyFilter(null),
                    child: Text('VER TUDO', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              allEvents(),
            ],
          ),
        ),
      ),
      floatingActionButton: currentUser == null
          ? null
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final role = snapshot.data!.data()?['role'] as String?;
                if (role != 'admin') return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminPanel()),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Admin'),
                );
              },
            ),
    );
  }
}
