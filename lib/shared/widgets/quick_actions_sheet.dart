import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_card.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/presentation/controllers/trip_controller.dart';
import '../../features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import '../../features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import '../../features/checklist/presentation/screens/widgets/add_packing_item_sheet.dart';
import '../../features/vault/presentation/screens/widgets/add_document_sheet.dart';
import '../../features/budget/presentation/screens/widgets/share_trip_sheet.dart';

/// Single action configuration for Quick Actions bottom sheet
class QuickActionItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

/// Modern tactile Quick Actions Bottom Sheet that replaces text-heavy FABs
/// with a sleek, clean single `+` button opening instant contextual options.
class QuickActionsSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<QuickActionItem> items;

  const QuickActionsSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
  });

  /// Displays the QuickActionsSheet in a sleek modal
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<QuickActionItem> items,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          child: SafeArea(
            top: false,
            child: QuickActionsSheet(
              title: title,
              subtitle: subtitle,
              items: items,
            ),
          ),
        ),
      ),
    );
  }

  /// Preset: Quick Actions for Home / Dashboard Screen
  static Future<void> showForDashboard(
    BuildContext context, {
    required WidgetRef ref,
    Trip? activeTrip,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final allTrips = ref.read(tripControllerProvider).trips;

    final items = [
      // 1. Add Trip
      QuickActionItem(
        icon: Icons.flight_takeoff_rounded,
        iconColor: theme.colorScheme.primary,
        iconBgColor: theme.colorScheme.primary.withValues(alpha: 0.15),
        title: l10n.addTrip,
        subtitle: _QuickActionL10n.addTripDesc(lang),
        onTap: () => AddTripSheet.show(context),
      ),
      // 2. Add Expense
      QuickActionItem(
        icon: Icons.receipt_long_rounded,
        iconColor: const Color(0xFF10B981),
        iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.15),
        title: l10n.addExpense,
        subtitle: _QuickActionL10n.addExpenseDesc(lang),
        onTap: () {
          if (allTrips.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.noTripsYet),
                action: SnackBarAction(
                  label: l10n.addTrip,
                  onPressed: () => AddTripSheet.show(context),
                ),
              ),
            );
            return;
          }

          final targetTrip = activeTrip ?? allTrips.first;
          AddExpenseSheet.show(
            context,
            tripId: targetTrip.id,
            defaultCurrency: targetTrip.defaultCurrency,
          );
        },
      ),
      // 3. Add Packing Item
      QuickActionItem(
        icon: Icons.luggage_rounded,
        iconColor: const Color(0xFF6366F1),
        iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
        title: l10n.addItem,
        subtitle: _QuickActionL10n.addItemDesc(lang),
        onTap: () {
          AddPackingItemSheet.show(
            context,
            tripId: activeTrip?.id,
          );
        },
      ),
      // 4. Add Document
      QuickActionItem(
        icon: Icons.note_add_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
        title: l10n.addDocument,
        subtitle: _QuickActionL10n.addDocumentDesc(lang),
        onTap: () {
          AddDocumentSheet.show(
            context,
            initialTripId: activeTrip?.id,
          );
        },
      ),
    ];

    return show(
      context,
      title: l10n.quickActions,
      subtitle: _QuickActionL10n.selectAction(lang),
      items: items,
    );
  }

  /// Preset: Quick Actions for Trips List Screen
  static Future<void> showForTrips(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    final items = [
      QuickActionItem(
        icon: Icons.flight_takeoff_rounded,
        iconColor: theme.colorScheme.primary,
        iconBgColor: theme.colorScheme.primary.withValues(alpha: 0.15),
        title: l10n.addTrip,
        subtitle: _QuickActionL10n.addTripDesc(lang),
        onTap: () => AddTripSheet.show(context),
      ),
      QuickActionItem(
        icon: Icons.group_add_rounded,
        iconColor: const Color(0xFF0D9488),
        iconBgColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
        title: l10n.joinSharedTrip,
        subtitle: _QuickActionL10n.joinTripDesc(lang),
        onTap: () => JoinTripDialog.show(context),
      ),
    ];

    return show(
      context,
      title: l10n.quickActions,
      subtitle: _QuickActionL10n.selectAction(lang),
      items: items,
    );
  }

  /// Preset: Quick Actions for Trip Detail Screen
  static Future<void> showForTripDetail(
    BuildContext context, {
    required Trip trip,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    final items = [
      QuickActionItem(
        icon: Icons.receipt_long_rounded,
        iconColor: const Color(0xFF10B981),
        iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.15),
        title: l10n.addExpense,
        subtitle: _QuickActionL10n.addExpenseDesc(lang),
        onTap: () => AddExpenseSheet.show(
          context,
          tripId: trip.id,
          defaultCurrency: trip.defaultCurrency,
        ),
      ),
      QuickActionItem(
        icon: Icons.luggage_rounded,
        iconColor: const Color(0xFF6366F1),
        iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
        title: l10n.addItem,
        subtitle: _QuickActionL10n.addItemDesc(lang),
        onTap: () => AddPackingItemSheet.show(context, tripId: trip.id),
      ),
      QuickActionItem(
        icon: Icons.note_add_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
        title: l10n.addDocument,
        subtitle: _QuickActionL10n.addDocumentDesc(lang),
        onTap: () => AddDocumentSheet.show(context, initialTripId: trip.id),
      ),
    ];

    return show(
      context,
      title: l10n.quickActions,
      subtitle: _QuickActionL10n.selectAction(lang),
      items: items,
    );
  }

  /// Preset: Quick Actions for Vault Screen
  static Future<void> showForVault(
    BuildContext context, {
    String? selectedTripId,
    String? selectedCategory,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    final items = [
      QuickActionItem(
        icon: Icons.note_add_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
        title: l10n.addDocument,
        subtitle: _QuickActionL10n.addDocumentDesc(lang),
        onTap: () => AddDocumentSheet.show(
          context,
          initialTripId: selectedTripId,
        ),
      ),
      QuickActionItem(
        icon: Icons.add_a_photo_rounded,
        iconColor: const Color(0xFFE11D48),
        iconBgColor: const Color(0xFFE11D48).withValues(alpha: 0.15),
        title: l10n.addPrivatePhoto,
        subtitle: _QuickActionL10n.addPhotoDesc(lang),
        onTap: () => AddDocumentSheet.show(
          context,
          initialTripId: selectedTripId,
          initialCategory: 'PrivatePhotos',
        ),
      ),
    ];

    return show(
      context,
      title: l10n.quickActions,
      subtitle: _QuickActionL10n.selectAction(lang),
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grab Handle
        Center(
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Action Options List
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () {
                Navigator.of(context).pop();
                item.onTap();
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: item.iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Localization helper for Quick Action descriptions across all 20 languages
class _QuickActionL10n {
  _QuickActionL10n._();

  static String selectAction(String lang) {
    switch (lang) {
      case 'tr': return 'Yapmak istediğiniz işlemi seçin';
      case 'es': return 'Selecciona una acción rápida';
      case 'fr': return 'Sélectionnez une action rapide';
      case 'de': return 'Wählen Sie eine Schnellaktion';
      case 'it': return 'Seleziona un\'azione rapida';
      case 'pt': return 'Selecione uma ação rápida';
      case 'ru': return 'Выберите быстрое действие';
      case 'zh': return '选择要执行的快速操作';
      case 'ja': return 'クイック操作を選択';
      case 'ko': return '빠른 작업을 선택하세요';
      case 'ar': return 'اختر إجراءً سريعاً';
      case 'nl': return 'Selecteer een snelle actie';
      case 'el': return 'Επιλέξτε μια γρήγορη ενέργεια';
      case 'sv': return 'Välj en snabbåtgärd';
      case 'pl': return 'Wybierz szybką akcję';
      case 'id': return 'Pilih tindakan cepat';
      case 'th': return 'เลือกการดำเนินการด่วน';
      case 'vi': return 'Chọn một thao tác nhanh';
      case 'hi': return 'त्वरित कार्रवाई चुनें';
      case 'en':
      default:
        return 'Select a quick action';
    }
  }

  static String addTripDesc(String lang) {
    switch (lang) {
      case 'tr': return 'Yeni bir rota ve bütçe planla';
      case 'es': return 'Planifica una nueva ruta y presupuesto';
      case 'fr': return 'Planifiez un nouvel itinéraire et budget';
      case 'de': return 'Neue Route und Budget planen';
      case 'it': return 'Pianifica un nuovo percorso e budget';
      case 'pt': return 'Planeje uma nova rota e orçamento';
      case 'ru': return 'Спланируйте маршрут и бюджет';
      case 'zh': return '规划新路线与旅行预算';
      case 'ja': return '新しいルートと予算を計画';
      case 'ko': return '새로운 경로 및 예산 계획';
      case 'ar': return 'خطط لمسار وميزانية جديدة';
      case 'nl': return 'Plan een nieuwe route en budget';
      case 'el': return 'Σχεδιάστε μια νέα διαδρομή & προϋπολογισμό';
      case 'sv': return 'Planera en ny rutt och budget';
      case 'pl': return 'Zaplanuj nową trasę i budżet';
      case 'id': return 'Rencanakan rute & anggaran baru';
      case 'th': return 'วางแผนเส้นทางและงบประมาณใหม่';
      case 'vi': return 'Lập kế hoạch lộ trình & ngân sách mới';
      case 'hi': return 'नया मार्ग और बजट बनाएं';
      case 'en':
      default:
        return 'Plan a new route & budget';
    }
  }

  static String addExpenseDesc(String lang) {
    switch (lang) {
      case 'tr': return 'Seyahatinize harcama kaydedin';
      case 'es': return 'Registra un gasto en tu viaje';
      case 'fr': return 'Enregistrez une dépense de voyage';
      case 'de': return 'Ausgabe für die Reise erfassen';
      case 'it': return 'Registra una spesa di viaggio';
      case 'pt': return 'Registre uma despesa de viagem';
      case 'ru': return 'Запишите расход в поездке';
      case 'zh': return '记录行程中的旅行支出';
      case 'ja': return '旅行の支出を記録';
      case 'ko': return '여행 지출 기록하기';
      case 'ar': return 'سجل نفقة لرحلتك';
      case 'nl': return 'Registreer een uitgave voor je reis';
      case 'el': return 'Καταγράψτε ένα έξοδο για το ταξίδι σας';
      case 'sv': return 'Logga en utgift för din resa';
      case 'pl': return 'Zarejestruj wydatek na podróż';
      case 'id': return 'Catat pengeluaran untuk perjalanan Anda';
      case 'th': return 'บันทึกค่าใช้จ่ายสำหรับการเดินทาง';
      case 'vi': return 'Ghi lại chi tiêu cho chuyến đi của bạn';
      case 'hi': return 'अपनी यात्रा का खर्च दर्ज करें';
      case 'en':
      default:
        return 'Log an expense for your journey';
    }
  }

  static String addItemDesc(String lang) {
    switch (lang) {
      case 'tr': return 'Bavul kontrol listesine eşya ekleyin';
      case 'es': return 'Añade artículos a la lista de equipaje';
      case 'fr': return 'Ajoutez un article à la valise';
      case 'de': return 'Gegenstand zur Packliste hinzufügen';
      case 'it': return 'Aggiungi articolo alla valigia';
      case 'pt': return 'Adicione itens à lista de bagagem';
      case 'ru': return 'Добавьте вещи в чемодан';
      case 'zh': return '添加物品至行李清单';
      case 'ja': return '荷物チェックリストに追加';
      case 'ko': return '수하물 목록에 물품 추가';
      case 'ar': return 'أضف عنصراً لقائمة الحقيبة';
      case 'nl': return 'Voeg benodigdheden toe aan je paklijst';
      case 'el': return 'Προσθέστε αντικείμενα στη λίστα αποσκευών σας';
      case 'sv': return 'Lägg till saker i din packlista';
      case 'pl': return 'Dodaj rzeczy do listy pakowania';
      case 'id': return 'Tambahkan barang ke daftar bawaan Anda';
      case 'th': return 'เพิ่มสิ่งของลงในรายการจัดกระเป๋า';
      case 'vi': return 'Thêm vật dụng vào danh sách đóng gói';
      case 'hi': return 'अपनी पैकिंग सूची में वस्तुएं जोड़ें';
      case 'en':
      default:
        return 'Add essentials to your packing list';
    }
  }

  static String addDocumentDesc(String lang) {
    switch (lang) {
      case 'tr': return 'Pasaport, bilet veya rezervasyon ekleyin';
      case 'es': return 'Guarda pasaportes, billetes o reservas';
      case 'fr': return 'Enregistrez passeport, billet ou hôtel';
      case 'de': return 'Pass, Ticket oder Buchung sichern';
      case 'it': return 'Salva passaporto, biglietti o hotel';
      case 'pt': return 'Guarde passaporte, bilhetes ou reservas';
      case 'ru': return 'Сохраните паспорт, билет или бронь';
      case 'zh': return '安全保存护照、机票或预订单';
      case 'ja': return 'パスポートやチケットを保管';
      case 'ko': return '여권, 티켓, 예약 내역 보관';
      case 'ar': return 'احفظ الجواز والتذاكر والحجوزات';
      case 'nl': return 'Bewaar paspoort, ticket of reservering';
      case 'el': return 'Αποθηκεύστε διαβατήριο, εισιτήριο ή κράτηση';
      case 'sv': return 'Spara pass, biljett eller bokning';
      case 'pl': return 'Zapisz paszport, bilet lub rezerwację';
      case 'id': return 'Simpan paspor, tiket, atau reservasi';
      case 'th': return 'บันทึกหนังสือเดินทาง ตั๋ว หรือการจอง';
      case 'vi': return 'Lưu hộ chiếu, vé hoặc đặt chỗ';
      case 'hi': return 'पासपोर्ट, टिकट या आरक्षण सहेजें';
      case 'en':
      default:
        return 'Store passport, ticket, or reservation';
    }
  }

  static String joinTripDesc(String lang) {
    switch (lang) {
      case 'tr': return 'Davet koduyla seyahate katılın';
      case 'es': return 'Únete con código de invitación';
      case 'fr': return 'Rejoignez avec un code d\'invitation';
      case 'de': return 'Mit Einladungscode beitreten';
      case 'it': return 'Unisciti con codice di invito';
      case 'pt': return 'Participe com código de convite';
      case 'ru': return 'Присоединиться по коду';
      case 'zh': return '通过邀请码加入共享行程';
      case 'ja': return '招待コードで旅行に参加';
      case 'ko': return '초대 코드로 여행 참여';
      case 'ar': return 'انضم للرحلة برمز الدعوة';
      case 'nl': return 'Deelnemen met een reisuitnodigingscode';
      case 'el': return 'Συμμετοχή με κωδικό πρόσκλησης ταξιδιού';
      case 'sv': return 'Gå med med en inbjudningskod';
      case 'pl': return 'Dołącz za pomocą kodu zaproszenia';
      case 'id': return 'Gabung dengan kode undangan perjalanan';
      case 'th': return 'เข้าร่วมด้วยรหัสเชิญการเดินทาง';
      case 'vi': return 'Tham gia bằng mã mời chuyến đi';
      case 'hi': return 'यात्रा आमंत्रण कोड के साथ जुड़ें';
      case 'en':
      default:
        return 'Join with a trip invite code';
    }
  }

  static String addPhotoDesc(String lang) {
    switch (lang) {
      case 'tr': return 'Kasaya şifreli özel fotoğraf yükleyin';
      case 'es': return 'Añade fotos privadas encriptadas';
      case 'fr': return 'Ajoutez des photos privées chiffrées';
      case 'de': return 'Verschlüsseltes privates Foto sichern';
      case 'it': return 'Aggiungi foto private crittografate';
      case 'pt': return 'Adicione fotos privadas criptografadas';
      case 'ru': return 'Добавьте зашифрованные фото';
      case 'zh': return '加密存储私密旅行照片';
      case 'ja': return '暗号化されたプライベート写真を追加';
      case 'ko': return '암호화된 비공개 사진 추가';
      case 'ar': return 'أضف صوراً خاصة مشفرة';
      case 'nl': return 'Versleutelde privéfoto\'s opslaan';
      case 'el': return 'Αποθηκεύστε κρυπτογραφημένες ιδιωτικές φωτογραφίες';
      case 'sv': return 'Lagra krypterade privata foton';
      case 'pl': return 'Zapisz zaszyfrowane prywatne zdjęcia';
      case 'id': return 'Simpan foto pribadi terenkripsi';
      case 'th': return 'จัดเก็บรูปภาพส่วนตัวที่เข้ารหัส';
      case 'vi': return 'Lưu trữ ảnh riêng tư được mã hóa';
      case 'hi': return 'एन्क्रिप्टेड निजी फ़ोटो सहेजें';
      case 'en':
      default:
        return 'Store encrypted private photos';
    }
  }
}
