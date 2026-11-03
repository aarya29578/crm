class CampaignCustomFieldsResponse {
  final bool success;
  final String? id;
  final String? campaignId;
  final List<CampaignCustomField> fields;

  CampaignCustomFieldsResponse({
    this.success = false,
    this.id,
    this.campaignId,
    this.fields = const [],
  });

  factory CampaignCustomFieldsResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] == true || json['status'] == true;
    final rawData = json['data'];

    String? id;
    String? campaignId;
    List<CampaignCustomField> fields = [];

    if (rawData is Map<String, dynamic>) {
      id = rawData['_id']?.toString() ?? rawData['id']?.toString();
      campaignId = rawData['campaign']?.toString() ??
          rawData['campaignId']?.toString();
      if (rawData['fields'] is List) {
        fields = (rawData['fields'] as List)
            .whereType<Map>()
            .map((item) =>
                CampaignCustomField.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } else if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          final itemMap = Map<String, dynamic>.from(item);
          if (itemMap['fields'] is List) {
            id ??= itemMap['_id']?.toString() ?? itemMap['id']?.toString();
            campaignId ??= itemMap['campaign']?.toString() ??
                itemMap['campaignId']?.toString();
            fields.addAll(
              (itemMap['fields'] as List).whereType<Map>().map(
                    (f) => CampaignCustomField.fromJson(
                      Map<String, dynamic>.from(f),
                    ),
                  ),
            );
          } else if (itemMap.containsKey('label') ||
              itemMap.containsKey('name')) {
            fields.add(CampaignCustomField.fromJson(itemMap));
          }
        }
      }
    }

    return CampaignCustomFieldsResponse(
      success: success,
      id: id,
      campaignId: campaignId,
      fields: fields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        if (id != null) '_id': id,
        if (campaignId != null) 'campaign': campaignId,
        'fields': fields.map((f) => f.toJson()).toList(),
      },
    };
  }
}

class CampaignCustomField {
  final String? id;
  final String label;
  final String type;
  final List<String> options;
  final bool required;
  final bool mask;

  CampaignCustomField({
    this.id,
    required this.label,
    required this.type,
    this.options = const [],
    this.required = false,
    this.mask = false,
  });

  factory CampaignCustomField.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final List<String> parsedOptions = [];
    if (rawOptions is List) {
      for (final opt in rawOptions) {
        if (opt is String) {
          final trimmed = opt.trim();
          if (trimmed.isNotEmpty) parsedOptions.add(trimmed);
        } else if (opt is Map) {
          final val = opt['label'] ?? opt['value'] ?? opt['name'];
          if (val != null && val.toString().trim().isNotEmpty) {
            parsedOptions.add(val.toString().trim());
          }
        } else if (opt != null && opt.toString().trim().isNotEmpty) {
          parsedOptions.add(opt.toString().trim());
        }
      }
    }

    return CampaignCustomField(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      label: (json['label'] ?? json['name'] ?? json['fieldName'] ?? '')
          .toString()
          .trim(),
      type: (json['type'] ?? json['fieldType'] ?? 'text')
          .toString()
          .toLowerCase()
          .trim(),
      options: parsedOptions,
      required: json['required'] == true ||
          json['isMandatory'] == true ||
          json['mandatory'] == true,
      mask: json['mask'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'label': label,
      'type': type,
      'options': options,
      'required': required,
      'mask': mask,
    };
  }
}

