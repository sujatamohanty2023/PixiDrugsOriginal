import 'dart:ui';

class DashboardCardModel {
  final String title;
  String amount;
  final Color color;

  DashboardCardModel({
    required this.title,
    this.amount='0.0',
    required this.color,
  });
}
