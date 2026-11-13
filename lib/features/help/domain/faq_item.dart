import 'package:flutter/material.dart';

/// Domain entity representing a Help & FAQ question and answer item
class FaqItem {
  final String id;
  final String category; // 'general', 'vault', 'budget', 'checklist', 'sync', 'pro', 'account'
  final IconData icon;

  const FaqItem({
    required this.id,
    required this.category,
    required this.icon,
  });
}

