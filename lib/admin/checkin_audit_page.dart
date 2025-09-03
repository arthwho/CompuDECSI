import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/admin/qr_scanner_page.dart';
import 'package:intl/intl.dart';

class CheckinAuditPage extends StatefulWidget {
  const CheckinAuditPage({super.key});

  @override
  State<CheckinAuditPage> createState() => _CheckinAuditPageState();
}

class _CheckinAuditPageState extends State<CheckinAuditPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // Helper method to get user name from check-in data
  String _getUserName(Map<String, dynamic> data) {
    return data['userName'] ?? data['name'] ?? 'N/A';
  }

  // Filter check-ins based on search query
  List<QueryDocumentSnapshot> _filterCheckins(
    List<QueryDocumentSnapshot> checkins,
  ) {
    if (searchQuery.isEmpty) return checkins;

    return checkins.where((checkin) {
      final data = checkin.data() as Map<String, dynamic>;
      final userName = _getUserName(data).toLowerCase();
      final eventName = (data['lectureName'] ?? '').toString().toLowerCase();
      final staffName = (data['checkedInBy']?['staffName'] ?? '')
          .toString()
          .toLowerCase();

      return userName.contains(searchQuery.toLowerCase()) ||
          eventName.contains(searchQuery.toLowerCase()) ||
          staffName.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Check-ins'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Por Staff'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome do usuário, evento ou staff...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAllCheckinsTab(), _buildStaffCheckinsTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QRScannerPage()),
          );
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scanner'),
      ),
    );
  }

  Widget _buildStaffCheckinsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseMethods().getAllEventCheckIns(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Nenhum check-in de staff encontrado'),
          );
        }

        final allCheckins = snapshot.data!.docs;
        final filteredCheckins = _filterCheckins(allCheckins);

        if (filteredCheckins.isEmpty && searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum resultado encontrado para "$searchQuery"',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Group by staff member
        Map<String, List<QueryDocumentSnapshot>> staffCheckins = {};
        for (var checkin in filteredCheckins) {
          final data = checkin.data() as Map<String, dynamic>;
          final checkedInBy = data['checkedInBy'] as Map<String, dynamic>?;
          if (checkedInBy != null) {
            final staffId = checkedInBy['staffId'] as String;
            staffCheckins.putIfAbsent(staffId, () => []).add(checkin);
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: staffCheckins.length,
          itemBuilder: (context, index) {
            final staffId = staffCheckins.keys.elementAt(index);
            final staffCheckinsList = staffCheckins[staffId]!;
            final firstCheckin =
                staffCheckinsList.first.data() as Map<String, dynamic>;
            final checkedInBy =
                firstCheckin['checkedInBy'] as Map<String, dynamic>?;
            final staffName = checkedInBy?['staffName'] ?? 'Staff Member';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(staffName),
                subtitle: Text(
                  '${staffCheckinsList.length} check-ins realizados',
                ),
                children: staffCheckinsList.map((checkin) {
                  final data = checkin.data() as Map<String, dynamic>;
                  final checkinTime =
                      data['checkedInBy']?['checkedInAt'] as Timestamp?;

                  return ListTile(
                    title: Text(_getUserName(data)),
                    subtitle: Text(
                      '${data['lectureName'] ?? 'N/A'} - ${data['date'] ?? 'N/A'}',
                    ),
                    trailing: checkinTime != null
                        ? Text(
                            DateFormat('HH:mm').format(checkinTime.toDate()),
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllCheckinsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseMethods().getAllEventCheckIns(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum check-in encontrado'));
        }

        final allCheckins = snapshot.data!.docs;
        final filteredCheckins = _filterCheckins(allCheckins);

        // Sort by most recent check-in time
        filteredCheckins.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aCheckedInBy = aData['checkedInBy'] as Map<String, dynamic>?;
          final bCheckedInBy = bData['checkedInBy'] as Map<String, dynamic>?;
          final aTimestamp = aCheckedInBy?['checkedInAt'] as Timestamp?;
          final bTimestamp = bCheckedInBy?['checkedInAt'] as Timestamp?;

          if (aTimestamp == null && bTimestamp == null) return 0;
          if (aTimestamp == null) return 1;
          if (bTimestamp == null) return -1;

          return bTimestamp.compareTo(aTimestamp); // Most recent first
        });

        if (filteredCheckins.isEmpty && searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum resultado encontrado para "$searchQuery"',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredCheckins.length,
          itemBuilder: (context, index) {
            final checkin =
                filteredCheckins[index].data() as Map<String, dynamic>;
            final checkedInBy = checkin['checkedInBy'] as Map<String, dynamic>?;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (checkin['name'] as String).substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(checkin['name'] ?? 'N/A'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Evento: ${checkin['lectureName'] ?? 'N/A'}'),
                    Text(
                      'Data: ${checkin['date'] ?? 'N/A'} - ${checkin['time'] ?? 'N/A'}',
                    ),
                    if (checkedInBy != null)
                      Text(
                        'Check-in por: ${checkedInBy['staffName'] ?? 'N/A'}',
                      ),
                  ],
                ),
                trailing:
                    checkedInBy != null && checkedInBy['checkedInAt'] != null
                    ? Text(
                        DateFormat('HH:mm').format(
                          (checkedInBy['checkedInAt'] as Timestamp).toDate(),
                        ),
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
