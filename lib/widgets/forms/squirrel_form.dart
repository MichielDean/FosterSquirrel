import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';

/// Full-screen page for adding or editing a squirrel
class SquirrelFormPage extends StatefulWidget {
  final Squirrel? squirrel;

  const SquirrelFormPage({super.key, this.squirrel});

  @override
  State<SquirrelFormPage> createState() => _SquirrelFormPageState();
}

class _SquirrelFormPageState extends State<SquirrelFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  // Cache expensive objects to avoid recreation in build methods
  static final _dateFormat = DateFormat('M/d/yyyy');
  static final List<DropdownMenuItem<DevelopmentStage>>
  _dropdownItems = DevelopmentStage.values.map((stage) {
    return DropdownMenuItem<DevelopmentStage>(
      value: stage,
      child: Text(
        '${stage.value} (${stage.minWeeks}-${stage.maxWeeks == 999 ? '∞' : stage.maxWeeks}w)',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }).toList();

  // Cache date ranges for date picker to avoid DateTime.now() calls in build methods
  late final DateTime _today;
  late final DateTime _earliestDate;

  DateTime _foundDate = DateTime.now();
  DevelopmentStage _developmentStage = DevelopmentStage.newborn;

  @override
  void initState() {
    super.initState();
    // Initialize cached date values once
    _today = DateTime.now();
    _earliestDate = _today.subtract(const Duration(days: 365));

    if (widget.squirrel != null) {
      _initializeWithExistingSquirrel();
    }
  }

  void _initializeWithExistingSquirrel() {
    final squirrel = widget.squirrel!;
    _nameController.text = squirrel.name;
    _weightController.text = squirrel.admissionWeight?.toString() ?? '';
    _notesController.text = squirrel.notes ?? '';
    _foundDate = squirrel.foundDate;
    _developmentStage = squirrel.developmentStage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.squirrel == null ? 'Add New Squirrel' : 'Edit Squirrel',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveSquirrel,
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
              _buildNameField(),
              const SizedBox(height: 16),
              _buildFoundDateField(),
              const SizedBox(height: 16),
              _buildDevelopmentStageField(),
              const SizedBox(height: 16),
              _buildWeightField(),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 32),
              // Save button at the bottom for better visibility
              _buildSaveButton(),
              const SizedBox(height: 32),
              // Static bottom padding instead of dynamic MediaQuery call
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Name *',
        hintText: 'Enter squirrel name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.pets),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required';
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildFoundDateField() {
    return InkWell(
      onTap: _selectFoundDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date Found *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(_formatDate(_foundDate)),
      ),
    );
  }

  Widget _buildDevelopmentStageField() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<DevelopmentStage>(
            initialValue: _developmentStage,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Development Stage',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timeline),
            ),
            items: _dropdownItems,
            onChanged: (DevelopmentStage? value) {
              if (value != null) {
                setState(() {
                  _developmentStage = value;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showDevelopmentStageInfo(context),
          tooltip: 'Development Stages',
        ),
      ],
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      decoration: const InputDecoration(
        labelText: 'Initial Weight (grams) *',
        hintText: 'Enter weight in grams',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.monitor_weight),
        suffixText: 'g',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Weight is required';
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

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes',
        hintText: 'Any additional information...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.notes),
        helperText: 'Optional - record special observations or conditions',
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
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
            onPressed: _saveSquirrel,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              widget.squirrel == null ? 'Add Squirrel' : 'Save Changes',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectFoundDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _foundDate,
      firstDate: _earliestDate,
      lastDate: _today,
    );

    if (picked != null) {
      setState(() {
        _foundDate = picked;
      });
    }
  }

  void _saveSquirrel() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final weight = _weightController.text.isNotEmpty
        ? double.tryParse(_weightController.text)
        : null;

    final squirrel =
        widget.squirrel?.copyWith(
          name: _nameController.text.trim(),
          foundDate: _foundDate,
          admissionWeight: weight,
          currentWeight: weight,
          developmentStage: _developmentStage,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ) ??
        Squirrel.create(
          name: _nameController.text.trim(),
          foundDate: _foundDate,
          admissionWeight: weight,
          developmentStage: _developmentStage,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    Navigator.of(context).pop(squirrel);
  }

  void _showDevelopmentStageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.timeline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Development Stages'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStageInfo(
                  'Pinkie (0-2 weeks)',
                  'Hairless, eyes and ears closed, pink skin. Very vulnerable, requires constant warmth and frequent feedings every 2-3 hours.',
                ),
                _buildStageInfo(
                  'Peach Fuzz (2-4 weeks)',
                  'Fine hair beginning to appear, giving a fuzzy appearance. Eyes still closed, ears may start to open. Continue frequent feedings.',
                ),
                _buildStageInfo(
                  'Fuzzy (4-6 weeks)',
                  'Full fur developing, eyes beginning to open. More active, may start to sit up. Can begin to introduce solid foods while continuing milk.',
                ),
                _buildStageInfo(
                  'Pre-Weaning (6-8 weeks)',
                  'Eyes fully open, very active and curious. Beginning to eat solid foods regularly. Still nursing but becoming more independent.',
                ),
                _buildStageInfo(
                  'Weaning (8-10 weeks)',
                  'Fully furred, very active. Eating solid foods primarily. Learning important survival skills. May still nurse occasionally.',
                ),
                _buildStageInfo(
                  'Pre-Release (10-12 weeks)',
                  'Independent eating, very active and agile. Learning to forage and climb effectively. Preparing for outdoor life.',
                ),
                _buildStageInfo(
                  'Adult/Release Ready (12+ weeks)',
                  'Fully independent, excellent climbing and foraging skills. Ready for release or already living independently in the wild.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note: These are general guidelines. Individual squirrels may develop at slightly different rates.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStageInfo(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
