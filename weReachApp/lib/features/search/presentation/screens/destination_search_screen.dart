import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/bottom_action_sheet.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../../core/providers/core_providers.dart';

class DestinationSearchScreen extends ConsumerStatefulWidget {
  const DestinationSearchScreen({super.key});

  @override
  ConsumerState<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends ConsumerState<DestinationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Dio _dio = Dio();
  
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;
  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.trim().length >= 3) {
        _fetchSuggestions(query.trim());
      } else {
        setState(() {
          _suggestions = [];
          _errorMsg = "";
        });
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() {
      _isLoading = true;
      _errorMsg = "";
    });

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'WereachStopAlertApp/1.0',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _suggestions = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = "Server returned code ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = "Connection error. Please try again.";
        _isLoading = false;
      });
    }
  }

  void _handleSuggestionSelect(Map<String, dynamic> item) {
    _focusNode.unfocus();
    final String displayName = item['display_name'] ?? "";
    final String name = item['name'] ?? displayName.split(',')[0];
    final double lat = double.parse(item['lat']);
    final double lon = double.parse(item['lon']);

    // Add to database recents
    ref.read(recentsProvider.notifier).addRecent(name, displayName, lat, lon);
    
    // Calculate a mock distance for display
    final mockDist = (Random().nextDouble() * 12 + 1).toStringAsFixed(1);

    // Set selected destination state
    ref.read(selectedDestinationProvider.notifier).state = SelectedDestination(
      name: name,
      address: displayName,
      latitude: lat,
      longitude: lon,
      distanceText: "$mockDist km away",
    );
    
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Search Destination",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Search Box Input
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: "Where are you going?",
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged("");
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Custom location option button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.map_rounded, color: AppColors.accent, size: 20),
              ),
              title: const Text(
                "Choose on map",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              subtitle: const Text("Tap or drop a pin to select spot"),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              onTap: () {
                context.push('/map-select');
              },
            ),
          ),
          
          const Divider(color: AppColors.border, height: 24, thickness: 1, indent: 20, endIndent: 20),

          // Search results lists
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMsg.isNotEmpty
                    ? Center(
                        child: Text(
                          _errorMsg,
                          style: const TextStyle(color: AppColors.alert, fontSize: 14),
                        ),
                      )
                    : _suggestions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withOpacity(0.1)),
                                const SizedBox(height: 12),
                                const Text(
                                  "No destinations searched yet",
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _suggestions.length,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemBuilder: (context, index) {
                              final item = _suggestions[index];
                              final String displayName = item['display_name'] ?? "";
                              final String name = item['name'] ?? displayName.split(',')[0];
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: GlassCard(
                                  padding: EdgeInsets.zero,
                                  borderRadius: 12,
                                  child: ListTile(
                                    leading: const Icon(Icons.location_on_rounded, color: AppColors.primaryLight),
                                    title: Text(
                                      name,
                                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      displayName,
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () => _handleSuggestionSelect(item),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
