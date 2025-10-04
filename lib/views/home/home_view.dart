import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../squirrel_detail/squirrel_detail_view.dart';
import '../../widgets/forms/squirrel_form.dart';
import '../../widgets/common/optimized_images.dart';

/// Home screen displaying list of squirrels and main navigation
///
/// PERFORMANCE OPTIMIZATION: This widget uses SquirrelListProvider with
/// ChangeNotifier instead of FutureBuilder to avoid the antipattern of
/// running database queries on every rebuild.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // PERFORMANCE: Load data AFTER UI is fully settled
    // Increased delay to 800ms to let splash screen transition complete
    // and give the main thread time to process the provider tree
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final provider = Provider.of<SquirrelListProvider>(
        context,
        listen: false,
      );
      if (!provider.hasData && !provider.isLoading) {
        // Start loading asynchronously - won't block UI
        provider.loadSquirrels();
      }
    });
  }

  Future<void> _addSquirrel(BuildContext context) async {
    final result = await Navigator.of(context).push<Squirrel>(
      MaterialPageRoute(builder: (context) => const SquirrelFormPage()),
    );

    if (result != null && context.mounted) {
      final provider = Provider.of<SquirrelListProvider>(
        context,
        listen: false,
      );

      try {
        await provider.addSquirrel(result);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${result.name} successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add squirrel: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE: Using Consumer instead of FutureBuilder
    // This only rebuilds when the provider notifies listeners,
    // not on every widget rebuild
    return Consumer<SquirrelListProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('FosterSquirrel'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: _buildBody(context, provider),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addSquirrel(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Squirrel'),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SquirrelListProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OptimizedImages.errorSquirrel,
            const SizedBox(height: 16),
            Text(
              'Error: ${provider.error}',
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadSquirrels(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final squirrels = provider.squirrels;
    if (squirrels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OptimizedImages.errorSquirrel,
            const SizedBox(height: 16),
            Text(
              'No squirrels yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first baby squirrel',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // PERFORMANCE: ListView.builder is already lazy-loading
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: squirrels.length,
      itemBuilder: (context, index) {
        final squirrel = squirrels[index];
        return SquirrelCard(
          squirrel: squirrel,
          onTap: () => _navigateToSquirrelDetail(context, squirrel),
        );
      },
    );
  }

  void _navigateToSquirrelDetail(BuildContext context, Squirrel squirrel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SquirrelDetailView(squirrel: squirrel),
      ),
    );
  }
}

/// Card widget displaying squirrel information
class SquirrelCard extends StatelessWidget {
  final Squirrel squirrel;
  final VoidCallback onTap;

  const SquirrelCard({super.key, required this.squirrel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Cache expensive calculations to avoid repeated calls during rebuilds
    final ageInDays = squirrel.actualAgeInDays;
    final currentStage = squirrel.currentDevelopmentStage;
    final currentWeight = squirrel.currentWeight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      squirrel.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          squirrel.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, currentStage),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Age: $ageInDays days',
                  ),
                  _buildInfoChip(
                    context,
                    icon: Icons.pets,
                    label: currentStage.value.toUpperCase(),
                    color: _getStageColor(currentStage),
                  ),
                  if (currentWeight != null)
                    _buildInfoChip(
                      context,
                      icon: Icons.monitor_weight,
                      label: '${currentWeight.toStringAsFixed(1)}g',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, DevelopmentStage stage) {
    final color = _getStageColor(stage);

    return Chip(
      label: Text(
        stage.value.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            color?.withValues(alpha: 0.1) ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get color for development stage chips
  Color _getStageColor(DevelopmentStage stage) {
    switch (stage) {
      case DevelopmentStage.newborn:
        return Colors.red;
      case DevelopmentStage.infant:
        return Colors.orange;
      case DevelopmentStage.juvenile:
        return Colors.blue;
      case DevelopmentStage.adolescent:
        return Colors.green;
      case DevelopmentStage.adult:
        return Colors.purple;
    }
  }
}
