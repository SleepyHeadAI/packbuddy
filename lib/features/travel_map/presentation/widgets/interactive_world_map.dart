import 'package:flutter/material.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/country_flag.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'globe_3d_viewer.dart';

/// Interactive vector-based World Travel Map widget with direct country polygon coloring,
/// 2D / 3D Globe mode toggle, single-finger panning, pinch-to-zoom, and Cyprus/Kosovo support.
class InteractiveWorldMap extends StatefulWidget {
  final List<TravelCountry> countries;
  final ValueChanged<TravelCountry> onCountryTap;
  final ValueChanged<bool>? onMapInteracting;
  final bool? is3DMode;
  final ValueChanged<bool>? onToggle3DMode;

  const InteractiveWorldMap({
    super.key,
    required this.countries,
    required this.onCountryTap,
    this.onMapInteracting,
    this.is3DMode,
    this.onToggle3DMode,
  });

  @override
  State<InteractiveWorldMap> createState() => _InteractiveWorldMapState();
}

class _InteractiveWorldMapState extends State<InteractiveWorldMap> {
  final TransformationController _transformController = TransformationController();
  late bool _is3DMode; // Toggle between 2D flat projection and 3D globe
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _is3DMode = widget.is3DMode ?? PreferencesService.instance.getTravelMapIs3D();
  }

  @override
  void didUpdateWidget(covariant InteractiveWorldMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.is3DMode != null && widget.is3DMode != _is3DMode) {
      _is3DMode = widget.is3DMode!;
    }
  }

  void _set3DMode(bool value) {
    if (_is3DMode != value) {
      setState(() {
        _is3DMode = value;
      });
      PreferencesService.instance.setTravelMapIs3D(value);
      widget.onToggle3DMode?.call(value);
    }
  }

  void _setInteracting(bool val) {
    if (_isInteracting != val) {
      setState(() {
        _isInteracting = val;
      });
      widget.onMapInteracting?.call(val);
    }
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
    setState(() {});
  }

  void _zoomBy(double factor) {
    final matrix = _transformController.value.clone();
    final currentScale = matrix.storage[0];
    final newScale = (currentScale * factor).clamp(1.0, 8.0);
    final effectiveFactor = newScale / currentScale;
    if ((effectiveFactor - 1.0).abs() < 0.001) return;

    final focalX = (context.size?.width ?? 350.0) / 2.0;
    const focalY = 390.0 / 2.0;

    final translation = Matrix4.translationValues(focalX, focalY, 0.0);
    final scale = Matrix4.diagonal3Values(effectiveFactor, effectiveFactor, 1.0);
    final invTranslation = Matrix4.translationValues(-focalX, -focalY, 0.0);

    _transformController.value = translation * scale * invTranslation * matrix;
  }

  void _zoomIn() => _zoomBy(1.35);
  void _zoomOut() => _zoomBy(0.74);

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _handleCountryTap(String id, String name) {
    final cleanId = id.toUpperCase().trim();

    // Prevent ocean or non-country background clicks from showing an empty or 'Dünya' popup
    if (cleanId.isEmpty ||
        cleanId == 'WORLD' ||
        cleanId == 'SIMPLE WIDGETS' ||
        cleanId == 'OCEAN' ||
        cleanId.length < 2) {
      return;
    }

    // Cyprus Disambiguation: allow user to choose North Cyprus or South Cyprus
    if (cleanId == 'CY') {
      _showCyprusDisambiguationSheet();
      return;
    }

    TravelCountry? matched = widget.countries
        .where((c) => c.code.toUpperCase() == cleanId)
        .firstOrNull;

    matched ??= WorldCountriesData.allCountries
        .where((c) => c.code.toUpperCase() == cleanId)
        .firstOrNull;

    if (matched == null && name.isNotEmpty) {
      matched = WorldCountriesData.matchCountry(name);
    }

    matched ??= WorldCountriesData.matchCountry(cleanId);

    if (matched != null) {
      final userSaved = widget.countries
          .where((c) => c.code.toUpperCase() == matched!.code.toUpperCase())
          .firstOrNull;
      if (userSaved != null) {
        matched = userSaved;
      }
    }

    if (matched == null && cleanId.length == 2) {
      matched = TravelCountry(
        code: cleanId,
        nameTr: name.isNotEmpty ? name : cleanId,
        nameEn: name.isNotEmpty ? name : cleanId,
        flag: _getFlagEmoji(cleanId),
        continent: 'Asia',
        capital: '',
        latitude: 0,
        longitude: 0,
      );
    }

    if (matched == null) {
      return; // Not a recognized country
    }

    widget.onCountryTap(matched);
  }

  static String _getFlagEmoji(String countryCode) {
    if (countryCode == 'NC') return '🇹🇷';
    return countryCode
        .toUpperCase()
        .runes
        .map((r) => 0x1F1E6 + (r - 0x41))
        .map(String.fromCharCode)
        .join();
  }

  void _showCyprusDisambiguationSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final northCyprus = widget.countries.where((c) => c.code == 'NC').firstOrNull ??
        WorldCountriesData.allCountries.firstWhere((c) => c.code == 'NC');
    final southCyprus = widget.countries.where((c) => c.code == 'CY').firstOrNull ??
        WorldCountriesData.allCountries.firstWhere((c) => c.code == 'CY');

    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context).languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.cyprusRegion,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                // North Cyprus Option
                _buildCyprusOptionTile(
                  country: northCyprus,
                  theme: theme,
                  isDark: isDark,
                  l10n: l10n,
                  currentLocale: currentLocale,
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onCountryTap(northCyprus);
                  },
                ),
                const SizedBox(height: 8),
                // South Cyprus Option
                _buildCyprusOptionTile(
                  country: southCyprus,
                  theme: theme,
                  isDark: isDark,
                  l10n: l10n,
                  currentLocale: currentLocale,
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onCountryTap(southCyprus);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCyprusOptionTile({
    required TravelCountry country,
    required ThemeData theme,
    required bool isDark,
    required AppLocalizations l10n,
    required String currentLocale,
    required VoidCallback onTap,
  }) {
    Color? statusColor;
    String? statusLabel;
    if (country.isLived) {
      statusColor = const Color(0xFF10B981);
      statusLabel = l10n.mapLegendLived;
    } else if (country.isVisited) {
      statusColor = const Color(0xFFEA580C);
      statusLabel = l10n.mapLegendBeen;
    } else if (country.isWishlist) {
      statusColor = const Color(0xFFEF4444);
      statusLabel = l10n.mapLegendWant;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor ?? (isDark ? Colors.white12 : Colors.black12),
            width: statusColor != null ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            CountryFlag(code: country.code, fallbackEmoji: country.flag, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.getLocalizedName(currentLocale),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    '${country.continent} • ${country.capital}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (statusLabel != null && statusColor != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Build the dynamic country polygon color mapping (Lived: Green, Been: Orange, Skratch: Coral Red)
    final colorMap = <String, Color>{};
    for (final country in widget.countries) {
      final code = country.code.toLowerCase().trim();
      if (country.isLived) {
        colorMap[code] = const Color(0xFF10B981);
      } else if (country.isVisited) {
        colorMap[code] = const Color(0xFFEA580C);
      } else if (country.isWishlist) {
        colorMap[code] = const Color(0xFFEF4444);
      }
    }

    // Also map Northern Cyprus color onto Cyprus polygon if set
    final nc = widget.countries.where((c) => c.code == 'NC').firstOrNull;
    if (nc != null && (colorMap['cy'] == null || nc.isLived || nc.isVisited)) {
      if (nc.isLived) {
        colorMap['cy'] = const Color(0xFF10B981);
      } else if (nc.isVisited) {
        colorMap['cy'] = const Color(0xFFEA580C);
      } else if (nc.isWishlist && colorMap['cy'] == null) {
        colorMap['cy'] = const Color(0xFFEF4444);
      }
    }

    final unvisitedLandColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final borderColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final oceanColor = isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        color: oceanColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _setInteracting(true),
          onPointerUp: (_) => _setInteracting(false),
          onPointerCancel: (_) => _setInteracting(false),
          child: Stack(
            children: [
              // Active Map View: 3D Globe or 2D Interactive Map
              if (_is3DMode)
                Globe3DViewer(
                  countries: widget.countries,
                  onCountryTap: (country) => _handleCountryTap(country.code, country.nameEn),
                  onInteracting: _setInteracting,
                  isDark: isDark,
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 390,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 1.0,
                        maxScale: 8.0,
                        panAxis: PanAxis.free,
                        boundaryMargin: const EdgeInsets.symmetric(horizontal: 160, vertical: 120),
                        onInteractionStart: (_) => _setInteracting(true),
                        onInteractionEnd: (_) => _setInteracting(false),
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: 390,
                          child: SimpleMap(
                            instructions: SMapWorld.instructions,
                            defaultColor: unvisitedLandColor,
                            colors: colorMap,
                            countryBorder: CountryBorder(
                              color: borderColor,
                              width: 0.65,
                            ),
                            fit: BoxFit.contain,
                            callback: (id, name, tapDetails) {
                              _handleCountryTap(id, name);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

            // Top-Left: 2D / 3D Mode Toggle Switcher
            Positioned(
              top: 12,
              left: 14,
              child: AnimatedOpacity(
                opacity: _isInteracting ? 0.06 : 0.84,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: _isInteracting,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _set3DMode(false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: !_is3DMode
                                  ? const Color(0xFFEA580C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '🗺️ 2D',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: !_is3DMode ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        GestureDetector(
                          onTap: () => _set3DMode(true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _is3DMode
                                  ? const Color(0xFF0284C7)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '🌐 ${l10n?.globe3D ?? "3D Globe"}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: _is3DMode ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top-Right: Zoom Controls (Only in 2D mode)
            if (!_is3DMode)
              Positioned(
                top: 12,
                right: 14,
                child: AnimatedOpacity(
                  opacity: _isInteracting ? 0.06 : 0.84,
                  duration: const Duration(milliseconds: 180),
                  child: IgnorePointer(
                    ignoring: _isInteracting,
                    child: Container(
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Builder(
                        builder: (ctx) {
                          final l10n = AppLocalizations.of(ctx);
                          final zoomInTooltip = l10n?.zoomIn ?? 'Zoom In';
                          final zoomOutTooltip = l10n?.zoomOut ?? 'Zoom Out';
                          final resetTooltip = l10n?.resetZoom ?? 'Reset';

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_rounded, size: 18),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                tooltip: zoomInTooltip,
                                onPressed: _zoomIn,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: isDark ? Colors.white10 : Colors.black12,
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_rounded, size: 18),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                tooltip: zoomOutTooltip,
                                onPressed: _zoomOut,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: isDark ? Colors.white10 : Colors.black12,
                              ),
                              IconButton(
                                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                tooltip: resetTooltip,
                                onPressed: _resetZoom,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Center: Floating Pill & Color Legend
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: AnimatedOpacity(
                opacity: _isInteracting ? 0.06 : 0.84,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: _isInteracting,
                  child: Center(
                    child: Builder(
                      builder: (ctx) {
                        final l10n = AppLocalizations.of(ctx);
                        final legendLived = l10n?.mapLegendLived ?? 'Lived';
                        final legendVisited = l10n?.mapLegendBeen ?? 'Visited';
                        final legendWishlist = l10n?.mapLegendWant ?? 'Wishlist';
                        final legendOther = l10n?.mapLegendUnvisited ?? 'Unvisited';

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildLegendDot(
                                color: const Color(0xFF10B981),
                                label: legendLived,
                                isDark: isDark,
                              ),
                              _buildLegendDot(
                                color: const Color(0xFFEA580C),
                                label: legendVisited,
                                isDark: isDark,
                              ),
                              _buildLegendDot(
                                color: const Color(0xFFEF4444),
                                label: legendWishlist,
                                isDark: isDark,
                              ),
                              _buildLegendDot(
                                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                label: legendOther,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildLegendDot({
    required Color color,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
