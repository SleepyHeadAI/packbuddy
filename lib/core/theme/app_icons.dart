import 'package:flutter/material.dart';

/// Unified iconography dictionary for PackBuddy.
/// Standardizes all icon glyphs across the application to rounded, crisp vector outlines.
///
/// Note on future extensibility: If a third-party vector library (`lucide_icons_flutter` or
/// `phosphor_flutter`) is activated in a future phase, only this dictionary needs to be pointed
/// to the third-party glyphs; caller code remains completely unchanged.
class AppIcons {
  AppIcons._();

  // --- Navigation & Core Shell ---
  static const IconData home = Icons.home_rounded;
  static const IconData homeOutlined = Icons.home_outlined;
  static const IconData map = Icons.public_rounded;
  static const IconData mapOutlined = Icons.public_outlined;
  static const IconData checklist = Icons.checklist_rtl_rounded;
  static const IconData checklistOutlined = Icons.checklist_rounded;
  static const IconData vault = Icons.folder_shared_rounded;
  static const IconData vaultOutlined = Icons.folder_shared_outlined;
  static const IconData settings = Icons.tune_rounded;
  static const IconData settingsOutlined = Icons.tune_outlined;

  // --- Actions & Controls ---
  static const IconData add = Icons.add_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData deleteSweep = Icons.delete_sweep_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData copy = Icons.copy_rounded;
  static const IconData more = Icons.more_horiz_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData chevronLeft = Icons.chevron_left_rounded;
  static const IconData arrowForward = Icons.arrow_forward_rounded;
  static const IconData arrowBack = Icons.arrow_back_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData undo = Icons.undo_rounded;

  // --- Travel & Packing ---
  static const IconData flight = Icons.flight_rounded;
  static const IconData flightTakeoff = Icons.flight_takeoff_rounded;
  static const IconData flightLand = Icons.flight_land_rounded;
  static const IconData luggage = Icons.luggage_rounded;
  static const IconData backpack = Icons.backpack_rounded;
  static const IconData train = Icons.train_rounded;
  static const IconData car = Icons.directions_car_rounded;
  static const IconData boat = Icons.directions_boat_rounded;
  static const IconData hotel = Icons.hotel_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData location = Icons.place_rounded;
  static const IconData globe = Icons.language_rounded;
  static const IconData users = Icons.people_alt_rounded;

  // --- Finance & Budget ---
  static const IconData budget = Icons.account_balance_wallet_rounded;
  static const IconData expense = Icons.receipt_long_rounded;
  static const IconData currency = Icons.currency_exchange_rounded;
  static const IconData trendUp = Icons.trending_up_rounded;
  static const IconData creditCard = Icons.credit_card_rounded;
  static const IconData payments = Icons.payments_rounded;

  // --- Security & Vault ---
  static const IconData lock = Icons.lock_rounded;
  static const IconData lockOpen = Icons.lock_open_rounded;
  static const IconData fingerprint = Icons.fingerprint_rounded;
  static const IconData shield = Icons.shield_rounded;
  static const IconData verified = Icons.verified_user_rounded;
  static const IconData document = Icons.description_rounded;
  static const IconData pdf = Icons.picture_as_pdf_rounded;
  static const IconData photo = Icons.photo_rounded;

  // --- System Status & Feedback ---
  static const IconData info = Icons.info_outline_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData success = Icons.check_circle_outline_rounded;
  static const IconData spark = Icons.auto_awesome_rounded;
  static const IconData cloudSync = Icons.cloud_sync_rounded;
  static const IconData cloudDone = Icons.cloud_done_rounded;
  static const IconData cloudOff = Icons.cloud_off_rounded;
}
