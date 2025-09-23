import 'dart:ui';

class DashboardCardModel {
  final String title;
  String amount;
  final Color color;
  final  icon;
  final String svgAsset;


  DashboardCardModel({
    required this.title,
    this.amount='0.0',
    required this.color,
    required this.icon,
    required this.svgAsset,
  });
}