import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Interactive Live Currency Converter Card & Modal
/// Supports all 30 PackBuddy travel currencies with live/offline rates,
/// quick presets, rate inversion, and clipboard copying.
class CurrencyConverterCard extends StatefulWidget {
  final String? initialFromCurrency;
  final String? initialToCurrency;
  final double? initialAmount;
  final bool isModal;

  const CurrencyConverterCard({
    super.key,
    this.initialFromCurrency,
    this.initialToCurrency,
    this.initialAmount,
    this.isModal = false,
  });

  /// Displays the Currency Converter as a modern, compact bottom sheet
  static Future<void> showAsModal(
    BuildContext context, {
    String? initialFromCurrency,
    String? initialToCurrency,
    double? initialAmount,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CurrencyConverterCard(
                    initialFromCurrency: initialFromCurrency,
                    initialToCurrency: initialToCurrency,
                    initialAmount: initialAmount,
                    isModal: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<CurrencyConverterCard> createState() => _CurrencyConverterCardState();
}

class _CurrencyConverterCardState extends State<CurrencyConverterCard>
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
    _fromCurrency = widget.initialFromCurrency ?? 'USD';
    _toCurrency = widget.initialToCurrency ?? 'EUR';
    if (_fromCurrency == _toCurrency) {
      _toCurrency = _fromCurrency == 'EUR' ? 'USD' : 'EUR';
    }
    final initialAmt = widget.initialAmount ?? 100.0;
    _amountController = TextEditingController(
      text: (initialAmt % 1 == 0) ? initialAmt.toInt().toString() : initialAmt.toStringAsFixed(2),
    );
    _swapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
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
    final titleText = l10n?.currencyConverter ?? 'Currency Converter';

    final amount = _currentAmount;
    final converted = CurrencyService.convert(
      amount: amount,
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
    );

    // Rate calculations
    final rateFromTo = CurrencyService.convert(
      amount: 1.0,
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
    );
    final rateToFrom = CurrencyService.convert(
      amount: 1.0,
      fromCurrency: _toCurrency,
      toCurrency: _fromCurrency,
    );

    final isLive = CurrencyService.isUsingLiveRates;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.currency_exchange_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isLive
                        ? (l10n?.liveRates ?? 'Live Rates')
                        : (l10n?.offlineRates ?? 'Offline Baseline'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLive ? AppColors.successPastel : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, size: 20),
              tooltip: l10n?.refreshRates ?? 'Refresh Rates',
              onPressed: _refreshRates,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Currency Selector & Swap Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            ),
          ),
          child: Row(
            children: [
              // From Dropdown
              Expanded(
                child: _buildCurrencyDropdown(
                  value: _fromCurrency,
                  onChanged: (val) {
                    if (val != null) setState(() => _fromCurrency = val);
                  },
                  theme: theme,
                ),
              ),
              // Swap Button
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_swapAnimController),
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                  onPressed: _swapCurrencies,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ),
              // To Dropdown
              Expanded(
                child: _buildCurrencyDropdown(
                  value: _toCurrency,
                  onChanged: (val) {
                    if (val != null) setState(() => _toCurrency = val);
                  },
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Amount Input Field
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
          ],
          decoration: InputDecoration(
            labelText: l10n?.amount ?? 'Amount',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                CurrencyService.getCurrencySymbol(_fromCurrency),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            suffixIcon: _amountController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _amountController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),

        // Quick Preset Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _quickPresets.map((preset) {
              final isSelected = amount == preset;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    '${CurrencyService.getCurrencySymbol(_fromCurrency)}${preset.toInt()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _amountController.text = preset.toInt().toString();
                      setState(() {});
                    }
                  },
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Result Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      theme.colorScheme.primary.withValues(alpha: 0.18),
                      theme.colorScheme.secondary.withValues(alpha: 0.10),
                    ]
                  : [
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                      theme.colorScheme.secondary.withValues(alpha: 0.04),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${CurrencyFormatter.format(amount, currency: _fromCurrency)} =',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      final formatted = CurrencyFormatter.format(converted, currency: _toCurrency);
                      Clipboard.setData(ClipboardData(text: formatted));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$formatted copied!'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CurrencyFormatter.format(converted, currency: _toCurrency),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                height: 12,
              ),
              // Conversion Rate Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '1 $_fromCurrency = ${rateFromTo.toStringAsFixed(4)} $_toCurrency',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '1 $_toCurrency = ${rateToFrom.toStringAsFixed(4)} $_fromCurrency',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.isModal) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
        borderRadius: BorderRadius.circular(16),
        items: CurrencyService.supportedCurrencies.map((code) {
          final symbol = CurrencyService.getCurrencySymbol(code);
          return DropdownMenuItem<String>(
            value: code,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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
