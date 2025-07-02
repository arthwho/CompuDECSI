import 'package:animated_emoji/emojis.g.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/pages/detail_page.dart';
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:compudecsi/services/shared_pref.dart';
import 'package:animated_emoji/animated_emoji.dart';

enum CardInfo {
  dataScience('Data Science', Icons.analytics),
  cryptography('Criptografia', Icons.security),
  robotics('Robótica', Icons.smart_toy),
  ai('Inteligência\n Artificial', Icons.psychology),
  software('Software', Icons.code),
  computing('Computação', Icons.computer),
  electronics('Eletrônica', Icons.electric_bolt),
  telecom('Redes', Icons.signal_cellular_alt);

  const CardInfo(this.label, this.icon);
  final String label;
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
  Stream? eventStream;
  String? userName;

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

  onTheLoad() async {
    eventStream = await DatabaseMethods().getAllEvents();
    userName = await SharedpreferenceHelper().getUserName();
    setState(() {});
  }

  @override
  void initState() {
    onTheLoad();
    super.initState();
  }

  Widget allEvents() {
    return StreamBuilder(
      stream: eventStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return Center(
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.border),
                      ),
                      clipBehavior: Clip
                          .antiAlias, // Ensures the image respects card corners
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                image: ds["image"],
                                name: ds["name"],
                                local: ds["local"],
                                date: ds["date"],
                                time: ds["time"],
                                description: ds["description"],
                                speaker: ds["speaker"],
                                eventId: ds.id,
                              ),
                            ),
                          );
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
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                bottom: 8.0,
                              ),
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
              )
            : Container();
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
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                      return List<ListTile>.generate(5, (int index) {
                        final String item = 'item $index';
                        return ListTile(
                          title: Text(item),
                          onTap: () {
                            setState(() {
                              controller.closeView(item);
                            });
                          },
                        );
                      });
                    },
              ),
              SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: CarouselView.weighted(
                  flexWeights: [1, 1, 1],
                  shrinkExtent: 300,
                  consumeMaxWeight: true,
                  children: CardInfo.values.map((CardInfo info) {
                    return Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: info.backgroundColor,
                          borderRadius: BorderRadius.circular(10),
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
                    );
                  }).toList(),
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
                    onPressed: () {},
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
    );
  }
}
