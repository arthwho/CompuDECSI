import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:compudecsi/pages/detail_page.dart';
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:compudecsi/services/shared_pref.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:compudecsi/services/category_service.dart';
import 'package:compudecsi/widgets/event_search_widget.dart';
import 'package:compudecsi/pages/all_events.dart';

class CardInfo {
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
  String selectedEmoji = 'alienMonster'; // Default emoji
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allEvents =
      []; // Store all events for search
  List<CardInfo> categories = []; // Dynamic categories from Firestore

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

  // Filter events to show only upcoming events (from current date and time forward)
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterUpcomingEvents(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> events,
  ) {
    final now = DateTime.now();

    final upcomingEvents = events.where((doc) {
      final data = doc.data();
      final eventDate = data['date'] as String?;
      final eventTime = data['time'] as String?;

      if (eventDate == null || eventTime == null) {
        return false; // Skip events without date or time
      }

      try {
        // Parse event date (dd/MM/yyyy)
        final dateParts = eventDate.split('/');
        if (dateParts.length != 3) return false;

        final eventDay = int.parse(dateParts[0]);
        final eventMonth = int.parse(dateParts[1]);
        final eventYear = int.parse(dateParts[2]);

        // Parse event time (HH:mm)
        final timeParts = eventTime.split(':');
        if (timeParts.length != 2) return false;

        final eventHour = int.parse(timeParts[0]);
        final eventMinute = int.parse(timeParts[1]);

        // Create event DateTime
        final eventDateTime = DateTime(
          eventYear,
          eventMonth,
          eventDay,
          eventHour,
          eventMinute,
        );

        // Return true if event is in the future (including current time)
        return eventDateTime.isAfter(now) ||
            eventDateTime.isAtSameMomentAs(now);
      } catch (e) {
        print('Error parsing event date/time: $e');
        return false; // Skip events with invalid date/time format
      }
    }).toList();

    // Sort upcoming events by date and time (earliest first)
    upcomingEvents.sort((a, b) {
      final dataA = a.data();
      final dataB = b.data();

      final dateA = dataA['date'] as String?;
      final timeA = dataA['time'] as String?;
      final dateB = dataB['date'] as String?;
      final timeB = dataB['time'] as String?;

      if (dateA == null || timeA == null || dateB == null || timeB == null) {
        return 0; // Keep original order if parsing fails
      }

      try {
        // Parse event A date and time
        final datePartsA = dateA.split('/');
        final timePartsA = timeA.split(':');
        final dateTimeA = DateTime(
          int.parse(datePartsA[2]), // year
          int.parse(datePartsA[1]), // month
          int.parse(datePartsA[0]), // day
          int.parse(timePartsA[0]), // hour
          int.parse(timePartsA[1]), // minute
        );

        // Parse event B date and time
        final datePartsB = dateB.split('/');
        final timePartsB = timeB.split(':');
        final dateTimeB = DateTime(
          int.parse(datePartsB[2]), // year
          int.parse(datePartsB[1]), // month
          int.parse(datePartsB[0]), // day
          int.parse(timePartsB[0]), // hour
          int.parse(timePartsB[1]), // minute
        );

        // Sort by DateTime (earliest first)
        return dateTimeA.compareTo(dateTimeB);
      } catch (e) {
        print('Error sorting events: $e');
        return 0; // Keep original order if parsing fails
      }
    });

    return upcomingEvents;
  }

  Future<void> onTheLoad() async {
    eventStream = FirebaseFirestore.instance.collection('events').snapshots();
    userName = await SharedpreferenceHelper().getUserName();
    await fetchCategories();
    await _loadEmojiPreference();

    if (mounted) setState(() {});
  }

  Future<void> _loadEmojiPreference() async {
    final emoji = await SharedpreferenceHelper().getUserEmoji();
    if (emoji != null && emoji.isNotEmpty && mounted) {
      setState(() {
        selectedEmoji = emoji;
      });
    }
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

  Future<void> fetchCategories() async {
    try {
      final categoriesData = await CategoryService.getCategories();
      final List<CardInfo> newCategories = [];

      for (final category in categoriesData) {
        final icon = _getIconForCategory(category['icon'] as String);
        newCategories.add(
          CardInfo(
            category['name'] as String,
            category['value'] as String,
            icon,
          ),
        );
      }

      if (mounted) {
        setState(() {
          categories = newCategories;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      // Fallback to default categories
      if (mounted) {
        setState(() {
          categories = [
            const CardInfo('Data Science', 'data_science', Icons.analytics),
            const CardInfo('Criptografia', 'cryptography', Icons.security),
            const CardInfo('Robótica', 'robotics', Icons.smart_toy),
            const CardInfo('Inteligência Artificial', 'ai', Icons.psychology),
            const CardInfo('Software', 'software', Icons.code),
            const CardInfo('Computação', 'computing', Icons.computer),
            const CardInfo('Eletrônica', 'electronics', Icons.electric_bolt),
            const CardInfo(
              'Telecomunicações',
              'telecom',
              Icons.signal_cellular_alt,
            ),
          ];
        });
      }
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

  String labelFor(String value) {
    return categories
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
      // Keep a single stream of all events; apply filter client-side to
      // tolerate legacy records where 'category' may store the display name.
      eventStream = FirebaseFirestore.instance.collection('events').snapshots();
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

        // Update the all events list for search functionality (keep all events for search)
        _allEvents = snapshot.data!.docs;

        // Filter for upcoming events only (for display in home page)
        List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            _filterUpcomingEvents(snapshot.data!.docs);

        // Apply client-side category filter to handle legacy data where
        // 'category' may contain either the slug value or the display name.
        if (selectedCategoryValue != null) {
          final selectedValue = selectedCategoryValue!;
          // derive display label for fallback comparison
          String? displayLabel;
          try {
            displayLabel = labelFor(selectedValue);
          } catch (_) {
            displayLabel = null;
          }
          String norm(String? s) => (s ?? '').trim().toLowerCase();
          final normValue = norm(selectedValue);
          final normLabel = norm(displayLabel);
          docs = docs.where((d) {
            final data = d.data();
            final stored = norm(data['category']?.toString());
            // Also check alternative legacy keys just in case
            final stored2 = norm(data['categoria']?.toString());
            return stored == normValue ||
                stored == normLabel ||
                stored2 == normValue ||
                stored2 == normLabel;
          }).toList();
        }
        print('Updated _allEvents with ${_allEvents.length} events');
        if (_allEvents.isNotEmpty) {
          print('First event: ${_allEvents.first.data()['name']}');
        }
        if (docs.isEmpty) {
          String message;
          if (selectedCategoryValue != null) {
            message =
                'Nenhuma palestra futura encontrada para "${labelFor(selectedCategoryValue!)}"';
          } else {
            message = 'Nenhuma palestra futura encontrada';
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: AppColors.grey),
                  SizedBox(height: 8),
                  Text(
                    message,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Verifique a página "Todas as Palestras" para ver eventos passados',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
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
                              speakerImage: ds["speakerImage"] ?? '',
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
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                ds["name"] ?? "Sem título",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (FirebaseAuth.instance.currentUser != null)
                              FutureBuilder<bool>(
                                future: DatabaseMethods().isUserEnrolledInEvent(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  ds.id,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data == true) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Inscrito',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                              ),
                          ],
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
                                ds["speakerImage"] != null &&
                                        ds["speakerImage"].toString().isNotEmpty
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          ds["speakerImage"],
                                        ),
                                        radius: 20,
                                      )
                                    : Icon(Icons.account_circle, size: 40),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: AppSpacing.viewPortTop,
            bottom: AppSpacing.viewPortBottom,
          ),
          width: MediaQuery.of(context).size.width,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.viewPortSide,
                ),
                child: Column(
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
                        AnimatedEmoji(
                          _getAnimatedEmoji(selectedEmoji),
                          size: 32,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    EventSearchWidget(
                      eventsStream: eventStream!,
                      formatFirstAndLastName: formatFirstAndLastName,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  padding: EdgeInsets.only(left: AppSpacing.viewPortSide),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final info = categories[index];
                    final isActive = selectedCategoryValue == info.value;
                    print(
                      'Building carousel item: ${info.label} (${info.value}) - Active: $isActive',
                    );
                    return Container(
                      width: 120,
                      margin: EdgeInsets.only(
                        right: index == categories.length - 1
                            ? AppSpacing.viewPortSide
                            : AppSpacing.sm,
                      ),
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
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
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
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.viewPortSide,
                ),
                child: Row(
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllEventsPage(),
                          ),
                        );
                      },
                      child: Text('VER TUDO', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.viewPortSide,
                ),
                child: allEvents(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
