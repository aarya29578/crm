import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart' as all_leads;
import 'package:crm_flutter/api/response/campaign_custom_fields_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CampaignDynamicFieldsWidget extends StatefulWidget {
  final String? campaignId;
  final List<all_leads.CustomList>? initialCustomList;
  final InputDecoration Function(String label, bool isRequired)?
      decorationBuilder;
  final Widget Function(Widget child)? fieldWrapper;
  final double spacing;
  final ValueChanged<List<Map<String, String>>>? onChanged;

  const CampaignDynamicFieldsWidget({
    super.key,
    required this.campaignId,
    this.initialCustomList,
    this.decorationBuilder,
    this.fieldWrapper,
    this.spacing = 12.0,
    this.onChanged,
  });

  @override
  State<CampaignDynamicFieldsWidget> createState() =>
      CampaignDynamicFieldsWidgetState();
}

class CampaignDynamicFieldsWidgetState
    extends State<CampaignDynamicFieldsWidget> {
  static final Map<String, List<CampaignCustomField>> _fieldsCache = {};

  @visibleForTesting
  static void clearCache() => _fieldsCache.clear();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _error;
  List<CampaignCustomField> _fields = [];
  String? _currentCampaignId;

  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String?> _selectedOptions = {};
  final Map<String, DateTime?> _selectedDates = {};
  final Map<String, Set<String>> _selectedCheckboxes = {};
  final Map<String, bool> _singleCheckboxes = {};

  List<CampaignCustomField> get fields => _fields;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void initState() {
    super.initState();
    _currentCampaignId = widget.campaignId;
    if (_currentCampaignId != null && _currentCampaignId!.isNotEmpty) {
      _fetchFields();
    }
  }

  @override
  void didUpdateWidget(covariant CampaignDynamicFieldsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.campaignId != oldWidget.campaignId) {
      _currentCampaignId = widget.campaignId;
      _clearFieldValues();
      if (_currentCampaignId != null && _currentCampaignId!.isNotEmpty) {
        _fetchFields();
      } else {
        setState(() {
          _fields = [];
          _error = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    super.dispose();
  }

  void _clearFieldValues() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    _selectedOptions.clear();
    _selectedDates.clear();
    _selectedCheckboxes.clear();
    _singleCheckboxes.clear();
  }

  Future<void> _fetchFields({bool forceRefresh = false}) async {
    final campaignId = _currentCampaignId;
    if (campaignId == null || campaignId.isEmpty) return;

    if (!forceRefresh && _fieldsCache.containsKey(campaignId)) {
      final cached = _fieldsCache[campaignId]!;
      setState(() {
        _fields = cached;
        _isLoading = false;
        _error = null;
      });
      _initializeFieldValues();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await DioApi().getCampaignCustomFields(campaignId);
      if (!mounted || _currentCampaignId != campaignId) return;

      final fetchedFields = response.fields;
      _fieldsCache[campaignId] = fetchedFields;

      setState(() {
        _fields = fetchedFields;
        _isLoading = false;
        _error = null;
      });
      _initializeFieldValues();
    } catch (e) {
      if (!mounted || _currentCampaignId != campaignId) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst(RegExp(r'^(Exception:\s*)+'), '');
      });
    }
  }

  void _initializeFieldValues() {
    final initialList = widget.initialCustomList ?? [];
    final isInitialCampaign = widget.campaignId != null;

    for (final field in _fields) {
      final key = _fieldKey(field);

      all_leads.CustomList? matched;
      if (isInitialCampaign && initialList.isNotEmpty) {
        matched = initialList.where((item) {
          if (field.id != null &&
              item.sId != null &&
              item.sId == field.id) {
            return true;
          }
          final itemLabel = item.label?.trim().toLowerCase();
          final fieldLabel = field.label.trim().toLowerCase();
          return itemLabel != null &&
              itemLabel.isNotEmpty &&
              itemLabel == fieldLabel;
        }).firstOrNull;
      }

      final initialStringVal =
          matched?.value != null && matched!.value!.isNotEmpty
              ? matched.value!.join(', ')
              : '';

      switch (field.type) {
        case 'dropdown':
        case 'select':
        case 'radio':
          _selectedOptions[key] =
              initialStringVal.isNotEmpty ? initialStringVal : null;
          break;
        case 'date':
          if (initialStringVal.isNotEmpty) {
            _selectedDates[key] = DateTime.tryParse(initialStringVal);
          }
          break;
        case 'checkbox':
          if (field.options.isEmpty) {
            _singleCheckboxes[key] =
                initialStringVal.toLowerCase() == 'true' ||
                    initialStringVal == '1';
          } else {
            _selectedCheckboxes[key] = matched?.value != null
                ? matched!.value!.map((v) => v.trim()).toSet()
                : <String>{};
          }
          break;
        default:
          _textControllers[key] =
              TextEditingController(text: initialStringVal);
          break;
      }
    }
  }

  String _fieldKey(CampaignCustomField field) {
    return field.id != null && field.id!.isNotEmpty
        ? field.id!
        : field.label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _getFieldValueString(CampaignCustomField field) {
    final key = _fieldKey(field);
    switch (field.type) {
      case 'dropdown':
      case 'select':
      case 'radio':
        return _selectedOptions[key]?.trim() ?? '';
      case 'date':
        final date = _selectedDates[key];
        return date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
      case 'checkbox':
        if (field.options.isEmpty) {
          final isChecked = _singleCheckboxes[key] ?? false;
          return isChecked ? 'true' : 'false';
        } else {
          final selected = _selectedCheckboxes[key] ?? {};
          return selected.join(', ');
        }
      default:
        return _textControllers[key]?.text.trim() ?? '';
    }
  }

  bool validate() {
    if (_fields.isEmpty) return true;
    final formValid = _formKey.currentState?.validate() ?? true;

    var customValid = true;
    for (final field in _fields) {
      if (field.required) {
        final val = _getFieldValueString(field);
        if (val.isEmpty || (field.type == 'checkbox' && val == 'false')) {
          customValid = false;
        }
      }
    }

    return formValid && customValid;
  }

  List<Map<String, String>> getCustomFieldPayload({bool includeEmpty = true}) {
    final List<Map<String, String>> result = [];
    for (final field in _fields) {
      final value = _getFieldValueString(field);
      if (includeEmpty || value.isNotEmpty) {
        result.add({
          'label': field.label,
          'value': value,
        });
      }
    }
    return result;
  }

  List<all_leads.CustomList> getCustomFieldsAsModelList() {
    return _fields.map((field) {
      final value = _getFieldValueString(field);
      final List<String> valuesList;
      if (field.type == 'checkbox' && field.options.isNotEmpty) {
        valuesList = (_selectedCheckboxes[_fieldKey(field)] ?? {})
            .toList();
      } else {
        valuesList = value.isNotEmpty ? [value] : [];
      }
      return all_leads.CustomList(
        label: field.label,
        value: valuesList,
        sId: field.id,
      );
    }).toList();
  }

  bool hasChanges() {
    if (_fields.isEmpty || _isLoading || _error != null) return false;
    final current = getCustomFieldPayload();
    final initial = widget.initialCustomList ?? [];

    if (current.isEmpty && initial.isEmpty) return false;

    final initialMap = <String, String>{};
    for (final item in initial) {
      final label = item.label?.trim().toLowerCase() ?? '';
      if (label.isNotEmpty) {
        initialMap[label] = (item.value?.join(', ') ?? '').trim();
      }
    }

    for (final entry in current) {
      final label = entry['label']!.trim().toLowerCase();
      final currentVal = entry['value']!.trim();
      final initVal = initialMap[label] ?? '';
      if (currentVal != initVal) return true;
    }

    for (final entry in initialMap.entries) {
      final matchingCurrent = current
          .where((c) => c['label']!.trim().toLowerCase() == entry.key)
          .firstOrNull;
      if (matchingCurrent == null && entry.value.isNotEmpty) return true;
    }

    return false;
  }

  InputDecoration _decoration(String label, bool isRequired) {
    if (widget.decorationBuilder != null) {
      return widget.decorationBuilder!(label, isRequired);
    }
    return InputDecoration(
      labelText: isRequired ? '$label *' : label,
      border: const OutlineInputBorder(),
    );
  }

  String? _validateInput(CampaignCustomField field, String? rawValue) {
    final value = rawValue?.trim() ?? '';
    if (field.required && value.isEmpty) {
      return '${field.label} is required';
    }
    if (value.isNotEmpty) {
      if (field.type == 'number') {
        if (num.tryParse(value) == null) {
          return '${field.label} must be a number';
        }
      } else if (field.type == 'email') {
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
          return 'Enter a valid email address';
        }
      } else if (field.type == 'phone') {
        if (value.length < 7 || int.tryParse(value) == null) {
          return 'Enter a valid phone number';
        }
      }
    }
    return null;
  }

  Widget _wrapField(Widget child) {
    if (widget.fieldWrapper != null) {
      return widget.fieldWrapper!(child);
    }
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing),
      child: child,
    );
  }

  Widget _buildFieldItem(CampaignCustomField field) {
    final key = _fieldKey(field);
    final fieldWidgetKey = ValueKey('dynamic-field-${field.label.toLowerCase().replaceAll(' ', '-')}-$key');

    switch (field.type) {
      case 'dropdown':
      case 'select':
        final currentValue = _selectedOptions[key];
        final items = field.options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option, overflow: TextOverflow.ellipsis),
          );
        }).toList();

        if (currentValue != null &&
            currentValue.isNotEmpty &&
            !field.options.contains(currentValue)) {
          items.add(
            DropdownMenuItem<String>(
              value: currentValue,
              child: Text(currentValue, overflow: TextOverflow.ellipsis),
            ),
          );
        }

        return DropdownButtonFormField<String>(
          key: fieldWidgetKey,
          initialValue: currentValue,
          isExpanded: true,
          decoration: _decoration(field.label, field.required),
          items: items,
          validator: (val) {
            if (field.required && (val == null || val.trim().isEmpty)) {
              return '${field.label} is required';
            }
            return null;
          },
          onChanged: (val) {
            setState(() => _selectedOptions[key] = val);
            widget.onChanged?.call(getCustomFieldPayload());
          },
        );

      case 'date':
        final selectedDate = _selectedDates[key];
        return InkWell(
          key: fieldWidgetKey,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _selectedDates[key] = picked);
              widget.onChanged?.call(getCustomFieldPayload());
            }
          },
          child: InputDecorator(
            decoration: _decoration(field.label, field.required).copyWith(
              suffixIcon: const Icon(Icons.calendar_today, size: 20),
            ),
            child: Text(
              selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedDate)
                  : 'Select date',
              style: TextStyle(
                color: selectedDate != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        );

      case 'radio':
        return Column(
          key: fieldWidgetKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              field.required ? '${field.label} *' : field.label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              children: field.options.map((opt) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: opt,
                      groupValue: _selectedOptions[key],
                      onChanged: (val) {
                        setState(() => _selectedOptions[key] = val);
                        widget.onChanged?.call(getCustomFieldPayload());
                      },
                    ),
                    Text(opt),
                  ],
                );
              }).toList(),
            ),
          ],
        );

      case 'checkbox':
        if (field.options.isEmpty) {
          final isChecked = _singleCheckboxes[key] ?? false;
          return CheckboxListTile(
            key: fieldWidgetKey,
            contentPadding: EdgeInsets.zero,
            title: Text(field.required ? '${field.label} *' : field.label),
            value: isChecked,
            onChanged: (val) {
              setState(() => _singleCheckboxes[key] = val ?? false);
              widget.onChanged?.call(getCustomFieldPayload());
            },
            controlAffinity: ListTileControlAffinity.leading,
          );
        } else {
          final selectedSet = _selectedCheckboxes[key] ?? <String>{};
          return Column(
            key: fieldWidgetKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                field.required ? '${field.label} *' : field.label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                children: field.options.map((opt) {
                  final checked = selectedSet.contains(opt);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: checked,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedSet.add(opt);
                            } else {
                              selectedSet.remove(opt);
                            }
                            _selectedCheckboxes[key] = selectedSet;
                          });
                          widget.onChanged?.call(getCustomFieldPayload());
                        },
                      ),
                      Text(opt),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        }

      case 'textarea':
        if (!_textControllers.containsKey(key)) {
          _textControllers[key] = TextEditingController();
        }
        return TextFormField(
          key: fieldWidgetKey,
          controller: _textControllers[key],
          maxLines: 3,
          decoration: _decoration(field.label, field.required),
          validator: (v) => _validateInput(field, v),
          onChanged: (_) => widget.onChanged?.call(getCustomFieldPayload()),
        );

      case 'number':
        if (!_textControllers.containsKey(key)) {
          _textControllers[key] = TextEditingController();
        }
        return TextFormField(
          key: fieldWidgetKey,
          controller: _textControllers[key],
          keyboardType: TextInputType.number,
          decoration: _decoration(field.label, field.required),
          validator: (v) => _validateInput(field, v),
          onChanged: (_) => widget.onChanged?.call(getCustomFieldPayload()),
        );

      case 'email':
        if (!_textControllers.containsKey(key)) {
          _textControllers[key] = TextEditingController();
        }
        return TextFormField(
          key: fieldWidgetKey,
          controller: _textControllers[key],
          keyboardType: TextInputType.emailAddress,
          decoration: _decoration(field.label, field.required),
          validator: (v) => _validateInput(field, v),
          onChanged: (_) => widget.onChanged?.call(getCustomFieldPayload()),
        );

      case 'phone':
        if (!_textControllers.containsKey(key)) {
          _textControllers[key] = TextEditingController();
        }
        return TextFormField(
          key: fieldWidgetKey,
          controller: _textControllers[key],
          keyboardType: TextInputType.phone,
          decoration: _decoration(field.label, field.required),
          validator: (v) => _validateInput(field, v),
          onChanged: (_) => widget.onChanged?.call(getCustomFieldPayload()),
        );

      case 'text':
      default:
        if (!_textControllers.containsKey(key)) {
          _textControllers[key] = TextEditingController();
        }
        return TextFormField(
          key: fieldWidgetKey,
          controller: _textControllers[key],
          keyboardType: TextInputType.text,
          decoration: _decoration(field.label, field.required),
          validator: (v) => _validateInput(field, v),
          onChanged: (_) => widget.onChanged?.call(getCustomFieldPayload()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.campaignId == null || widget.campaignId!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                "Loading campaign fields...",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        margin: EdgeInsets.only(bottom: widget.spacing),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 20, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Failed to load campaign fields: $_error",
                style: TextStyle(fontSize: 13, color: Colors.red.shade900),
              ),
            ),
            TextButton(
              onPressed: () => _fetchFields(forceRefresh: true),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_fields.isEmpty) {
      return const SizedBox.shrink();
    }

    final fieldWidgets = _fields.map((field) {
      final item = _buildFieldItem(field);
      return _wrapField(item);
    }).toList();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                "Campaign Fields",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${_fields.length}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...fieldWidgets,
        ],
      ),
    );
  }
}
