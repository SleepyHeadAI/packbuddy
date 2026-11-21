import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/app_widget_service.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';

/// Active, real-time Horizontal Currency Converter Card designed specifically
/// for the PackBuddy Dashboard. Completely responsive and overflow-safe on all screens (even 320px).
class HorizontalCurrencyConverterCard extends StatefulWidget {
  final String? initialFrom;
  final String? initialTo;
  final double initialAmount;

  const HorizontalCurrencyConverterCard({
    super.key,
    this.initialFrom,
    this.initialTo,
    this.initialAmount = 100.0,
  });

  @override
  State<HorizontalCurrencyConverterCard> createState() =>
      _HorizontalCurrencyConverterCardState();
}

class _HorizontalCurrencyConverterCardState
    extends State<HorizontalCurrencyConverterCard>
    with SingleTickerProviderStateMixin {
  late String _fromCurrency;
  late String _toCurrency;
  late TextEditingController _amountController;
  late AnimationController _swapAnimController;
  bool _isRefreshing = false;

  final List<double> _quickPresets = const [10, 50, 100, 250, 500, 1000];

  @override
  void initState() {
    super.initState();
    final savedFrom = PreferencesService.instance.getLastConverterFromCurrency();
    final savedTo = PreferencesService.instance.getLastConverterToCurrency();
    final savedAmt = PreferencesService.instance.getLastConverterAmount();

    _fromCurrency = widget.initialFrom ?? savedFrom;
    _toCurrency = widget.initialTo ?? savedTo;
    if (_fromCurrency == _toCurrency) {
      _toCurrency = _fromCurrency == 'TRY' ? 'EUR' : 'TRY';
    }

    final initialAmt = widget.initialAmount != 100.0 ? widget.initialAmount : savedAmt;
    _amountController = TextEditingController(
      text: (initialAmt % 1 == 0)
          ? initialAmt.toInt().toString()
          : initialAmt.toStringAsFixed(2),
    );

    _swapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  void _persistConverterState() {
    PreferencesService.instance.setLastConverterFromCurrency(_fromCurrency);
    PreferencesService.instance.setLastConverterToCurrency(_toCurrency);
    PreferencesService.instance.setLastConverterAmount(_currentAmount);
    AppWidgetService.syncCurrentState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _swapAnimController.dispose();
    super.dispose();
  }

  void _swapCurrencies() {
    _swapAnimController.forward(from: 0.0);
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _persistConverterState();
  }

  Future<void> _refreshRates() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await CurrencyService.syncRates(force: true);
    } catch (_) {}
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  double get _currentAmount {
    final text = _amountController.text.replaceAll(',', '.').trim();
    return double.tryParse(text) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final amount = _currentAmount;
    final converted = CurrencyService.convert(
      amount: amount,
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
    );

    final rateFromTo = CurrencyService.convert(
      amount: 1.0,
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
    );

    final inverseRate = rateFromTo > 0 ? (1.0 / rateFromTo) : 0.0;
    final inverseFormatted = inverseRate >= 100
        ? inverseRate.toStringAsFixed(1)
        : (inverseRate >= 1 ? inverseRate.toStringAsFixed(2) : inverseRate.toStringAsFixed(4));

    final isLive = CurrencyService.isUsingLiveRates;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Row (Overflow Safe on 320px)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.brandAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  AppIcons.currency,
                  color: isDark ? AppColors.brandAccentDark : AppColors.brandPrimaryLight,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.currencyConverter ?? 'Currency Converter',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              // Live / Offline Status Pill (Optically aligned, intrinsic width)
              Container(
                constraints: const BoxConstraints(maxWidth: 105),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isLive
                      ? AppColors.successPastel.withValues(alpha: 0.12)
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isLive
                        ? AppColors.successPastel.withValues(alpha: 0.25)
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.18),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isLive ? AppColors.successPastel : theme.colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4.5),
                    Flexible(
                      child: Text(
                        isLive
                            ? (l10n?.liveRates ?? 'Live Rates')
                            : (l10n?.offlineRates ?? 'Offline'),
                        style: AppTypography.caption.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isLive ? AppColors.successPastel : theme.colorScheme.onSurfaceVariant,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(AppIcons.refresh, size: 15),
                tooltip: l10n?.refreshRates ?? 'Refresh',
                onPressed: _refreshRates,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Horizontal Conversion Layout (Input [From] <-> Output [To])
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // From Box (Amount & Currency)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCurrencySelector(
                        value: _fromCurrency,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _fromCurrency = val);
                            _persistConverterState();
                          }
                        },
                        theme: theme,
                      ),
                      const SizedBox(height: 1),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
                        ],
                        style: AppTypography.mono(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          tabularFigures: true,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 2),
                          border: InputBorder.none,
                          hintText: '0',
                          prefixText: '${CurrencyService.getCurrencySymbol(_fromCurrency)} ',
                          prefixStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {});
                          _persistConverterState();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Swap Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_swapAnimController),
                  child: IconButton.filledTonal(
                    icon: const Icon(AppIcons.currency, size: 15),
                    onPressed: () {
                      AppHaptics.selection();
                      _swapCurrencies();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(28, 28),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ),

              // To Box (Result & Target Currency)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCurrencySelector(
                        value: _toCurrency,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _toCurrency = val);
                            _persistConverterState();
                          }
                        },
                        theme: theme,
                      ),
                      const SizedBox(height: 1),
                      InkWell(
                        onTap: () {
                          AppHaptics.light();
                          final formatted = CurrencyFormatter.format(converted, currency: _toCurrency);
                          Clipboard.setData(ClipboardData(text: formatted));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n?.amountCopied(formatted) ?? '$formatted copied!'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              CurrencyFormatter.format(converted, currency: _toCurrency),
                              style: AppTypography.mono(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                                letterSpacing: -0.3,
                                tabularFigures: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. Quick Presets Row (Full Width Horizontal Scroll with FAB Clearance)
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 56),
              itemCount: _quickPresets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 5),
              itemBuilder: (context, index) {
                final preset = _quickPresets[index];
                final isSelected = amount == preset;
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    AppHaptics.light();
                    _amountController.text = preset.toInt().toString();
                    setState(() {});
                    _persistConverterState();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark
                              ? AppColors.surfaceRaisedDark
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight),
                        width: 0.6,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${CurrencyService.getCurrencySymbol(_fromCurrency)}${preset.toInt()}',
                        style: AppTypography.mono(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          tabularFigures: true,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // 4. Conversion Rate Info Footer (Balanced 2-column Direct + Inverse rate, eliminating empty void)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight,
                width: 0.6,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Direct Rate (e.g. 1 USD = 50.53 TRY)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.currency,
                        size: 11.5,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '1 $_fromCurrency = ${rateFromTo.toStringAsFixed(2)} $_toCurrency',
                            style: AppTypography.mono(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              tabularFigures: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 12,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight,
                ),
                // Inverse Rate (e.g. 1 TRY = 0.0198 USD)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '1 $_toCurrency = $inverseFormatted $_fromCurrency',
                            style: AppTypography.mono(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              tabularFigures: true,
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
      ),
    );
  }

  Widget _buildCurrencySelector({
    required String value,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        isExpanded: true,
        menuMaxHeight: 360,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14),
        borderRadius: BorderRadius.circular(14),
        selectedItemBuilder: (context) {
          return CurrencyService.supportedCurrencies.map((code) {
            final symbol = CurrencyService.getCurrencySymbol(code);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList();
        },
        items: CurrencyService.supportedCurrencies.map((code) {
          final flag = CurrencyFormatter.getFlag(code);
          final symbol = CurrencyService.getCurrencySymbol(code);
          final name = CurrencyFormatter.getCleanName(code);
          return DropdownMenuItem<String>(
            value: code,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(
                  code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($symbol)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
