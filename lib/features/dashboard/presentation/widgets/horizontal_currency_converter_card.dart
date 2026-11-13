import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
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
    _fromCurrency = widget.initialFrom ?? 'USD';
    _toCurrency = widget.initialTo ?? 'TRY';
    if (_fromCurrency == _toCurrency) {
      _toCurrency = _fromCurrency == 'TRY' ? 'EUR' : 'TRY';
    }

    final initialAmt = widget.initialAmount;
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
                  color: const Color(0xFFD97706).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.currency_exchange_rounded,
                  color: Color(0xFFD97706),
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
              const SizedBox(width: 4),
              // Live / Offline Status Pill
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLive
                        ? AppColors.successPastel.withValues(alpha: 0.14)
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isLive ? AppColors.successPastel : theme.colorScheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isLive
                              ? (l10n?.liveRates ?? 'Live Rates')
                              : (l10n?.offlineRates ?? 'Offline'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isLive ? AppColors.successPastel : theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 16),
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
                          if (val != null) setState(() => _fromCurrency = val);
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
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
                        onChanged: (_) => setState(() {}),
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
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    onPressed: _swapCurrencies,
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
                          if (val != null) setState(() => _toCurrency = val);
                        },
                        theme: theme,
                      ),
                      const SizedBox(height: 1),
                      InkWell(
                        onTap: () {
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                                color: theme.colorScheme.primary,
                                letterSpacing: -0.3,
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
          const SizedBox(height: 8),

          // 3. Quick Presets Row & Live Ratio
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _quickPresets.map((preset) {
                      final isSelected = amount == preset;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            _amountController.text = preset.toInt().toString();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark
                                      ? theme.colorScheme.surfaceContainerHighest
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                                width: 0.7,
                              ),
                            ),
                            child: Text(
                              '${CurrencyService.getCurrencySymbol(_fromCurrency)}${preset.toInt()}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Conversion Rate Details
              Flexible(
                child: Text(
                  '1 $_fromCurrency = ${rateFromTo.toStringAsFixed(2)} $_toCurrency',
                  style: AppTheme.monoFont(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
