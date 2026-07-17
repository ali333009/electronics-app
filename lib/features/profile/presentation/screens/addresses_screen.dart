import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/core/theme/app_colors.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:elct/core/widgets/app_toast.dart';
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/address_model.dart';
import '../providers/profile_provider.dart';

class CountryInfo {
  final String name;
  final String code;
  final String flag;

  const CountryInfo({
    required this.name,
    required this.code,
    required this.flag,
  });
}

const List<CountryInfo> _countries = [
  CountryInfo(name: 'الكويت', code: '+965', flag: '🇰🇼'),
  CountryInfo(name: 'المملكة العربية السعودية', code: '+966', flag: '🇸🇦'),
  CountryInfo(name: 'الإمارات العربية المتحدة', code: '+971', flag: '🇦🇪'),
  CountryInfo(name: 'قطر', code: '+974', flag: '🇶🇦'),
  CountryInfo(name: 'البحرين', code: '+973', flag: '🇧🇭'),
  CountryInfo(name: 'عمان', code: '+968', flag: '🇴🇲'),
  CountryInfo(name: 'مصر', code: '+20', flag: '🇪🇬'),
];

const Map<String, List<String>> _regionsPerCountry = {
  '+965': ['العاصمة', 'حولي', 'الفروانية', 'الأحمدي', 'الجهراء', 'مبارك الكبير'],
  '+966': ['الرياض', 'مكة المكرمة', 'المنطقة الشرقية', 'المدينة المنورة', 'القصيم', 'عسير', 'تبوك', 'حائل'],
  '+971': ['أبوظبي', 'دبي', 'الشارقة', 'عجمان', 'رأس الخيمة', 'الفجيرة', 'أم القيوين'],
  '+974': ['الدوحة', 'الريان', 'الوكرة', 'الخور', 'الشمال', 'الظعاين', 'أم صلال'],
  '+973': ['العاصمة', 'المحرق', 'الشمالية', 'الجنوبية'],
  '+968': ['مسقط', 'ظفار', 'مسندم', 'البريمي', 'الداخلية', 'الباطنة', 'الشرقية'],
  '+20': ['القاهرة', 'الجيزة', 'الإسكندرية', 'القليوبية', 'الدقهلية', 'الشرقية', 'الغربية', 'المنوفية'],
};

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  
  CountryInfo _selectedCountry = _countries.first; // Kuwait default
  String? _selectedGovernorate;
  
  double _lat = 29.375900;
  double _lng = 47.977400;
  
  bool _isSaving = false;
  bool _dataLoaded = false;
  AddressModel? _existingAddress;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
  }

  void _initAddressForm(List<AddressModel> addresses) {
    if (_dataLoaded) return;
    _existingAddress = addresses.firstOrNull;
    if (_existingAddress != null) {
      _addressController.text = _existingAddress!.street;

      if (_existingAddress!.countryCode != null) {
        final parsedCountry = _countries.firstWhere(
          (c) => c.code == _existingAddress!.countryCode,
          orElse: () => _countries.first,
        );
        _selectedCountry = parsedCountry;
        if (_existingAddress!.latitude != null && _existingAddress!.longitude != null) {
          _lat = _existingAddress!.latitude!;
          _lng = _existingAddress!.longitude!;
        }
      } else if (_existingAddress!.label.contains(',')) {
        final parts = _existingAddress!.label.split(',');
        if (parts.length >= 3) {
          final parsedCountry = _countries.firstWhere(
            (c) => c.code == parts[0],
            orElse: () => _countries.first,
          );
          _selectedCountry = parsedCountry;
          final parsedLat = double.tryParse(parts[1]);
          final parsedLng = double.tryParse(parts[2]);
          if (parsedLat != null && parsedLng != null) {
            _lat = parsedLat;
            _lng = parsedLng;
          }
        }
      }

      final validRegions = _regionsPerCountry[_selectedCountry.code] ?? [];
      if (validRegions.contains(_existingAddress!.city)) {
        _selectedGovernorate = _existingAddress!.city;
      }
    }
    _dataLoaded = true;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) AppToast.show(context, AppLocalizations.of(context)!.permissionDenied, icon: Icons.warning);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) AppToast.show(context, AppLocalizations.of(context)!.permissionDeniedForever, icon: Icons.warning);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
      
      _mapController.move(LatLng(_lat, _lng), 15.0);
    } catch (e) {
      if (mounted) AppToast.show(context, AppLocalizations.of(context)!.locationFailed, icon: Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserIdProvider);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    final addressesAsync = ref.watch(addressesProvider(uid));

    ref.listen(addressesProvider(uid), (prev, next) {
      if (next is AsyncData && next.value != null) {
        _initAddressForm(next.value!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward : Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Text(e.toString(), style: const TextStyle(color: AppColors.error)),
        ),
        data: (addresses) {
          final regions = _regionsPerCountry[_selectedCountry.code] ?? [];

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.deliveryAddress,
                      style: AppTypography.displayMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
                    const SizedBox(height: 24),

                    // Country Selection Dropdown
                    _buildFieldLabel(l10n.country),
                    const SizedBox(height: 8),
                    _buildCountryDropdownField(),
                    const SizedBox(height: 18),

                    // Governorate Selection
                    _buildFieldLabel(_selectedCountry.code == '+20' ? l10n.governorate : l10n.regionGovernorate),
                    const SizedBox(height: 8),
                    _buildGovernorateDropdownField(regions),
                    const SizedBox(height: 18),

                    // Address details
                    _buildFieldLabel(l10n.addressDetails),
                    const SizedBox(height: 8),
                    _buildStreetField(),
                    const SizedBox(height: 24),

                    // OpenStreetMap Header & Button
                    _buildMapSectionLabel(),
                    const SizedBox(height: 12),
                    
                    // OpenStreetMap Map View
                    _buildOSMMapView(),
                    const SizedBox(height: 36),

                    // Save Button
                    _buildSaveButton(uid, l10n),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: RichText(
        text: TextSpan(
          text: label,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Country Picker ────────────────────────────────────────────────────────
  Widget _buildCountryDropdownField() {
    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
            Row(
              children: [
                Text(
                  _selectedCountry.name,
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(_selectedCountry.flag, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.selectCountry,
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    final isSelected = country.code == _selectedCountry.code;
                    return ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        country.name,
                        style: isSelected
                            ? AppTypography.labelLarge.copyWith(color: AppColors.gold)
                            : AppTypography.bodyLarge,
                        textAlign: TextAlign.start,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.gold, size: 18)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                          _selectedGovernorate = null; // reset region
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Governorate Dropdown ──────────────────────────────────────────────────
  Widget _buildGovernorateDropdownField(List<String> regions) {
    return FormField<String>(
      validator: (v) => _selectedGovernorate == null ? AppLocalizations.of(context)!.selectRegionRequired : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _showGovernoratePicker(context, regions),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: state.hasError ? AppColors.error : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    Text(
                      _selectedGovernorate ?? AppLocalizations.of(context)!.selectOption,
                      style: _selectedGovernorate != null
                          ? AppTypography.labelLarge
                          : AppTypography.bodyLarge.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 6, end: 12),
                child: Text(
                  state.errorText ?? '',
                  style: AppTypography.badge.copyWith(color: AppColors.error),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showGovernoratePicker(BuildContext context, List<String> regions) {
    if (regions.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedCountry.code == '+20' ? AppLocalizations.of(context)!.selectGovernorate : AppLocalizations.of(context)!.selectRegionGovernorate,
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    final reg = regions[index];
                    final isSelected = reg == _selectedGovernorate;
                    return ListTile(
                      title: Text(
                        reg,
                        style: isSelected
                            ? AppTypography.labelLarge.copyWith(color: AppColors.gold)
                            : AppTypography.bodyLarge,
                        textAlign: TextAlign.start,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.gold, size: 18)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedGovernorate = reg;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Street details ────────────────────────────────────────────────────────
  Widget _buildStreetField() {
    return TextFormField(
      controller: _addressController,
      validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.addressRequired : null,
      maxLines: 2,
      style: AppTypography.labelLarge,
      decoration: InputDecoration(
        hintText: 'Street, house/apartment/unit',
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: AppTypography.badge,
      ),
    );
  }

  // ─── Map Header ────────────────────────────────────────────────────────────
  Widget _buildMapSectionLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _getCurrentLocation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: Colors.white, size: 13),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.currentLocation,
                  style: AppTypography.badge.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Text(
          AppLocalizations.of(context)!.deliveryAddress,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ─── OpenStreetMap Widget Integration ──────────────────────────────────────
  Widget _buildOSMMapView() {
    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_lat, _lng),
                initialZoom: 14.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _lat = point.latitude;
                    _lng = point.longitude;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.elct',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_lat, _lng),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.error,
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        
        // Coordinates display bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.gold, size: 16),
              const SizedBox(width: 8),
              Text(
                'Lat: ${_lat.toStringAsFixed(6)}, Lng: ${_lng.toStringAsFixed(6)}',
                style: AppTypography.captionBold,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)!.locationInstruction,
          style: AppTypography.badge.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── Save Button ───────────────────────────────────────────────────────────
  Widget _buildSaveButton(String uid, AppLocalizations l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        gradient: _isSaving ? null : LinearGradient(
          colors: AppColors.goldGradient.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: _isSaving ? AppColors.border : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isSaving ? null : [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSaving ? null : () => _save(uid),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.gold,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.saveAddress,
                        style: AppTypography.titleLarge.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Save Logic ────────────────────────────────────────────────────────────
  Future<void> _save(String uid) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGovernorate == null) {
      AppToast.show(context, AppLocalizations.of(context)!.addressRequiredMsg, icon: Icons.warning_amber_rounded);
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    try {
      final repository = ref.read(addressRepositoryProvider);

      if (_existingAddress != null) {
        await repository.updateAddress(
          uid,
          _existingAddress!.copyWith(
            label: _selectedCountry.name,
            city: _selectedGovernorate!,
            street: _addressController.text.trim(),
            isDefault: true,
            countryCode: _selectedCountry.code,
            latitude: _lat,
            longitude: _lng,
          ),
        );
      } else {
        await repository.addAddress(
          uid,
          AddressModel(
            id: '',
            label: _selectedCountry.name,
            city: _selectedGovernorate!,
            street: _addressController.text.trim(),
            isDefault: true,
            countryCode: _selectedCountry.code,
            latitude: _lat,
            longitude: _lng,
          ),
        );
      }

      ref.invalidate(addressesProvider(uid));

      if (!mounted) return;
      AppToast.show(context, AppLocalizations.of(context)!.addressSavedSuccess, icon: Icons.check_circle_outline);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, AppLocalizations.of(context)!.errorOccurred(e.toString()), icon: Icons.error_outline);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
