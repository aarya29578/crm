import 'package:flutter/material.dart';

class EditCallClientDetailsDialog extends StatefulWidget {
  final String clientName;
  final String mobileNumber;
  final Future<void> Function(String clientName, String mobileNumber) onSave;

  const EditCallClientDetailsDialog({
    super.key,
    required this.clientName,
    required this.mobileNumber,
    required this.onSave,
  });

  @override
  State<EditCallClientDetailsDialog> createState() =>
      _EditCallClientDetailsDialogState();
}

class _EditCallClientDetailsDialogState
    extends State<EditCallClientDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientNameController;
  late final TextEditingController _mobileNumberController;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(text: widget.clientName);
    _mobileNumberController = TextEditingController(text: widget.mobileNumber);
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  String? _validateClientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Client name is required';
    }
    return null;
  }

  String? _validateMobileNumber(String? value) {
    final mobileNumber = value?.trim() ?? '';
    if (!RegExp(r'^\d{10}$').hasMatch(mobileNumber)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await widget.onSave(
        _clientNameController.text.trim(),
        _mobileNumberController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saveError = error.toString();
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Client Details'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_saveError != null) ...[
              Text(_saveError!, style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 12),
            ],
            TextFormField(
              key: const ValueKey('edit-client-name-field'),
              controller: _clientNameController,
              enabled: !_saving,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Client Name'),
              validator: _validateClientName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('edit-client-mobile-field'),
              controller: _mobileNumberController,
              enabled: !_saving,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                counterText: '',
              ),
              validator: _validateMobileNumber,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
