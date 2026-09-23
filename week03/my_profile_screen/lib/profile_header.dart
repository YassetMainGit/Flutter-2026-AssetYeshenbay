import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/my_photo.jpg', width: 220, height: 220),
        Text(name, style: const TextStyle(fontFamily: 'font1', fontSize: 25)),
        Text(university, style: const TextStyle(fontFamily: 'font1', fontSize: 20)),
      ],
    );
  }
}
