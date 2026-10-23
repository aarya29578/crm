import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_campaigns_response.dart';
import 'package:crm_flutter/api/response/all_lead_stage_response.dart'
    as stage_model;
import 'package:crm_flutter/api/response/all_leads_response.dart' hide State;
import 'package:crm_flutter/api/response/all_leads_response.dart' as lead_model;
import 'package:crm_flutter/api/response/all_sources_response.dart'
    as source_model;
import 'package:crm_flutter/api/response/location_response.dart';
import 'package:crm_flutter/api/response/substatus_lead_stage_response.dart';
import 'package:crm_flutter/pages/Allocations/components/searchable_sub_status_field.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';

class EditAllocationLeadDialog extends StatefulWidget {
  final Data lead;

  const EditAllocationLeadDialog({super.key, required this.lead});

  @override
  State<EditAllocationLeadDialog> createState() =>
      _EditAllocationLeadDialogState();
}

class _EditAllocationLeadDialogState extends State<EditAllocationLeadDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _middleName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _pincode;
  late final TextEditingController _company;
  late final TextEditingController _age;
  late final TextEditingController _remarks;

  final _priorityOptions = const ['Hot', 'Warm', 'Cold', 'Very Hot', 'Dead'];
  final _genderOptions = const ['Male', 'Female', 'Other'];

  List<source_model.Data> _sources = [];
  List<stage_model.Data> _stages = [];
  List<SubStatusData> _subStatuses = [];
  List<CampaignData> _campaigns = [];
  List<LocationData> _countries = [];
  List<LocationData> _states = [];
  List<LocationData> _cities = [];
  List<Map<String, dynamic>> _users = [];

  String? _sourceId;
  String? _stageId;
  String? _subStatusId;
  String? _campaignId;
  String? _assignedUserId;
  String? _countryId;
  String? _stateId;
  String? _cityId;
  String? _priority;
  String? _gender;
  DateTime? _followUpDate;

  bool _optionsLoaded = false;
  bool _saving = false;
  String? _optionError;
  String? _saveError;

  Data get _lead => widget.lead;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: _lead.name?.first ?? '');
    _middleName = TextEditingController(text: _lead.name?.middle ?? '');
    _lastName = TextEditingController(text: _lead.name?.last ?? '');
    _phone = TextEditingController(text: _lead.phone?.toString() ?? '');
    _email = TextEditingController(text: _lead.email ?? '');
    _address = TextEditingController(text: _lead.address ?? '');
    _pincode = TextEditingController(text: _lead.pincode?.toString() ?? '');
    _company = TextEditingController(text: _lead.companyName ?? '');
    _age = TextEditingController(text: _lead.age?.toString() ?? '');
    _remarks = TextEditingController(text: _lead.remarks ?? '');

    _sourceId = _lead.leadSourceId?.sId;
    _stageId = _lead.leadStageId?.sId;
    _subStatusId = _lead.subStatusId?.sId;
    _campaignId = _lead.compaignName?.sId;
    _assignedUserId = _lead.assignedTo?.sId;
    _countryId = _lead.location?.country?.sId;
    _stateId = _lead.location?.state?.sId;
    _cityId = _lead.location?.city?.sId;
    _priority = _lead.priority;
    _gender = _lead.gender;
    _followUpDate = _lead.followUpDate?.toLocal();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    await Future.wait([
      _loadSources(),
      _loadStages(),
      _loadCampaigns(),
      _loadCountries(),
      _loadUsers(),
    ]);

    if (_countryId != null) await _loadStates(_countryId!, update: false);
    if (_stateId != null) await _loadCities(_stateId!, update: false);
    if (_stageId != null) await _loadSubStatuses(_stageId!);
    if (mounted) setState(() => _optionsLoaded = true);
  }

  Future<void> _loadSources() async {
    try {
      final response = await DioApi().getAllSources();
      _sources = response.data ?? [];
    } catch (error) {
      _recordOptionError(error);
    }
  }

  Future<void> _loadStages() async {
    try {
      final response = await DioApi().getAllLeadStage();
      _stages = response.data ?? [];
    } catch (error) {
      _recordOptionError(error);
    }
  }

  Future<void> _loadCampaigns() async {
    try {
      final response = await DioApi().getAllCampaigns();
      _campaigns = response.data ?? [];
    } catch (error) {
      _recordOptionError(error);
    }
  }

  Future<void> _loadCountries() async {
    try {
      final response = await DioApi().getCountries();
      _countries = response.data ?? [];
    } catch (error) {
      _recordOptionError(error);
    }
  }

  Future<void> _loadStates(String countryId, {bool update = true}) async {
    try {
      final response = await DioApi().getStates(countryId);
      if (!mounted || (update && countryId != _countryId)) return;
      setState(() {
        _states = response.data ?? [];
        if (update) {
          _stateId = null;
          _cityId = null;
          _cities = [];
        }
      });
    } catch (error) {
      _recordOptionError(error);
    }
  }

  Future<void> _loadCities(String stateId, {bool update = true}) async {
    try {
      final response = await DioApi().getCities(stateId);
      if (!mounted || (update && stateId != _stateId)) return;
      setState(() {
        _cities = response.data ?? [];
        if (update) _cityId = null;
      });
    } catch (error) {
      _recordOptionError(error);
    }
  }

  Future<void> _loadSubStatuses(String stageId) async {
    try {
      final response = await DioApi().getFailedSubLeadStage(
        selectedStageId: stageId,
      );
      if (!mounted || stageId != _stageId) return;
      setState(() => _subStatuses = response.data ?? []);
    } catch (error) {
      _recordOptionError(error);
    }
  }

  Future<void> _loadUsers() async {
    try {
      final response = await DioApi().getAllUsers(limit: 100);
      final responseData = response.data;
      final List<dynamic>? users = responseData is List
          ? responseData
          : responseData is Map && responseData['data'] is List
          ? responseData['data'] as List
          : null;
      if (users != null) {
        _users = users
            .whereType<Map>()
            .map((user) => Map<String, dynamic>.from(user))
            .toList();
      }
    } catch (error) {
      _recordOptionError(error);
    }
  }

  void _recordOptionError(Object error) {
    if (_optionError != null) return;
    if (mounted) {
      setState(() => _optionError = error.toString());
    } else {
      _optionError = error.toString();
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _pincode.dispose();
    _company.dispose();
    _age.dispose();
    _remarks.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {String? helperText}) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      border: const OutlineInputBorder(),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return TextFormField(
      key: ValueKey(
        'edit-lead-${label.toLowerCase().replaceAll(' ', '-')}-field',
      ),
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: _decoration(label, helperText: helperText),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final knownValue = items.any((item) => item.value == value);
    final resolvedItems = [...items];
    if (value != null && !knownValue) {
      resolvedItems.add(
        DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis),
        ),
      );
    }
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value-${resolvedItems.length}'),
      initialValue: value,
      isExpanded: true,
      decoration: _decoration(label),
      items: resolvedItems,
      onChanged: onChanged,
    );
  }

  List<DropdownMenuItem<String>> _optionItems(
    Iterable<(String?, String?)> options,
  ) {
    return options
        .where((option) => option.$1 != null && option.$1!.isNotEmpty)
        .map(
          (option) => DropdownMenuItem<String>(
            value: option.$1,
            child: Text(
              option.$2 ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();
  }

  String? _validateOptionalInt(String? value, String label) {
    if (value == null || value.trim().isEmpty) return null;
    return int.tryParse(value.trim()) == null
        ? '$label must be a number'
        : null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : 'Enter a valid email address';
  }

  Future<void> _selectFollowUpDate() async {
    final now = DateTime.now();
    final initial = _followUpDate ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    setState(() {
      _followUpDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{};

    final newFirst = _firstName.text.trim();
    final newMiddle = _middleName.text.trim();
    final newLast = _lastName.text.trim();
    if (newFirst != (_lead.name?.first ?? '') ||
        newMiddle != (_lead.name?.middle ?? '') ||
        newLast != (_lead.name?.last ?? '')) {
      payload['name'] = {
        'first': newFirst,
        'middle': newMiddle,
        'last': newLast,
      };
    }

    final phone = _phone.text.trim();
    if (phone != (_lead.phone?.toString() ?? '')) {
      payload['phone'] = phone.isEmpty ? null : int.parse(phone);
    }
    _addChangedString(payload, 'email', _email, _lead.email);
    _addChangedString(payload, 'address', _address, _lead.address);
    final pincode = _pincode.text.trim();
    if (pincode != (_lead.pincode?.toString() ?? '')) {
      payload['pincode'] = pincode.isEmpty ? null : int.parse(pincode);
    }
    _addChangedString(payload, 'company_name', _company, _lead.companyName);
    _addChangedString(payload, 'remarks', _remarks, _lead.remarks);
    final age = _age.text.trim();
    if (age != (_lead.age?.toString() ?? '')) {
      payload['age'] = age.isEmpty ? null : int.parse(age);
    }

    if (_sourceId != _lead.leadSourceId?.sId) {
      payload['lead_source_id'] = _sourceId;
    }
    if (_stageId != _lead.leadStageId?.sId) {
      payload['lead_stage_id'] = _stageId;
    }
    if (_subStatusId != _lead.subStatusId?.sId) {
      payload['sub_status_id'] = _subStatusId;
    }
    if (_campaignId != _lead.compaignName?.sId) {
      payload['campaign'] = _campaignId;
    }
    if (_assignedUserId != _lead.assignedTo?.sId) {
      payload['assignedTo'] = _assignedUserId;
    }
    if (_priority != _lead.priority) payload['priority'] = _priority;
    if (_gender != _lead.gender) payload['gender'] = _gender;

    final originalCountry = _lead.location?.country?.sId;
    final originalState = _lead.location?.state?.sId;
    final originalCity = _lead.location?.city?.sId;
    if (_countryId != originalCountry ||
        _stateId != originalState ||
        _cityId != originalCity) {
      payload['location'] = {
        'country': _countryId,
        'state': _stateId,
        'city': _cityId,
      };
    }

    final currentFollowUp = _lead.followUpDate?.toLocal();
    if (_followUpDate != currentFollowUp) {
      payload['followUpDate'] = _followUpDate?.toUtc().toIso8601String();
    }

    return payload;
  }

  void _addChangedString(
    Map<String, dynamic> payload,
    String key,
    TextEditingController controller,
    String? original,
  ) {
    final value = controller.text.trim();
    if (value != (original ?? '')) payload[key] = value;
  }

  Data _updatedLeadFromForm() {
    final updated = Data.fromJson(_lead.toJson());
    updated.name = Name(
      first: _firstName.text.trim(),
      middle: _middleName.text.trim(),
      last: _lastName.text.trim(),
    );
    updated.phone = int.tryParse(_phone.text.trim());
    updated.email = _email.text.trim();
    updated.address = _address.text.trim();
    updated.pincode = int.tryParse(_pincode.text.trim());
    updated.companyName = _company.text.trim();
    updated.age = int.tryParse(_age.text.trim());
    updated.remarks = _remarks.text.trim();
    updated.priority = _priority;
    updated.gender = _gender;
    updated.followUpDate = _followUpDate?.toUtc();
    if (_sourceId != _lead.leadSourceId?.sId) {
      updated.leadSourceId = _sourceId == null
          ? null
          : LeadSourceId(
              sId: _sourceId,
              name: _sources
                  .where((source) => source.sId == _sourceId)
                  .firstOrNull
                  ?.name,
            );
    }
    if (_stageId != _lead.leadStageId?.sId) {
      updated.leadStageId = _stageId == null
          ? null
          : LeadStageId(
              sId: _stageId,
              name: _stages
                  .where((stage) => stage.sId == _stageId)
                  .firstOrNull
                  ?.name,
            );
    }
    if (_subStatusId != _lead.subStatusId?.sId) {
      updated.subStatusId = _subStatusId == null
          ? null
          : LeadSourceId(
              sId: _subStatusId,
              name: _subStatuses
                  .where((status) => status.id == _subStatusId)
                  .firstOrNull
                  ?.name,
            );
    }
    if (_campaignId != _lead.compaignName?.sId) {
      updated.compaignName = _campaignId == null
          ? null
          : CompaignName(
              sId: _campaignId,
              name: _campaigns
                  .where((campaign) => campaign.sId == _campaignId)
                  .firstOrNull
                  ?.name,
            );
    }
    if (_assignedUserId != _lead.assignedTo?.sId) {
      updated.assignedTo = _assignedUserId == null
          ? null
          : AssignedTo(
              sId: _assignedUserId,
              name: _users
                  .where((user) => user['_id']?.toString() == _assignedUserId)
                  .firstOrNull?['name']
                  ?.toString(),
            );
    }
    if (_countryId != _lead.location?.country?.sId ||
        _stateId != _lead.location?.state?.sId ||
        _cityId != _lead.location?.city?.sId) {
      updated.location = _buildLocation();
    }
    return updated;
  }

  Country? _countryById(List<LocationData> options, String? id) {
    if (id == null) return null;
    final option = options.where((item) => item.sId == id).firstOrNull;
    if (option != null) return Country(sId: id, name: option.name);
    if (_lead.location?.country?.sId == id) {
      return Country(sId: id, name: _lead.location?.country?.name);
    }
    return Country(sId: id);
  }

  lead_model.State? _stateById(List<LocationData> options, String? id) {
    if (id == null) return null;
    final option = options.where((item) => item.sId == id).firstOrNull;
    if (option != null) return lead_model.State(sId: id, name: option.name);
    if (_lead.location?.state?.sId == id) {
      return lead_model.State(sId: id, name: _lead.location?.state?.name);
    }
    return lead_model.State(sId: id);
  }

  City? _cityById(List<LocationData> options, String? id) {
    if (id == null) return null;
    final option = options.where((item) => item.sId == id).firstOrNull;
    if (option != null) return City(sId: id, name: option.name);
    if (_lead.location?.city?.sId == id) {
      return City(sId: id, name: _lead.location?.city?.name);
    }
    return City(sId: id);
  }

  Location? _buildLocation() => Location(
    country: _countryById(_countries, _countryId),
    state: _stateById(_states, _stateId),
    city: _cityById(_cities, _cityId),
  );

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    Map<String, dynamic> payload;
    Data updated;
    try {
      payload = _buildPayload();
      updated = _updatedLeadFromForm();
    } catch (error) {
      setState(() => _saveError = error.toString());
      return;
    }

    if (payload.isEmpty) {
      Navigator.of(context).pop(updated);
      return;
    }

    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final leadId = _lead.sId;
      if (leadId == null || leadId.isEmpty) {
        throw StateError('Lead ID is not available');
      }
      await DioApi().patchLead(leadId, payload);
      if (mounted) Navigator.of(context).pop(updated);
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
    final screenHeight = MediaQuery.sizeOf(context).height;
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Edit Lead'),
          if (_saveError != null) ...[
            const SizedBox(height: 8),
            Text(
              _saveError!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
      content: SizedBox(
        width: 600,
        height: screenHeight * 0.64,
        child: !_optionsLoaded
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_optionError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Some dropdown options could not be loaded. '
                          'Current values are preserved. $_optionError',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ),
                    _textField('First Name', _firstName),
                    const SizedBox(height: 12),
                    _textField('Middle Name', _middleName),
                    const SizedBox(height: 12),
                    _textField('Last Name', _lastName),
                    const SizedBox(height: 12),
                    _textField(
                      'Phone Number',
                      _phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          _validateOptionalInt(value, 'Phone number'),
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      'Email',
                      _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    _textField('Address', _address, maxLines: 2),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: 'Country',
                      value: _countryId,
                      items: _optionItems(
                        _countries.map((item) => (item.sId, item.name)),
                      ),
                      onChanged: (value) async {
                        setState(() {
                          _countryId = value;
                          _stateId = null;
                          _cityId = null;
                          _states = [];
                          _cities = [];
                        });
                        if (value != null) await _loadStates(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: 'State',
                      value: _stateId,
                      items: _optionItems(
                        _states.map((item) => (item.sId, item.name)),
                      ),
                      onChanged: (value) async {
                        setState(() {
                          _stateId = value;
                          _cityId = null;
                          _cities = [];
                        });
                        if (value != null) await _loadCities(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: 'City',
                      value: _cityId,
                      items: _optionItems(
                        _cities.map((item) => (item.sId, item.name)),
                      ),
                      onChanged: (value) => setState(() => _cityId = value),
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      'Pincode',
                      _pincode,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          _validateOptionalInt(value, 'Pincode'),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: 'Lead Source',
                      value: _sourceId,
                      items: _optionItems(
                        _sources.map((item) => (item.sId, item.name)),
                      ),
                      onChanged: (value) => setState(() => _sourceId = value),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: 'Lead Stage',
                      value: _stageId,
                      items: _optionItems(
                        _stages.map((item) => (item.sId, item.name)),
                      ),
                      onChanged: (value) async {
                        setState(() {
                          _stageId = value;
                          _subStatusId = null;
                          _subStatuses = [];
                        });
                        if (value != null) await _loadSubStatuses(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SearchableSubStatusField(
                      subStatuses: _subStatuses,
                      selectedId: _subStatusId,
                      label: 'Sub-status',
                      decoration: _decoration('Sub-status'),
                      onChanged: (value) =>
                          setState(() => _subStatusId = value),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: 'Priority',
                      value: _priority,
                      items: _optionItems(
                        _priorityOptions.map((value) => (value, value)),
                      ),
                      onChanged: (value) => setState(() => _priority = value),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: 'Assigned Agent',
                      value: _assignedUserId,
                      items: _optionItems(
                        _users.map(
                          (user) => (
                            user['_id']?.toString(),
                            user['name']?.toString(),
                          ),
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => _assignedUserId = value),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: 'Campaign',
                      value: _campaignId,
                      items: _optionItems(
                        _campaigns.map((item) => (item.sId, item.name)),
                      ),
                      onChanged: (value) => setState(() => _campaignId = value),
                    ),
                    const SizedBox(height: 12),
                    _textField('Company Name', _company),
                    const SizedBox(height: 12),
                    _textField(
                      'Age',
                      _age,
                      keyboardType: TextInputType.number,
                      validator: (value) => _validateOptionalInt(value, 'Age'),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: 'Gender',
                      value: _gender,
                      items: _optionItems(
                        _genderOptions.map((value) => (value, value)),
                      ),
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: _decoration('Follow-up Date & Time'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _followUpDate == null
                                  ? 'Not set'
                                  : '${MaterialLocalizations.of(context).formatMediumDate(_followUpDate!)} '
                                        '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_followUpDate!))}',
                            ),
                          ),
                          IconButton(
                            onPressed: _selectFollowUpDate,
                            icon: const Icon(Icons.calendar_month),
                          ),
                          if (_followUpDate != null)
                            IconButton(
                              onPressed: () =>
                                  setState(() => _followUpDate = null),
                              icon: const Icon(Icons.clear),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _textField('Remarks', _remarks, maxLines: 3),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.MainPurpleBackground,
            foregroundColor: Colors.white,
          ),
          onPressed: _optionsLoaded && !_saving ? _save : null,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
