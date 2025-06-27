import 'package:compudecsi/services/auth.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  GestureDetector(
                    onTap: () {
                      AuthMethods().signInWithGoogle(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppBorderRadius.xxl,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/google.png',
                            height: 32,
                            width: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 30,
                                width: 30,
                                color: AppColors.primary,
                                child: Center(
                                  child: Text(
                                    'Error loading Google image: $error',
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Entrar com o Google',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppSize.lg,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
