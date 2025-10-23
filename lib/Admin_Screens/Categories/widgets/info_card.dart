import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';


class InfoCard extends StatelessWidget {
final String title;
final String value;
final IconData icon;


const InfoCard({
super.key,
required this.title,
required this.value,
required this.icon,
});


@override
Widget build(BuildContext context) {
return AnimatedContainer(
duration: const Duration(milliseconds: 350),
padding: const EdgeInsets.all(UIConstants.kPadding),
decoration: BoxDecoration(
color: AppColors.infoBg,
borderRadius: BorderRadius.circular(UIConstants.kCardRadius),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.03),
blurRadius: 8,
offset: const Offset(0, 4),
),
],
),
child: Row(
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(title,
style: const TextStyle(
fontSize: 12, fontWeight: FontWeight.w600)),
const SizedBox(height: 6),
Text(value,
style: const TextStyle(
fontSize: 18, fontWeight: FontWeight.w700)),
],
),
),
CircleAvatar(
radius: 20,
backgroundColor: AppColors.purple.withOpacity(0.12),
child: Icon(icon, color: AppColors.purple),
)
],
),
);
}
}