import 'package:flutter/material.dart';
import '../domain/faq_item.dart';

/// Static catalog of all curated FAQ items in PackBuddy
class FaqData {
  FaqData._();

  static const List<String> categories = [
    'general',
    'vault',
    'budget',
    'checklist',
    'sync',
    'pro',
    'account',
  ];

  static const List<FaqItem> allItems = [
    // General
    FaqItem(
      id: 'whatIsPackBuddy',
      category: 'general',
      icon: Icons.explore_rounded,
    ),
    FaqItem(
      id: 'offlineOperation',
      category: 'general',
      icon: Icons.wifi_off_rounded,
    ),

    // Vault & Security
    FaqItem(
      id: 'vaultPinForgot',
      category: 'vault',
      icon: Icons.lock_reset_rounded,
    ),
    FaqItem(
      id: 'vaultBiometrics',
      category: 'vault',
      icon: Icons.fingerprint_rounded,
    ),
    FaqItem(
      id: 'dataExportPrivacy',
      category: 'vault',
      icon: Icons.security_rounded,
    ),

    // Trips & Budget
    FaqItem(
      id: 'collaborativeTrips',
      category: 'budget',
      icon: Icons.group_rounded,
    ),
    FaqItem(
      id: 'currencyConversion',
      category: 'budget',
      icon: Icons.currency_exchange_rounded,
    ),

    // Packing & Checklist
    FaqItem(
      id: 'smartTemplates',
      category: 'checklist',
      icon: Icons.auto_awesome_rounded,
    ),
    FaqItem(
      id: 'airlineBaggage',
      category: 'checklist',
      icon: Icons.luggage_rounded,
    ),

    // Cloud Sync
    FaqItem(
      id: 'twoWaySync',
      category: 'sync',
      icon: Icons.sync_rounded,
    ),
    FaqItem(
      id: 'multiDeviceAccess',
      category: 'sync',
      icon: Icons.devices_rounded,
    ),

    // PackBuddy Pro
    FaqItem(
      id: 'packBuddyProBenefits',
      category: 'pro',
      icon: Icons.workspace_premium_rounded,
    ),
    FaqItem(
      id: 'restorePurchases',
      category: 'pro',
      icon: Icons.restore_rounded,
    ),

    // Account & Data
    FaqItem(
      id: 'accountDeletion',
      category: 'account',
      icon: Icons.delete_sweep_rounded,
    ),
  ];

  static List<FaqItem> getByCategory(String category) {
    return allItems.where((item) => item.category == category).toList();
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'general':
        return Icons.info_outline_rounded;
      case 'vault':
        return Icons.lock_outline_rounded;
      case 'budget':
        return Icons.wallet_outlined;
      case 'checklist':
        return Icons.checklist_rtl_rounded;
      case 'sync':
        return Icons.cloud_sync_outlined;
      case 'pro':
        return Icons.star_border_rounded;
      case 'account':
        return Icons.person_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

