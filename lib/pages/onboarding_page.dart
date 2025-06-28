import 'package:flutter/material.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/services/auth.dart';
import 'package:compudecsi/utils/widgets.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: PageView.builder(
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingContent(
                      illustration: onboardingData[index]['illustration'],
                      title: onboardingData[index]['title'],
                      text: onboardingData[index]['text'],
                    );
                  },
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    onboardingData.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: AnimatedDot(isActive: _selectedIndex == index),
                    ),
                  ),
                ],
              ),
              Spacer(flex: 2),
              Container(
                width: double.infinity,
                height: 48,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.viewPortSide,
                ),
                child: OutlinedButton(
                  onPressed: () {
                    // For now, just show a message that email login is not implemented
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Login com email será implementado em breve",
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.lightBlue),
                    foregroundColor: AppColors.lightBlue,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email, color: AppColors.lightBlue, size: 24),
                      Expanded(
                        child: Text(
                          'Continuar com o Email'.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 48,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.viewPortSide,
                ),
                child: GoogleSignInButton(
                  onPressed: () {
                    AuthMethods().signInWithGoogle(context);
                  },
                  text: 'Continuar com o Google',
                  backgroundColor: AppColors.lightBlue,
                  height: 48,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedDot extends StatelessWidget {
  const AnimatedDot({super.key, required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 20 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.lightBlue : Color(0xFF868686),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });
  final String illustration;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.viewPortSide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(illustration, width: 310),
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> onboardingData = [
  {
    'illustration': 'assets/compudecsi_onboarding.png',
    'title': 'A 4ª Semana da Computação na sua mão',
    'text': 'Acompanhe as palestras da semana da computação no ICEA',
  },
  {
    'illustration': 'assets/qanda_onboarding.png',
    'title': 'Q&A em tempo real',
    'text': 'Faça perguntas sobre a palestra e aprenda de forma dinâmica',
  },
  {
    'illustration': 'assets/checkin_onboarding.png',
    'title': 'Check-in e comprovante de presença ',
    'text':
        'Faça check-in nas palestras que assistir e ganhe horas complementares!',
  },
];
