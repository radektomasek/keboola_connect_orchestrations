import 'package:flutter/material.dart';

class OrchestrationDetail {
  final int id;
  final bool active;
  final String status;
  final String description;
  final String errorMessage;
  final String endTime;

  OrchestrationDetail({
    @required this.id,
    @required this.description,
    @required this.active,
    @required this.status,
    @required this.errorMessage,
    @required this.endTime,
  });
}
