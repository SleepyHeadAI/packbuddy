import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/shared/widgets/app_animations.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/add_packing_item_sheet.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/packing_item_tile.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/smart_templates_sheet.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/airline_guide_sheet.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/checklist_confetti_celebration.dart';
import 'package:packbuddy/features/checklist/domain/canonical_packing_catalog.dart';
import 'package:packbuddy/core/services/share_service.dart';
import 'package:packbuddy/shared/widgets/floating_action_button_location.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';

/// Principal Flutter UI/UX Checklist & Item Completion Tracking Screen
class ChecklistScreen extends ConsumerStatefulWidget {
  final String? tripId;
  final String? tripTitle;
  final bool isTabMode;

  const ChecklistScreen({
    super.key,
    this.tripId,
    this.tripTitle,
    this.isTabMode = true,
  });

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  final GlobalKey _fabKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ChecklistConfettiController _confettiController = ChecklistConfettiController();
  bool _isPackingTipDismissed = false;
  bool _hasCelebratedCurrentList = false;

  final List<String> _categories = [
    'Tümü',
    'Kıyafet',
    'Elektronik',
    'Kişisel Bakım',
    'Belgeler',
    'Aksesuar',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    // Load checklist items for active context (reloads if switched between trips or global)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentActiveTripId = ref.read(checklistControllerProvider).activeTripId;
      if (currentActiveTripId != widget.tripId || ref.read(checklistControllerProvider).items.isEmpty) {
        ref.read(checklistControllerProvider.notifier).loadItems(tripId: widget.tripId);
      }
    });
  }

  @override
  void deactivate() {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    super.deactivate();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getMotivationalProgressText(double ratio, AppLocalizations l10n, String langCode) {
    final lang = langCode.toLowerCase().split('_').first.split('-').first;
    if (ratio >= 1.0) {
      switch (lang) {
        case 'tr': return 'Bavulun tamamen hazır! Harika bir yolculuk seni bekliyor! ✈️✨';
        case 'de': return 'Gepäck ist bereit! Gute Reise! ✈️✨';
        case 'fr': return 'Valise prête ! Bon voyage ! ✈️✨';
        case 'es': return '¡Equipaje listo! ¡Buen viaje! ✈️✨';
        case 'it': return 'Valigia pronta! Buon viaggio! ✈️✨';
        case 'pt': return 'Mala 100% pronta! Tenha uma excelente viagem! ✈️✨';
        case 'ru': return 'Чемодан полностью собран! Отличного путешествия! ✈️✨';
        case 'zh': return '行李已全部收拾完毕！祝您旅途愉快！✈️✨';
        case 'ja': return '荷造り完了！素晴らしいご旅行を！✈️✨';
        case 'ko': return '짐 싸기 완료! 즐거운 여행 되세요! ✈️✨';
        case 'ar': return 'حقيبتك جاهزة تماماً! نتمنى لك رحلة رائعة! ✈️✨';
        case 'hi': return 'बैग पूरी तरह तैयार है! आपकी यात्रा मंगलमय हो! ✈️✨';
        case 'nl': return 'Koffer helemaal ingepakt! Goede reis! ✈️✨';
        case 'el': return 'Όλα έτοιμα στη βαλίτσα! Καλό ταξίδι! ✈️✨';
        case 'sv': return 'Väskan är helt packad! Trevlig resa! ✈️✨';
        case 'pl': return 'Bagaż w pełni spakowany! Udanej podróży! ✈️✨';
        case 'id': return 'Koper sudah siap! Selamat menikmati perjalanan! ✈️✨';
        case 'th': return 'จัดกระเป๋าเสร็จสมบูรณ์แล้ว! ขอให้เดินทางโดยสวัสดิภาพ! ✈️✨';
        case 'vi': return 'Hành lý đã sẵn sàng! Chúc bạn có chuyến đi tuyệt vời! ✈️✨';
        case 'en':
        default: return 'All packed and ready! Have an amazing trip! ✈️✨';
      }
    } else if (ratio >= 0.75) {
      switch (lang) {
        case 'tr': return 'Neredeyse bitti! Son birkaç dokunuş kaldı. 🎒';
        case 'de': return 'Fast geschafft! Nur noch ein paar Dinge. 🎒';
        case 'fr': return 'Presque fini ! Encore quelques détails. 🎒';
        case 'es': return '¡Casi listo! Solo faltan unos toques. 🎒';
        case 'it': return 'Quasi finito! Mancano solo gli ultimi dettagli. 🎒';
        case 'pt': return 'Quase pronto! Faltam apenas alguns detalhes. 🎒';
        case 'ru': return 'Почти готово! Остались последние штрихи. 🎒';
        case 'zh': return '马上完成！只剩最后几样物品了。🎒';
        case 'ja': return 'もうすぐ完了！あと少しで準備完了です。🎒';
        case 'ko': return '거의 다 끝났어요! 마지막 몇 가지만 챙기면 돼요. 🎒';
        case 'ar': return 'شارفت على الانتهاء! لم يتبق سوى القليل. 🎒';
        case 'hi': return 'लगभग पूरा हो गया! बस कुछ आखिरी चीजें बाकी हैं। 🎒';
        case 'nl': return 'Bijna klaar! Nog maar een paar spullen. 🎒';
        case 'el': return 'Σχεδόν έτοιμοι! Έμειναν μόνο λίγες λεπτομέρειες. 🎒';
        case 'sv': return 'Nästan klart! Bara några få saker kvar. 🎒';
        case 'pl': return 'Prawie gotowe! Jeszcze tylko kilka rzeczy. 🎒';
        case 'id': return 'Hampir selesai! Tinggal beberapa barang lagi. 🎒';
        case 'th': return 'ใกล้เสร็จแล้ว! เหลืออีกเพียงไม่กี่ชิ้น 🎒';
        case 'vi': return 'Gần xong rồi! Chỉ còn vài món đồ cuối cùng. 🎒';
        case 'en':
        default: return 'Almost there! Just a few last essentials. 🎒';
      }
    } else if (ratio >= 0.40) {
      switch (lang) {
        case 'tr': return 'Harika gidiyorsun! Valizin yavaş yavaş doluyor. 🧳';
        case 'de': return 'Guter Fortschritt! Koffer füllt sich. 🧳';
        case 'fr': return 'Bonne progression ! La valise se remplit. 🧳';
        case 'es': return '¡Buen progreso! La maleta se está llenando. 🧳';
        case 'it': return 'Ottimo lavoro! La valigia prende forma. 🧳';
        case 'pt': return 'Ótimo progresso! A mala está quase cheia. 🧳';
        case 'ru': return 'Отличный прогресс! Чемодан постепенно заполняется. 🧳';
        case 'zh': return '进展顺利！行李正逐渐准备就绪。🧳';
        case 'ja': return '順調です！スーツケースが埋まってきました。🧳';
        case 'ko': return '아주 잘하고 있어요! 가방이 채워지고 있습니다. 🧳';
        case 'ar': return 'تقدم رائع! حقيبتك تمتلئ تدريجياً. 🧳';
        case 'hi': return 'शानदार प्रगति! बैग धीरे-धीरे भर रहा है। 🧳';
        case 'nl': return 'Goede voortgang! De koffer raakt al lekker vol. 🧳';
        case 'el': return 'Εξαιρετική πρόοδος! Η βαλίτσα γεμίζει. 🧳';
        case 'sv': return 'Bra framsteg! Väskan fylls på. 🧳';
        case 'pl': return 'Świetny postęp! Walizka stopniowo się zapełnia. 🧳';
        case 'id': return 'Kemajuan luar biasa! Koper mulai terisi. 🧳';
        case 'th': return 'คืบหน้าไปได้ดีมาก! กระเป๋าเริ่มเต็มแล้ว 🧳';
        case 'vi': return 'Tiến độ rất tốt! Vali đang dần đầy đủ. 🧳';
        case 'en':
        default: return 'Great progress! Suitcase is coming together. 🧳';
      }
    } else {
      switch (lang) {
        case 'tr': return 'Hazırlıklar başlasın! Valizini adım adım dolduralım. 🗺️';
        case 'de': return 'Packen wir ein! Schritt für Schritt. 🗺️';
        case 'fr': return 'Commençons à faire nos valises ! 🗺️';
        case 'es': return '¡A empacar! Paso a paso. 🗺️';
        case 'it': return 'Iniziamo a fare la valigia! Passo dopo passo. 🗺️';
        case 'pt': return 'Hora de fazer as malas! Passo a passo. 🗺️';
        case 'ru': return 'Начнем сборы! Шаг за шагом заполняем чемодан. 🗺️';
        case 'zh': return '开始收拾吧！一步步装满你的行李箱。🗺️';
        case 'ja': return '荷造りを始めましょう！一歩ずつ準備を進めます。🗺️';
        case 'ko': return '짐 싸기를 시작해볼까요! 차근차근 담아보세요. 🗺️';
        case 'ar': return 'لنبدأ التعبئة! خطوة بخطوة حتى تكتمل الحقيبة. 🗺️';
        case 'hi': return 'पैकिंग शुरू करें! कदम दर कदम बैग भरें। 🗺️';
        case 'nl': return 'Tijd om in te pakken! Stap voor stap. 🗺️';
        case 'el': return 'Ώρα για πακετάρισμα! Βήμα-βήμα γεμίζουμε τη βαλίτσα. 🗺️';
        case 'sv': return 'Dags att packa! Steg för steg. 🗺️';
        case 'pl': return 'Czas się pakować! Krok po kroku uzupełniaj walizkę. 🗺️';
        case 'id': return 'Ayo mulai berkemas! Selangkah demi selangkah. 🗺️';
        case 'th': return 'เริ่มจัดกระเป๋ากันเลย! ทีละขั้นตอน 🗺️';
        case 'vi': return 'Bắt đầu xếp đồ nào! Từng bước lấp đầy vali của bạn. 🗺️';
        case 'en':
        default: return 'Let\'s get packing! Step by step. 🗺️';
      }
    }
  }

  static String _getReadyTitle(String langCode) {
    final lang = langCode.toLowerCase().split('_').first.split('-').first;
    switch (lang) {
      case 'tr': return 'Valizin %100 Hazır! 🎉';
      case 'de': return 'Koffer 100% bereit! 🎉';
      case 'fr': return 'Valise 100% prête ! 🎉';
      case 'es': return '¡Maleta 100% lista! 🎉';
      case 'it': return 'Valigia pronta al 100%! 🎉';
      case 'pt': return 'Mala 100% pronta! 🎉';
      case 'ru': return 'Чемодан готов на 100%! 🎉';
      case 'zh': return '行李已 100% 准备就绪！🎉';
      case 'ja': return '荷造り100%完了！🎉';
      case 'ko': return '가방이 100% 준비되었습니다! 🎉';
      case 'ar': return 'الحقيبة جاهزة 100%! 🎉';
      case 'hi': return 'सूटकेस 100% तैयार है! 🎉';
      case 'nl': return 'Koffer 100% klaar! 🎉';
      case 'el': return 'Βαλίτσα 100% έτοιμη! 🎉';
      case 'sv': return 'Väskan är 100% klar! 🎉';
      case 'pl': return 'Walizka w 100% gotowa! 🎉';
      case 'id': return 'Koper 100% Siap! 🎉';
      case 'th': return 'กระเป๋าพร้อม 100% แล้ว! 🎉';
      case 'vi': return 'Vali đã sẵn sàng 100%! 🎉';
      case 'en':
      default: return 'Suitcase 100% Ready! 🎉';
    }
  }

  static String _getReadySubtitle(String langCode) {
    final lang = langCode.toLowerCase().split('_').first.split('-').first;
    switch (lang) {
      case 'tr': return 'Tüm eşyaların valizde. Gönül rahatlığıyla yola çıkabilirsin!';
      case 'de': return 'Alles eingepackt. Du kannst beruhigt abreisen!';
      case 'fr': return 'Tous vos objets sont emballés. Vous pouvez partir sereinement !';
      case 'es': return 'Todo está empacado. ¡Puedes viajar con total tranquilidad!';
      case 'it': return 'Tutto è pronto. Puoi partire in totale serenità!';
      case 'pt': return 'Tudo embalado. Você está pronto para viajar com tranquilidade!';
      case 'ru': return 'Все вещи собраны. Можете отправляться в путь со спокойной душой!';
      case 'zh': return '所有物品均已打包。您可以安心启程了！';
      case 'ja': return '全ての荷物が揃いました。安心していってらっしゃい！';
      case 'ko': return '모든 물품을 챙겼습니다. 편안한 마음으로 출발하세요!';
      case 'ar': return 'جميع الأغراض جاهزة. يمكنك الانطلاق براحة بال!';
      case 'hi': return 'सभी सामान पैक हो गया है। आप बेफिक्र होकर यात्रा कर सकते हैं!';
      case 'nl': return 'Alles is ingepakt. Je kunt met een gerust hart vertrekken!';
      case 'el': return 'Όλα τα αντικείμενα έχουν συσκευαστεί. Μπορείτε να ταξιδέψετε ήσυχα!';
      case 'sv': return 'Allt är packat. Du kan resa med lugn i sinnet!';
      case 'pl': return 'Wszystkie rzeczy są spakowane. Możesz wyruszać ze spokojną głową!';
      case 'id': return 'Semua barang sudah dikemas. Anda siap berangkat dengan tenang!';
      case 'th': return 'สิ่งของทั้งหมดถูกจัดลงกระเป๋าแล้ว คุณพร้อมเดินทางอย่างสบายใจ!';
      case 'vi': return 'Mọi thứ đã được xếp gọn. Bạn có thể an tâm lên đường!';
      case 'en':
      default: return 'All items are packed. You are ready to travel in peace!';
    }
  }

  void _showUndoDeleteSnackBar(PackingItem item) {
    final l10n = AppLocalizations.of(context)!;
    final localizedName = CanonicalPackingCatalog.getLocalizedItemName(
      item.name,
      Localizations.localeOf(context).languageCode,
    );
    final deletedText = '$localizedName ${l10n.deleted}';
    final undoLabel = l10n.undo;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                deletedText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: undoLabel,
          textColor: const Color(0xFFFDE047),
          onPressed: () {
            ref.read(checklistControllerProvider.notifier).restoreItem(item);
          },
        ),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(milliseconds: 2500),
        persist: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final checklistState = ref.watch(checklistControllerProvider);
    final controller = ref.read(checklistControllerProvider.notifier);

    // Listen to checklist state to trigger confetti celebration on 100% completion
    ref.listen<ChecklistState>(checklistControllerProvider, (previous, next) {
      if (next.totalCount > 0 && next.completionRatio >= 1.0) {
        if (previous == null || previous.completionRatio < 1.0) {
          if (!_hasCelebratedCurrentList) {
            _hasCelebratedCurrentList = true;
            HapticFeedback.heavyImpact();
            Future.delayed(const Duration(milliseconds: 160), () {
              HapticFeedback.mediumImpact();
            });
            _confettiController.burst();
          }
        }
      } else if (next.completionRatio < 1.0) {
        _hasCelebratedCurrentList = false;
      }
    });

    final completionRatio = checklistState.completionRatio;
    final statusColor = completionRatio >= 1.0 && checklistState.totalCount > 0
        ? AppColors.successPastel
        : theme.colorScheme.primary;
    final progressRatio = completionRatio;

    final filteredItems = checklistState.filteredItems;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: !widget.isTabMode && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          titleSpacing: (!widget.isTabMode && Navigator.of(context).canPop()) ? 0 : 16,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.tripTitle == null) ...[
                  if (!widget.isTabMode)
                    Hero(
                      tag: 'checklist-hero-badge',
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.luggage_rounded,
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.luggage_rounded,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                    ),
                ],
                if (!widget.isTabMode)
                  Hero(
                    tag: widget.tripTitle != null
                        ? 'trip-checklist-title-${widget.tripId}'
                        : 'checklist-hero-title',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        widget.tripTitle != null
                            ? '${widget.tripTitle} - ${l10n.luggageAndChecklist}'
                            : l10n.baggageAndChecklist,
                        style: theme.appBarTheme.titleTextStyle ??
                            AppTheme.headlineFont(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: theme.colorScheme.onSurface,
                            ),
                      ),
                    ),
                  )
                else
                  Material(
                    type: MaterialType.transparency,
                    child: Text(
                      widget.tripTitle != null
                          ? '${widget.tripTitle} - ${l10n.luggageAndChecklist}'
                          : l10n.baggageAndChecklist,
                      style: theme.appBarTheme.titleTextStyle ??
                          AppTheme.headlineFont(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            // Collapsible Search Toggle Icon
            IconButton(
              icon: Icon(
                checklistState.isSearchExpanded ? Icons.search_off_rounded : Icons.search_rounded,
                color: checklistState.isSearchExpanded ? theme.colorScheme.primary : null,
              ),
              tooltip: checklistState.isSearchExpanded
                  ? l10n.closeSearch
                  : l10n.searchItems,
              onPressed: () {
                controller.toggleSearchExpanded();
                if (checklistState.isSearchExpanded) {
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                } else {
                  Future.delayed(const Duration(milliseconds: 150), () {
                    _searchFocusNode.requestFocus();
                  });
                }
              },
            ),
            // Smart Packing Templates
            IconButton(
              icon: const Icon(Icons.auto_awesome_rounded),
              tooltip: l10n.readyTemplates,
              onPressed: () => SmartTemplatesSheet.show(context, tripId: widget.tripId),
            ),
            // Social Checklist Share (Feature F-8)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: l10n.shareChecklist,
              onPressed: () {
                ShareService.shareChecklist(
                  tripTitle: widget.tripTitle ?? 'PackBuddy',
                  items: checklistState.items,
                  l10n: l10n,
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          key: _fabKey,
          heroTag: null,
          elevation: 3,
          onPressed: () => QuickActionsSheet.showForChecklist(
            context,
            tripId: widget.tripId,
            tripTitle: widget.tripTitle,
            fabKey: _fabKey,
          ),
          child: const Icon(Icons.add_rounded, size: 26),
        ),
        floatingActionButtonLocation: widget.isTabMode
            ? kFloatingActionButtonAboveFloatingBar
            : FloatingActionButtonLocation.endFloat,
        body: ChecklistConfettiCelebration(
          controller: _confettiController,
          child: SafeArea(
            child: CustomScrollView(
              scrollCacheExtent: const ScrollCacheExtent.pixels(600.0),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // 0. Dopamine Celebration Hero Banner when 100% Packed!
                if (completionRatio >= 1.0 && checklistState.totalCount > 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    const Color(0xFF0F3B36),
                                    const Color(0xFF132A26),
                                  ]
                                : [
                                    const Color(0xFFE6F8F3),
                                    const Color(0xFFF0FDF4),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.45 : 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF34D399), Color(0xFF059669)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getReadyTitle(Localizations.localeOf(context).languageCode),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getReadySubtitle(Localizations.localeOf(context).languageCode),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            BouncyPressable(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                _confettiController.burst();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1A4D45) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 15,
                                      color: Color(0xFF10B981),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '🎉',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 1. Collapsible Instant Search Bar (Animated expansion/collapse)
              SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  child: checklistState.isSearchExpanded
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
                                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (query) => controller.setSearchQuery(query),
                              decoration: InputDecoration(
                                hintText: l10n.searchItemsHint,
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 20),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          controller.setSearchQuery('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              // 2. Item Completion Progress & Overview Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                        width: 1,
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        final langCode = Localizations.localeOf(context).languageCode;
                        final cardTitle = widget.tripTitle != null
                            ? '${widget.tripTitle} • ${l10n.packingReadiness}'
                            : l10n.packingReadiness;

                        String airlineTitle;
                        String airlineSubtitle;

                        if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.none) {
                          airlineTitle = l10n.airlineBaggageLimits;
                          airlineSubtitle = l10n.standardBaggageLimitNote;
                        } else if (checklistState.selectedAirline != null) {
                          final air = checklistState.selectedAirline!;
                          final pkg = air.activePackage;
                          final hasPkg = air.packages.isNotEmpty;
                          final pkgSuffix = hasPkg ? ' • ${pkg.name}' : '';
                          final personalShort = PackingTagHelper.getShortTag('PERSONAL', langCode);
                          final cabinShort = PackingTagHelper.getShortTag('CABIN', langCode);
                          final checkedShort = PackingTagHelper.getShortTag('CHECKED', langCode);

                          final personalStr = pkg.personalItemLimitKg > 0 ? '${pkg.personalItemLimitKg.toInt()} kg' : '-';
                          final cabinStr = pkg.cabinLimitKg > 0 ? '${pkg.cabinLimitKg.toInt()} kg' : '-';
                          final checkedStr = pkg.checkedLimitKg > 0 ? '${pkg.checkedLimitKg.toInt()} kg' : '-';

                          if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.cabinOnly) {
                            airlineTitle = '${air.airlineName}$pkgSuffix ($cabinShort)';
                            airlineSubtitle = '${air.countryFlag} $personalShort: $personalStr • $cabinShort: $cabinStr (${pkg.cabinDimensions})';
                          } else if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.checkedOnly) {
                            airlineTitle = '${air.airlineName}$pkgSuffix ($checkedShort)';
                            airlineSubtitle = '${air.countryFlag} $checkedShort: $checkedStr';
                          } else {
                            airlineTitle = '${air.airlineName}$pkgSuffix';
                            airlineSubtitle = '${air.countryFlag} $personalShort: $personalStr • $cabinShort: $cabinStr • $checkedShort: $checkedStr';
                          }
                        } else {
                          if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.cabinOnly) {
                            airlineTitle = '${l10n.cabinBaggage} (8 kg)';
                            airlineSubtitle = '✈️ 8 kg (55x40x20 cm)';
                          } else if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.checkedOnly) {
                            airlineTitle = '${l10n.checkedBaggage} (20-23 kg)';
                            airlineSubtitle = '✈️ 20-23 kg';
                          } else {
                            airlineTitle = l10n.airlineBaggageLimits;
                            airlineSubtitle = l10n.standardBaggageLimitNote;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Baggage status icon, title, and Dynamic Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.luggage_rounded, color: statusColor, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          cardTitle,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      Text(
                                        checklistState.totalCount == 0
                                            ? l10n.noItemsYet
                                            : '${checklistState.packedCount}/${checklistState.totalCount} ${l10n.itemsReady} • %${(completionRatio * 100).toInt()}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Status badge
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        checklistState.totalCount == 0
                                            ? l10n.listEmpty.toUpperCase()
                                            : (completionRatio >= 1.0
                                                ? l10n.completed.toUpperCase()
                                                : l10n.preparing.toUpperCase()),
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Real-time animated gradient progress bar with glowing tip
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF232D3B) : const Color(0xFFE2E6EC),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final currentWidth = (constraints.maxWidth * progressRatio).clamp(0.0, constraints.maxWidth);
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 350),
                                          curve: Curves.easeOutCubic,
                                          width: currentWidth,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: progressRatio >= 1.0
                                                  ? [const Color(0xFF34D399), const Color(0xFF059669)]
                                                  : [AppColors.primaryAmber, const Color(0xFF0F766E), const Color(0xFF10B981)],
                                            ),
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: statusColor.withValues(alpha: 0.35),
                                                blurRadius: 6,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (currentWidth > 8)
                                          Positioned(
                                            left: currentWidth - 6,
                                            top: -1,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: statusColor.withValues(alpha: 0.6),
                                                    blurRadius: 6,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Dynamic motivational tagline under progress bar
                            Text(
                              _getMotivationalProgressText(completionRatio, l10n, langCode),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 14),

                            // Full-width Airline Baggage Limits & Quick Actions Banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceVariantDark
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.primaryContainerDark
                                              : AppColors.primaryContainerLight.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.flight_takeoff_rounded,
                                          size: 15,
                                          color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              airlineTitle,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.1,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              airlineSubtitle,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w500,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        InkWell(
                                          onTap: () => AirlineGuideSheet.show(context),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.primaryContainerDark
                                                  : AppColors.primaryContainerLight.withValues(alpha: 0.45),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              l10n.set,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => SmartTemplatesSheet.show(context, tripId: widget.tripId),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.secondaryContainerDark
                                                  : AppColors.secondaryContainerLight,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AppColors.secondaryLight,
                                                width: 0.8,
                                              ),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.auto_awesome_rounded,
                                                    size: 11,
                                                    color: AppColors.secondaryLight,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    l10n.readyTemplates,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.secondaryLight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),



              // - Dismissible Inline Smart Packing Tip Banner (Space optimized)
              if (!_isPackingTipDismissed)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.tips_and_updates_rounded,
                            color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.packingTip,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _isPackingTipDismissed = true),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close_rounded, size: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 4. Tactile Baggage Category Selector Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: SizedBox(
                    height: 42,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.03, 0.97, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final categoryLabels = {
                            'Tümü': l10n.allCategories,
                            'Kıyafet': l10n.categoryClothing,
                            'Giyim': l10n.categoryClothing,
                            'Elektronik': l10n.categoryElectronics,
                            'Kişisel Bakım': l10n.categoryToiletries,
                            'Belgeler': l10n.categoryDocuments,
                            'Aksesuar': l10n.categoryAccessories,
                            'Diğer': l10n.other == 'Other' ? 'Others' : l10n.other,
                          };
                          final categoryIcons = {
                            'Tümü': Icons.grid_view_rounded,
                            'Kıyafet': Icons.checkroom_rounded,
                            'Giyim': Icons.checkroom_rounded,
                            'Elektronik': Icons.devices_rounded,
                            'Kişisel Bakım': Icons.spa_rounded,
                            'Belgeler': Icons.description_rounded,
                            'Aksesuar': Icons.watch_rounded,
                            'Diğer': Icons.more_horiz_rounded,
                          };
                          final displayLabel = categoryLabels[category] ?? category;
                          final displayIcon = categoryIcons[category] ?? Icons.category_rounded;
                          final isSelected = (category == 'Tümü' && checklistState.selectedCategory == null) ||
                              (checklistState.selectedCategory == category) ||
                              (checklistState.selectedCategory != null &&
                                  ChecklistState.normalizeCategoryToken(checklistState.selectedCategory!) ==
                                      ChecklistState.normalizeCategoryToken(category));

                          return BouncyPressable(
                            scaleFactor: 0.92,
                            onTap: () {
                              if (isSelected && category != 'Tümü') {
                                controller.setCategoryFilter(null);
                              } else {
                                controller.setCategoryFilter(category == 'Tümü' ? null : category);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : (isDark
                                        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    displayIcon,
                                    size: 15,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    displayLabel,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurface,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Divider(height: 1),
                ),
              ),

              // 5. Checklist Items List with Dismissible Swipe Gestures
              if (checklistState.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: checklistState.searchQuery.isNotEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: 36,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noMatchingItems,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.tryDifferentKeyword,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Layered Travel Suitcase Illustration with Ambient Floating Motion
                                AppFloatingIllustration(
                                  floatDistance: 6.0,
                                  duration: const Duration(milliseconds: 2600),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              theme.colorScheme.primary.withValues(alpha: isDark ? 0.28 : 0.16),
                                              theme.colorScheme.primary.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 76,
                                        height: 76,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: isDark
                                                ? [
                                                    AppColors.primaryContainerDark,
                                                    const Color(0xFF1E2632),
                                                  ]
                                                : [
                                                    AppColors.primaryContainerLight,
                                                    Colors.white,
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.luggage_rounded,
                                            size: 38,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 4,
                                        bottom: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryLight,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark ? AppColors.surfaceDark : Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  l10n.checklistEmpty,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    fontSize: 17,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    l10n.addFirstItem,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                // Action Buttons: Smart Templates & Custom Item
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () => SmartTemplatesSheet.show(context, tripId: widget.tripId),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        foregroundColor: theme.colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        elevation: 2,
                                      ),
                                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                                      label: Text(
                                        l10n.readyTemplates,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => AddPackingItemSheet.show(context, tripId: widget.tripId),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                                      ),
                                      icon: const Icon(Icons.add_rounded, size: 16),
                                      label: Text(
                                        l10n.addItem,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(top: 4, bottom: 112),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredItems[index];
                        return PackingItemTile(
                          item: item,
                          onTap: () => AddPackingItemSheet.show(context, tripId: widget.tripId, itemToEdit: item),
                          onTogglePacked: () => controller.togglePacked(item.id),
                          onUpdateQuantity: (delta) => controller.updateQuantity(item.id, delta),
                          onDelete: () async {
                            final deleted = await controller.deleteItem(item.id);
                            if (deleted != null && mounted) {
                              _showUndoDeleteSnackBar(deleted);
                            }
                          },
                        );
                      },
                      childCount: filteredItems.length,
                      addRepaintBoundaries: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
