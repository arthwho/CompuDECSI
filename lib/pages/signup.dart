import 'package:compudecsi/utils/variables.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.viewPortSide,
          vertical: 100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Column(
                children: [
                  Text(
                    'Bem-vindo ao',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background gradient image
                      Image.asset(
                        'assets/gradient_radial.png',
                        width: 0,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 300,
                            height: 200,
                            color: Colors.grey[200],
                            child: Center(
                              child: Text('Error loading gradient: $error'),
                            ),
                          );
                        },
                      ),
                      // Foreground compudecsi image
                      Image.asset(
                        'assets/compudecsi.png',
                        width: 300,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text('Error loading compudecsi: $error'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Text(
                    'Acompanhe as palestras e eventos da Semana da Computação no ICEA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Image.asset(
                    'assets/noun.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  // Google Sign-In button removed - now handled in Onboarding
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Use a tela de onboarding para fazer login',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
