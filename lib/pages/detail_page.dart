import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/utils/widgets.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  String image, name, local, date, time, description, speaker;
  DetailsPage({
    required this.image,
    required this.name,
    required this.local,
    required this.date,
    required this.time,
    required this.description,
    required this.speaker,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: AppSpacing.viewPortSide,
          right: AppSpacing.viewPortSide,
        ),
        child: Column(
          children: [
            Text(widget.name!, style: AppTextStyle.title),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: Colors.black),
                    SizedBox(width: AppSpacing.sm),
                    Text(widget.date!, style: AppTextStyle.body),
                  ],
                ),
                SizedBox(width: AppSpacing.lg),
                Row(
                  children: [
                    Icon(Icons.alarm_on, color: Colors.black),
                    SizedBox(width: AppSpacing.sm),
                    Text(widget.time!, style: AppTextStyle.body),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: AppBorderRadius.md,
              child: Image.asset(
                'assets/icea.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sobre a palestra',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(widget.description!, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.black),
                      SizedBox(width: 5),
                      Text(
                        'Palestrante:',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(width: 5),
                      Text(
                        widget.speaker!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.black),
                      SizedBox(width: 5),
                      Text(
                        'Local:',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(width: 5),
                      Text(
                        widget.local!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: PrimaryButton(
                      text: 'Fazer checkin',
                      onPressed: () {
                        // TODO: Implement checkin functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Checkin realizado com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
