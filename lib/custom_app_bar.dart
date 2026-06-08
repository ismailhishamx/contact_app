import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget  implements PreferredSizeWidget{
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset('assets/images/logo.png', height: 40, fit: BoxFit.contain),
      backgroundColor: Color(0xff111821),
    );

  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
