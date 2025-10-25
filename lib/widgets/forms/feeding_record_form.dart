import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/squirrel.dart';
import '../../models/feeding_record.dart';
import '../../repositories/drift/feeding_repository.dart';

/// Full-screen page for adding new feeding records
class FeedingRecordForm extends StatefulWidget {
  final Squirrel squirrel;
  final FeedingRecord? existingRecord;

  const FeedingRecordForm({
    super.key,
    required this.squirrel,
    this.existingRecord,
  });

  @override
  State<FeedingRecordForm> createState() => _FeedingRecordFormState();
}

class _FeedingRecordFormState extends State<FeedingRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _startingWeightController = TextEditingController();
  final _endingWeightController = TextEditingController();
  final _actualFeedAmountController = TextEditingController();
  final _notesController = TextEditingController();

  // Cache expensive formatters to avoid recreation
  static final _dateFormat = DateFormat('M/d/yyyy');
  static final _timeFormat = DateFormat('h:mm a');

  // Cache date ranges for date picker to avoid DateTime.now() calls in build methods
  late final DateTime _today;
  late final DateTime _earliestDate;

  DateTime _feedingTime = DateTime.now();
  String _foodType = 'Formula';
  double? _recommendedAmount;

  @override
  void initState() {
    super.initState();
    // Initialize cached date values once
    _today = DateTime.now();
    _earliestDate = _today.subtract(const Duration(days: 365));

    if (widget.existingRecord != null) {
      _populateFromExistingRecord();
    }
    _calculateRecommendedAmount();
  }

  void _populateFromExistingRecord() {
    final record = widget.existingRecord!;
    _startingWeightController.text = record.startingWeightGrams.toString();
    _endingWeightController.text = record.endingWeightGrams?.toString() ?? '';
    _actualFeedAmountController.text =
        record.actualFeedAmountML?.toString() ?? '';
    _notesController.text = record.notes ?? '';
    _feedingTime = record.feedingTime;
    _foodType = record.foodType;
  }

  void _calculateRecommendedAmount() {
    final weightText = _startingWeightController.text;
    if (weightText.isNotEmpty) {
      final weight = double.tryParse(weightText);
      if (weight != null) {
        // Create a temporary record to calculate recommended amount
        final tempRecord = FeedingRecord(
          id: 'temp',
          squirrelId: widget.squirrel.id,
          squirrelName: widget.squirrel.name,
          feedingTime: _feedingTime,
          startingWeightGrams: weight,
        );
        setState(() {
          _recommendedAmount = tempRecord.recommendedFeedAmountML;
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_dateFormat.format(dateTime)} at ${_timeFormat.format(dateTime)}';
  }

  @override
  void dispose() {
    _startingWeightController.dispose();
    _endingWeightController.dispose();
    _actualFeedAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingRecord == null
                  ? 'Add Feeding Record'
                  : 'Edit Feeding Record',
            ),
            Text(
              'for ${widget.squirrel.name}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            key: const Key('save_button'),
            onPressed: _saveFeedingRecord,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text(
              'SAVE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFeedingTimeField(),
              const SizedBox(height: 16),
              _buildStartingWeightField(),
              const SizedBox(height: 16),
              _buildRecommendedAmountDisplay(),
              const SizedBox(height: 16),
              _buildActualFeedAmountField(),
              const SizedBox(height: 16),
              _buildEndingWeightField(),
              const SizedBox(height: 16),
              _buildFoodTypeField(),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 32),
              // Save button at the bottom for better visibility
              _buildSaveButton(),
              const SizedBox(height: 16),
              // Add some bottom padding for better scrolling experience
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedingTimeField() {
    return InkWell(
      onTap: _selectFeedingTime,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Feeding Date & Time *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.access_time),
        ),
        child: Text(_formatDateTime(_feedingTime)),
      ),
    );
  }

  Widget _buildStartingWeightField() {
    return TextFormField(
      key: const Key('starting_weight_field'),
      controller: _startingWeightController,
      decoration: const InputDecoration(
        labelText: 'Pre-Feeding Weight (grams) *',
        hintText: 'Enter weight before feeding',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.monitor_weight),
        suffixText: 'g',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) => _calculateRecommendedAmount(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Pre-feeding weight is required';
        }
        final weight = double.tryParse(value.trim());
        if (weight == null) {
          return 'Please enter a valid number';
        }
        if (weight <= 0) {
          return 'Weight must be greater than 0';
        }
        if (weight > 1000) {
          return 'Weight seems too high for a squirrel';
        }
        return null;
      },
    );
  }

  Widget _buildRecommendedAmountDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  _recommendedAmount != null
                      ? '${_recommendedAmount!.toStringAsFixed(1)} mL'
                      : 'Enter weight to calculate',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActualFeedAmountField() {
    return TextFormField(
      key: const Key('actual_feed_amount_field'),
      controller: _actualFeedAmountController,
      decoration: const InputDecoration(
        labelText: 'Actual Amount Fed (mL)',
        hintText: 'How much was actually fed',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_drink),
        suffixText: 'mL',
        helperText: 'Optional - record what was actually consumed',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final amount = double.tryParse(value.trim());
          if (amount == null) {
            return 'Please enter a valid number';
          }
          if (amount < 0) {
            return 'Amount cannot be negative';
          }
          if (amount > 50) {
            return 'Amount seems too high for a squirrel';
          }
        }
        return null;
      },
    );
  }

  Widget _buildEndingWeightField() {
    return TextFormField(
      key: const Key('ending_weight_field'),
      controller: _endingWeightController,
      decoration: const InputDecoration(
        labelText: 'Post-Feeding Weight (grams)',
        hintText: 'Weight after feeding (optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.monitor_weight_outlined),
        suffixText: 'g',
        helperText: 'Optional - helps track weight gain',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final weight = double.tryParse(value.trim());
          if (weight == null) {
            return 'Please enter a valid number';
          }
          if (weight <= 0) {
            return 'Weight must be greater than 0';
          }
          if (weight > 1000) {
            return 'Weight seems too high for a squirrel';
          }
          // Check if ending weight is reasonable compared to starting weight
          final startingWeight = double.tryParse(
            _startingWeightController.text,
          );
          if (startingWeight != null && weight < startingWeight * 0.8) {
            return 'Ending weight seems too low compared to starting weight';
          }
        }
        return null;
      },
    );
  }

  Widget _buildFoodTypeField() {
    return DropdownButtonFormField<String>(
      initialValue: _foodType,
      decoration: const InputDecoration(
        labelText: 'Food Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.restaurant),
      ),
      items: const [
        DropdownMenuItem(value: 'Formula', child: Text('Formula')),
        DropdownMenuItem(value: 'Solid food', child: Text('Solid food')),
        DropdownMenuItem(value: 'Water', child: Text('Water')),
        DropdownMenuItem(value: 'Medication', child: Text('Medication')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _foodType = value;
          });
        }
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      key: const Key('notes_field'),
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes',
        hintText: 'Any observations or notes about this feeding',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
      maxLength: 500,
    );
  }

  Widget _buildSaveButton() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            key: const Key('save_button'),
            onPressed: _saveFeedingRecord,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              widget.existingRecord == null ? 'Add Record' : 'Save Changes',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectFeedingTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _feedingTime,
      firstDate: _earliestDate,
      lastDate: _today,
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_feedingTime),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _feedingTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveFeedingRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final repository = Provider.of<FeedingRepository>(context, listen: false);

      final record = FeedingRecord(
        id: widget.existingRecord?.id ?? const Uuid().v4(),
        squirrelId: widget.squirrel.id,
        squirrelName: widget.squirrel.name,
        feedingTime: _feedingTime,
        startingWeightGrams: double.parse(_startingWeightController.text),
        endingWeightGrams: _endingWeightController.text.isNotEmpty
            ? double.parse(_endingWeightController.text)
            : null,
        actualFeedAmountML: _actualFeedAmountController.text.isNotEmpty
            ? double.parse(_actualFeedAmountController.text)
            : null,
        foodType: _foodType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (widget.existingRecord == null) {
        await repository.addFeedingRecord(record);
      } else {
        await repository.updateFeedingRecord(record);
      }

      if (mounted) {
        Navigator.of(context).pop(record);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving feeding record: $e')),
        );
      }
    }
  }
}
