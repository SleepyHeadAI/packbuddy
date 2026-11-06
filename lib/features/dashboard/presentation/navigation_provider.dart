import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global active tab index for the root [MainShellScaffold].
/// - 0: Home / Dashboard (Keşif & Özet)
/// - 1: Travel Map (Dünya Haritası)
/// - 2: Baggage & Checklist (Bavul Hazırlığı)
/// - 3: Document Vault (Güvenli Belge Kasası)
/// - 4: Settings (Ayarlar & Tercihler)
final mainNavigationIndexProvider = StateProvider<int>((ref) => 0);

