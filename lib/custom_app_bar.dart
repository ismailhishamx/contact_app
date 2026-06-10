import 'package:contact/main.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xff111821),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true, // This centers the entire Row below
      title: Row(
        mainAxisSize: MainAxisSize.min, // Shrinks the row to fit its content
        children: [
          // 1. The Logo
          Image.asset('assets/images/logo.png', height: 35, fit: BoxFit.contain),
          
          const SizedBox(width: 20), // Space between Logo and Button
          
          // 2. The Language Button
          GestureDetector(
            onTap: () {
              if (appLocale.value.languageCode == 'ar') {
                appLocale.value = const Locale('en', 'US');
              } else {
                appLocale.value = const Locale('ar', 'AE');
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 1),
                color: Colors.white.withAlpha(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    appLocale.value.languageCode == 'ar' ? 'English' : 'العربية',
                    style: const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w600, 
                      color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
