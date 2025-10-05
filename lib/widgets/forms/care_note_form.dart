import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/models.dart';

/// Full-screen page for adding or editing a care note
class CareNoteFormPage extends StatefulWidget {
  final String squirrelId;
  final CareNote? existingNote;

  const CareNoteFormPage({
    super.key,
    required this.squirrelId,
    this.existingNote,
  });

  @override
  State<CareNoteFormPage> createState() => _CareNoteFormPageState();
}

class _CareNoteFormPageState extends State<CareNoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  CareNoteType _selectedType = CareNoteType.general;
  bool _isImportant = false;
  String? _photoPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingNote != null) {
      _initializeWithExistingNote();
    }
  }

  void _initializeWithExistingNote() {
    final note = widget.existingNote!;
    _contentController.text = note.content;
    _selectedType = note.noteType;
    _isImportant = note.isImportant;
    _photoPath = note.photoPath;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final pickedFile = await picker.pickImage(source: result);
      if (pickedFile != null) {
        setState(() {
          _photoPath = pickedFile.path;
        });
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _photoPath = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final note = CareNote(
        id: widget.existingNote?.id ?? const Uuid().v4(),
        squirrelId: widget.squirrelId,
        content: _contentController.text.trim(),
        noteType: _selectedType,
        photoPath: _photoPath,
        isImportant: _isImportant,
        createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
      );

      Navigator.of(context).pop(note);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingNote != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Care Note' : 'Add Care Note'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Note Type Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<CareNoteType>(
                      segments: CareNoteType.values.map((type) {
                        return ButtonSegment<CareNoteType>(
                          value: type,
                          label: Text(_getNoteTypeLabel(type)),
                          icon: Icon(_getNoteTypeIcon(type)),
                        );
                      }).toList(),
                      selected: {_selectedType},
                      onSelectionChanged: (Set<CareNoteType> newSelection) {
                        setState(() {
                          _selectedType = newSelection.first;
                        });
                      },
                      multiSelectionEnabled: false,
                      showSelectedIcon: false,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note Content',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Enter care note details...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter note content';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Photo Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_photoPath != null) ...[
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _photoPath!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _removePhoto,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo),
                      label: Text(
                        _photoPath != null ? 'Change Photo' : 'Add Photo',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Important Flag
            Card(
              child: SwitchListTile(
                title: const Text('Mark as Important'),
                subtitle: const Text('Important notes will be highlighted'),
                secondary: Icon(
                  _isImportant ? Icons.flag : Icons.flag_outlined,
                  color: _isImportant ? Colors.red : null,
                ),
                value: _isImportant,
                onChanged: (bool value) {
                  setState(() {
                    _isImportant = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNoteTypeLabel(CareNoteType type) {
    return type.displayName;
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
}
