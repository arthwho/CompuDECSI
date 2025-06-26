import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/pages/detail_page.dart';
import 'package:compudecsi/services/database.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:flutter/material.dart';

enum CardInfo {
  dataScience(
    'Data Science',
    Icons.analytics,
    Color(0xff2354C7),
    Color(0xffECEFFD),
  ),
  cryptography(
    'Criptografia',
    Icons.security,
    Color(0xff806C2A),
    Color(0xffFAEEDF),
  ),
  robotics('Robótica', Icons.smart_toy, Color(0xffA44D2A), Color(0xffFAEDE7)),
  ai(
    'Inteligência\n Artificial',
    Icons.psychology,
    Color(0xff417345),
    Color(0xffE5F4E0),
  ),
  software('Software', Icons.code, Color(0xff2556C8), Color(0xffECEFFD)),
  computing('Computação', Icons.computer, Color(0xff794C01), Color(0xffFAEEDF)),
  electronics(
    'Eletrônica',
    Icons.electric_bolt,
    Color(0xff2251C5),
    Color(0xffECEFFD),
  ),
  telecom(
    'Redes',
    Icons.signal_cellular_alt,
    Color(0xff201D1C),
    Color(0xffE3DFD8),
  );

  const CardInfo(this.label, this.icon, this.color, this.backgroundColor);
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? eventStream;

  onTheLoad() async {
    eventStream = await DatabaseMethods().getAllEvents();
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
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return Center(
                    child: Card(
                      clipBehavior: Clip.antiAlias, // Clip image to card shape
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Image.asset(
                            'assets/icea.png',
                            height: 200,
                            width: double
                                .infinity, // Image takes full width of the card
                            fit: BoxFit
                                .cover, // Cover the area, cropping if necessary
                          ),
                          ListTile(
                            title: Text(ds["name"] ?? "Sem título"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(Icons.calendar_today, size: 18),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        ds["date"] ?? "Data não informada",
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ), // Small vertical spacing
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(Icons.location_on, size: 18),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        ds["local"] ?? "Local não informado",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
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
                                      ),
                                    ),
                                  );
                                }, // Empty callback as per instructions
                                child: const Text('VER MAIS'),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: AppSpacing.viewPortTop,
            left: AppSpacing.viewPortSide,
            right: AppSpacing.viewPortSide,
            bottom: AppSpacing.viewPortBottom,
          ),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, João',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Palestras do CompuDECSI',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.md,
                        side: BorderSide(color: Colors.grey),
                      ),
                    ),
                    elevation: MaterialStatePropertyAll(0),
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
              Text(
                'Categorias',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: CarouselView.weighted(
                  flexWeights: const <int>[7, 7, 7],
                  consumeMaxWeight: false,
                  children: CardInfo.values.map((CardInfo info) {
                    return Container(
                      child: Material(
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
