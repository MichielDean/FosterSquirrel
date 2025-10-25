import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/squirrel.dart';
import '../../models/feeding_record.dart';
import '../../models/care_note.dart';
import '../../repositories/drift/feeding_repository.dart';
import '../../repositories/drift/care_note_repository.dart';
import '../../widgets/forms/feeding_record_form.dart';
import '../../widgets/forms/care_note_form.dart';
import '../../widgets/charts/weight_progress_chart.dart';
import '../../providers/care_note_list_provider.dart';

/// Comprehensive detail view for displaying squirrel information and managing feeding records
class SquirrelDetailView extends StatefulWidget {
  final Squirrel squirrel;

  const SquirrelDetailView({super.key, required this.squirrel});

  @override
  State<SquirrelDetailView> createState() => _SquirrelDetailViewState();
}

class _SquirrelDetailViewState extends State<SquirrelDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FeedingRecord> _feedingRecords = [];
  List<FeedingRecord> _sortedFeedingRecords = [];
  final Map<String, double?> _baselineWeightCache = {};
  bool _isLoading = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    // Defer loading until after the widget is fully built to avoid
    // accessing InheritedWidgets (like ScaffoldMessenger) during initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeedingRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedingRecords() async {
    try {
      final repository = Provider.of<FeedingRepository>(context, listen: false);
      final records = await repository.getFeedingRecords(widget.squirrel.id);

      // Pre-sort records and calculate baseline weights to avoid expensive operations during build
      _sortedFeedingRecords = List<FeedingRecord>.from(records)
        ..sort((a, b) => a.feedingTime.compareTo(b.feedingTime));

      // Pre-calculate baseline weights for all records
      _baselineWeightCache.clear();
      for (int i = 0; i < _sortedFeedingRecords.length; i++) {
        final record = _sortedFeedingRecords[i];
        double? baselineWeight;

        if (i == 0) {
          // First feeding record uses admission weight
          baselineWeight = widget.squirrel.admissionWeight;
        } else {
          // Use the ending weight from the previous feeding record, or starting weight if ending not available
          final previousRecord = _sortedFeedingRecords[i - 1];
          baselineWeight =
              previousRecord.endingWeightGrams ??
              previousRecord.startingWeightGrams;
        }

        _baselineWeightCache[record.id] = baselineWeight;
      }

      setState(() {
        _feedingRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading feeding records: $e')),
        );
      }
    }
  }

  Future<void> _addFeedingRecord() async {
    final result = await Navigator.of(context).push<FeedingRecord>(
      MaterialPageRoute(
        builder: (context) => FeedingRecordForm(squirrel: widget.squirrel),
      ),
    );

    if (result != null) {
      await _loadFeedingRecords(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feeding record added successfully')),
        );
      }
    }
  }

  Future<void> _editFeedingRecord(FeedingRecord record) async {
    final result = await Navigator.of(context).push<FeedingRecord>(
      MaterialPageRoute(
        builder: (context) => FeedingRecordForm(
          squirrel: widget.squirrel,
          existingRecord: record,
        ),
      ),
    );

    if (result != null) {
      await _loadFeedingRecords(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feeding record updated successfully')),
        );
      }
    }
  }

  Future<void> _deleteFeedingRecord(FeedingRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feeding Record'),
        content: const Text(
          'Are you sure you want to delete this feeding record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = Provider.of<FeedingRepository>(
          context,
          listen: false,
        );
        await repository.deleteFeedingRecord(record.id);
        await _loadFeedingRecords(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feeding record deleted successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete feeding record: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.squirrel.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Info'),
            Tab(icon: Icon(Icons.restaurant), text: 'Feeding'),
            Tab(icon: Icon(Icons.timeline), text: 'Progress'),
            Tab(icon: Icon(Icons.note), text: 'Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildFeedingTab(),
          _buildProgressTab(),
          _buildCareNotesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add feeding record or care note depending on current tab
          if (_currentTabIndex == 3) {
            _addCareNote();
          } else {
            if (_currentTabIndex != 1) {
              _tabController.animateTo(1);
            }
            _addFeedingRecord();
          }
        },
        tooltip: _currentTabIndex == 3 ? 'Add Care Note' : 'Add Feeding Record',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Name', widget.squirrel.name),
                  _buildDetailRow(
                    'Found Date',
                    widget.squirrel.foundDate.toIso8601String().split('T')[0],
                  ),
                  _buildDetailRow(
                    'Actual Age',
                    '${widget.squirrel.actualAgeInDays} days (${widget.squirrel.actualAgeInWeeks.toStringAsFixed(1)} weeks)',
                  ),
                  _buildDetailRow(
                    'Days Since Found',
                    '${widget.squirrel.daysSinceFound} days',
                  ),
                  _buildDetailRow(
                    'Development Stage at Found',
                    widget.squirrel.developmentStage.value,
                  ),
                  _buildDetailRow(
                    'Current Development Stage',
                    widget.squirrel.currentDevelopmentStage.value,
                  ),
                  _buildDetailRow('Status', widget.squirrel.status.value),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Weight Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weight Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (widget.squirrel.admissionWeight != null)
                    _buildDetailRow(
                      'Admission Weight',
                      '${widget.squirrel.admissionWeight!.toStringAsFixed(1)}g',
                    ),
                  if (widget.squirrel.currentWeight != null)
                    _buildDetailRow(
                      'Current Weight',
                      '${widget.squirrel.currentWeight!.toStringAsFixed(1)}g',
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (widget.squirrel.notes != null &&
              widget.squirrel.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),

            // Notes Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.squirrel.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Feeding Schedule Info Card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feeding Schedule',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildFeedingScheduleInfo(),
              ],
            ),
          ),
        ),

        // Feeding Records List
        Expanded(
          child: _feedingRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No feeding records yet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add the first feeding record',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _feedingRecords.length,
                  itemBuilder: (context, index) {
                    final record = _feedingRecords[index];
                    return FeedingRecordCard(
                      record: record,
                      baselineWeight: _baselineWeightCache[record.id],
                      onEdit: () => _editFeedingRecord(record),
                      onDelete: () => _deleteFeedingRecord(record),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight Progress Chart
          Card(
            child: WeightProgressChart(
              squirrelId: widget.squirrel.id,
              height: 300,
            ),
          ),
          const SizedBox(height: 16),
          // Additional progress metrics could go here
          _buildProgressSummary(),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Current Weight',
              widget.squirrel.currentWeight != null
                  ? '${widget.squirrel.currentWeight!.toStringAsFixed(1)}g'
                  : 'Not recorded',
            ),
            _buildSummaryRow(
              'Admission Weight',
              widget.squirrel.admissionWeight != null
                  ? '${widget.squirrel.admissionWeight!.toStringAsFixed(1)}g'
                  : 'Not recorded',
            ),
            _buildSummaryRow(
              'Current Development Stage',
              _formatDevelopmentStage(widget.squirrel.currentDevelopmentStage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDevelopmentStage(DevelopmentStage stage) {
    switch (stage) {
      case DevelopmentStage.newborn:
        return 'Newborn (0-2 weeks)';
      case DevelopmentStage.infant:
        return 'Infant (2-5 weeks)';
      case DevelopmentStage.juvenile:
        return 'Juvenile (5-8 weeks)';
      case DevelopmentStage.adolescent:
        return 'Adolescent (8-12 weeks)';
      case DevelopmentStage.adult:
        return 'Adult (12+ weeks)';
    }
  }

  Widget _buildFeedingScheduleInfo() {
    // Create a temporary record to get feeding schedule information
    final currentWeight =
        widget.squirrel.currentWeight ??
        widget.squirrel.admissionWeight ??
        50.0;
    final tempRecord = FeedingRecord(
      id: 'temp',
      squirrelId: widget.squirrel.id,
      squirrelName: widget.squirrel.name,
      feedingTime: DateTime.now(),
      startingWeightGrams: currentWeight,
    );
    final schedule = tempRecord.feedingSchedule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          'Recommended Interval',
          '${schedule.feedingIntervalHours} hours',
        ),
        _buildDetailRow(
          'Feeding Amount',
          '${tempRecord.recommendedFeedAmountML.toStringAsFixed(1)} mL',
        ),
        _buildDetailRow('Next Feeding', _getNextFeedingTime()),
        if (schedule.requiresNightFeeding)
          _buildDetailRow(
            'Night Feeding',
            'Required',
            valueColor: Colors.orange,
          ),
      ],
    );
  }

  String _getNextFeedingTime() {
    if (_feedingRecords.isEmpty) {
      return 'Add first feeding record';
    }

    final lastFeeding = _feedingRecords.first; // Assuming sorted by most recent
    final tempRecord = FeedingRecord(
      id: 'temp',
      squirrelId: widget.squirrel.id,
      squirrelName: widget.squirrel.name,
      feedingTime: DateTime.now(),
      startingWeightGrams: lastFeeding.startingWeightGrams,
    );
    final schedule = tempRecord.feedingSchedule;
    final nextFeeding = lastFeeding.feedingTime.add(
      Duration(hours: schedule.feedingIntervalHours.round()),
    );

    final now = DateTime.now();
    if (nextFeeding.isBefore(now)) {
      return 'Overdue';
    } else {
      final difference = nextFeeding.difference(now);
      if (difference.inHours > 0) {
        return 'In ${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        return 'In ${difference.inMinutes}m';
      }
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: valueColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildCareNotesTab() {
    return ChangeNotifierProxyProvider<
      CareNoteRepository,
      CareNoteListProvider
    >(
      create: (context) => CareNoteListProvider(
        repository: Provider.of<CareNoteRepository>(context, listen: false),
        squirrelId: widget.squirrel.id,
      ),
      update: (context, repository, previous) =>
          previous ??
          CareNoteListProvider(
            repository: repository,
            squirrelId: widget.squirrel.id,
          ),
      builder: (context, child) {
        return Consumer<CareNoteListProvider>(
          builder: (context, provider, _) {
            // Load care notes if not already loaded
            if (!provider.hasData && !provider.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.loadCareNotes();
              });
            }

            if (provider.isLoading && !provider.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Error: ${provider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final notes = provider.careNotes;
            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No care notes yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add the first note',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return CareNoteCard(
                  note: note,
                  onEdit: () => _editCareNote(context, note),
                  onDelete: () => _deleteCareNote(context, note),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _addCareNote() async {
    final result = await Navigator.of(context).push<CareNote>(
      MaterialPageRoute(
        builder: (context) => CareNoteFormPage(squirrelId: widget.squirrel.id),
      ),
    );

    if (result != null && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final provider = Provider.of<CareNoteListProvider>(
        context,
        listen: false,
      );
      try {
        await provider.addCareNote(result);
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Care note added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to add care note: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ignore: use_build_context_synchronously
  Future<void> _editCareNote(BuildContext context, CareNote note) async {
    final result = await Navigator.of(context).push<CareNote>(
      MaterialPageRoute(
        builder: (context) => CareNoteFormPage(
          squirrelId: widget.squirrel.id,
          existingNote: note,
        ),
      ),
    );

    if (result == null || !mounted) return;

    // ignore: use_build_context_synchronously
    final messenger = ScaffoldMessenger.of(context);
    // ignore: use_build_context_synchronously
    final provider = Provider.of<CareNoteListProvider>(context, listen: false);

    try {
      await provider.updateCareNote(result);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Care note updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to update care note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ignore: use_build_context_synchronously
  Future<void> _deleteCareNote(BuildContext context, CareNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Care Note'),
        content: const Text('Are you sure you want to delete this care note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // ignore: use_build_context_synchronously
    final messenger = ScaffoldMessenger.of(context);
    // ignore: use_build_context_synchronously
    final provider = Provider.of<CareNoteListProvider>(context, listen: false);

    try {
      await provider.deleteCareNote(note.id);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Care note deleted successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete care note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Additional methods and widgets below...
}

/// Standalone widget for displaying feeding record information
class FeedingRecordCard extends StatelessWidget {
  final FeedingRecord record;
  final double? baselineWeight;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FeedingRecordCard({
    super.key,
    required this.record,
    this.baselineWeight,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.restaurant, color: Colors.white),
        ),
        title: Text(
          '${(record.actualFeedAmountML ?? record.recommendedFeedAmountML).toStringAsFixed(1)} mL',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDateTime(record.feedingTime)),
            if (record.endingWeightGrams != null)
              Text(
                'Weight: ${record.startingWeightGrams.toStringAsFixed(1)}g → ${record.endingWeightGrams!.toStringAsFixed(1)}g',
              )
            else
              Text(
                'Starting weight: ${record.startingWeightGrams.toStringAsFixed(1)}g',
              ),
            // Show weight gain from admission or previous feeding
            _buildWeightGainInfo(),
            if (record.notes != null && record.notes!.isNotEmpty)
              Text(record.notes!, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              (record.actualFeedAmountML ?? 0) >= record.recommendedFeedAmountML
                  ? Icons.check_circle
                  : Icons.warning,
              color:
                  (record.actualFeedAmountML ?? 0) >=
                      record.recommendedFeedAmountML
                  ? Colors.green
                  : Colors.orange,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('M/d/yyyy h:mm a').format(dateTime);
  }

  Widget _buildWeightGainInfo() {
    if (record.endingWeightGrams == null || baselineWeight == null) {
      return const SizedBox.shrink();
    }

    final weightGain = record.calculateWeightGainFrom(baselineWeight!);
    if (weightGain == null) {
      return const SizedBox.shrink();
    }

    String gainText;
    Color gainColor;

    if (weightGain > 0) {
      gainText = 'Gained ${weightGain.toStringAsFixed(1)}g';
      gainColor = Colors.green;
    } else if (weightGain < 0) {
      gainText = 'Lost ${(-weightGain).toStringAsFixed(1)}g';
      gainColor = Colors.red;
    } else {
      gainText = 'No weight change';
      gainColor = Colors.grey;
    }

    return Text(
      gainText,
      style: TextStyle(color: gainColor, fontWeight: FontWeight.w500),
    );
  }
}

/// Widget for displaying a care note card
class CareNoteCard extends StatelessWidget {
  final CareNote note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CareNoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNoteTypeColor(note.noteType),
              child: Icon(_getNoteTypeIcon(note.noteType), color: Colors.white),
            ),
            title: Row(
              children: [
                Text(
                  note.noteType.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (note.isImportant) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.flag, color: Colors.red, size: 18),
                ],
              ],
            ),
            subtitle: Text(
              DateFormat('M/d/yyyy h:mm a').format(note.createdAt),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(note.content),
          ),
          if (note.photoPath != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  note.photoPath!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getNoteTypeIcon(CareNoteType type) {
    switch (type) {
      case CareNoteType.general:
        return Icons.note;
      case CareNoteType.medical:
        return Icons.medical_services;
      case CareNoteType.behavioral:
        return Icons.psychology;
      case CareNoteType.feeding:
        return Icons.restaurant;
      case CareNoteType.development:
        return Icons.trending_up;
      case CareNoteType.release:
        return Icons.flight_takeoff;
    }
  }

  Color _getNoteTypeColor(CareNoteType type) {
    switch (type) {
      case CareNoteType.general:
        return Colors.blue;
      case CareNoteType.medical:
        return Colors.red;
      case CareNoteType.behavioral:
        return Colors.purple;
      case CareNoteType.feeding:
        return Colors.orange;
      case CareNoteType.development:
        return Colors.green;
      case CareNoteType.release:
        return Colors.teal;
    }
  }
}
