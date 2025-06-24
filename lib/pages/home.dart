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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 50, left: 20, right: 20),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
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
            SizedBox(height: 10),
            Text(
              'Palestras do CompuDECSI',
              style: TextStyle(
                color: Color(0xff6351ec),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search_outlined),
                  hintText: 'Pesquisar palestras',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: CarouselView.weighted(
                flexWeights: const <int>[7, 6, 7],
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
            SizedBox(height: 15),
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
                Text(
                  'Ver tudo',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Card(
                clipBehavior: Clip.antiAlias, // Clip image to card shape
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'assets/icea.png',
                      height: 200,
                      width:
                          double.infinity, // Image takes full width of the card
                      fit:
                          BoxFit.cover, // Cover the area, cropping if necessary
                    ),
                    const ListTile(
                      title: const Text(
                        'O Impacto da IA no Mercado de Trabalho',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text('23 de Agosto de 2025'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4), // Small vertical spacing
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const Icon(Icons.location_on, size: 18),
                              const SizedBox(width: 8),
                              const Flexible(child: Text('Bloco B, ICEA')),
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
                          onPressed:
                              () {}, // Empty callback as per instructions
                          child: const Text('VER MAIS'),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
