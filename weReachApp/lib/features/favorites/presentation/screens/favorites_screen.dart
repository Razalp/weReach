import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/destination_card.dart';
import '../providers/favorites_provider.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);

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
          "My Favorites",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: favoritesState.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    size: 72,
                    color: Colors.white.withOpacity(0.08),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No favorite stops saved yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Search and star places to view them here.",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = list[index];
              return DestinationCard(
                name: item.name,
                address: item.address,
                isFavorite: true,
                onFavoriteToggle: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(item.id);
                },
                onDelete: () {
                  ref.read(favoritesProvider.notifier).deleteFavorite(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Removed ${item.name} from Favorites"),
                      backgroundColor: AppColors.alert,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onTap: () {
                  // Start tracker GPS stream
                  ref.read(trackingProvider.notifier).startTracking(
                        name: item.name,
                        latitude: item.latitude,
                        longitude: item.longitude,
                      );
                  // Redirect to active tracking screen
                  context.go('/tracking');
                },
              );
            },
          );
        },
        error: (err, _) => const Center(
          child: Text(
            "Error loading favorite destinations",
            style: TextStyle(color: AppColors.alert),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}
