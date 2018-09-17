import 'package:flutter/material.dart';

class Orchestration {
  final int id;
  final bool active;
  final String status;
  final String name;
  final String createdTime;
  final String nextScheduledTime;
  final String lastScheduledTime;

  Orchestration({
    @required this.id,
    @required this.name,
    @required this.active,
    @required this.status,
    @required this.createdTime,
    @required this.nextScheduledTime,
    @required this.lastScheduledTime,
  });
}
