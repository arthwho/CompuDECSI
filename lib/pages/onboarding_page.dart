import 'dart:math';

import 'package:flutter/material.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/services/auth.dart';
import 'package:compudecsi/utils/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.viewPortBottom),
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
                  Spacer(flex: 2),
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
                  Spacer(),
                  // Container(
                  //   width: double.infinity,
                  //   height: 48,
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: AppSpacing.viewPortSideOnboarding,
                  //   ),
                  //   child: OutlinedButton(
                  //     onPressed: () {
                  //       // For now, just show a message that email login is not implemented
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(
                  //           content: Text(
                  //             "Login com email será implementado em breve",
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //     style: OutlinedButton.styleFrom(
                  //       side: BorderSide(color: AppColors.lightBlue),
                  //       foregroundColor: AppColors.lightBlue,
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.email, color: AppColors.lightBlue, size: 24),
                  //         Expanded(
                  //           child: Text(
                  //             'Continuar com o Email'.toUpperCase(),
                  //             style: TextStyle(
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //             textAlign: TextAlign.center,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  GoogleSignInButton(
                    onPressed: () {
                      AuthMethods().signInWithGoogle(context);
                    },
                    text: 'Continuar com o Google',
                    height: 48,
                    fontSize: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
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
        color: isActive ? AppColors.btnPrimary : Color(0xFF868686),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// Widget to load either SVG or PNG
class FlexibleAssetImage extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FlexibleAssetImage({
    Key? key,
    required this.assetName,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Accepts SVG, PNG, JPG, and GIF
    if (assetName.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetName,
        width: width,
        height: height,
        fit: fit,
      );
    } else if (assetName.toLowerCase().endsWith('.gif') ||
        assetName.toLowerCase().endsWith('.png') ||
        assetName.toLowerCase().endsWith('.jpg') ||
        assetName.toLowerCase().endsWith('.jpeg')) {
      return Image.asset(assetName, width: width, height: height, fit: fit);
    } else {
      // Default fallback
      return SizedBox.shrink();
    }
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.viewPortSideOnboarding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: FlexibleAssetImage(assetName: illustration, width: 310),
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
    'illustration': 'assets/qanda_onboarding.svg',
    'title': 'Q&A em tempo real',
    'text': 'Faça perguntas sobre a palestra e aprenda de forma dinâmica',
  },
  {
    'illustration': 'assets/checkin_onboarding.svg',
    'title': 'Check-in e comprovante de presença ',
    'text':
        'Faça check-in nas palestras que assistir e ganhe horas complementares!',
  },
];

/// 2. ANIMATED BACKGROUND WIDGET
/// This stateless widget builds the background by scattering
/// multiple `FloatingBox` widgets across the screen.
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final random = Random();

    // You can adjust the number of boxes here
    const int boxCount = 20;

    return Container(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: List.generate(boxCount, (index) {
          // Assign random properties to each box
          final size = random.nextDouble() * 80 + 20; // Size between 20 and 100
          final top = random.nextDouble() * screenHeight;
          final left = random.nextDouble() * screenWidth;
          final duration = Duration(
            seconds: random.nextInt(15) + 10,
          ); // Duration between 10 and 25 seconds

          return Positioned(
            top: top,
            left: left,
            child: FloatingBox(size: size, animationDuration: duration),
          );
        }),
      ),
    );
  }
}

/// 3. FLOATING BOX WIDGET
/// This is a stateful widget that represents a single animated square.
/// It manages its own animation controller to create a continuous floating effect.
class FloatingBox extends StatefulWidget {
  final double size;
  final Duration animationDuration;

  const FloatingBox({
    super.key,
    required this.size,
    this.animationDuration = const Duration(seconds: 20),
  });

  @override
  State<FloatingBox> createState() => _FloatingBoxState();
}

class _FloatingBoxState extends State<FloatingBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _yAnimation;
  late final Animation<double> _xAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    final random = Random();

    // Create a vertical floating animation (up and down)
    _yAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: -50.0 - random.nextDouble() * 50),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -50.0 - random.nextDouble() * 50, end: 0),
        weight: 1,
      ),
    ]).animate(_controller);

    // Create a horizontal floating animation (left and right)
    _xAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: 20.0 + random.nextDouble() * 20),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 20.0 + random.nextDouble() * 30, end: 0),
        weight: 1,
      ),
    ]).animate(_controller);

    // Start the animation and repeat it indefinitely
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          // Apply the x and y animations to move the box
          offset: Offset(_xAnimation.value, _yAnimation.value),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(57, 237, 247, 255),
              Color.fromRGBO(224, 231, 237, 0.467),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
