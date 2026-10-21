class HistoryTimelineResponse {
  bool? success;
  int? total;
  List<HistoryTimelineEntry> data = [];

  HistoryTimelineResponse({this.success, this.total, required this.data});

  HistoryTimelineResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    total = _parseInt(json['total']);

    if (success == false) {
      throw const FormatException('The timeline request was not successful');
    }

    final responseData = json['data'];
    if (responseData is! List) {
      throw const FormatException(
        'Invalid lead timeline response: expected data to be a list',
      );
    }

    data = responseData.map((entry) {
      final record = _asStringKeyedMap(entry);
      if (record == null) {
        throw const FormatException(
          'Invalid lead timeline entry: expected an object',
        );
      }
      return HistoryTimelineEntry.fromJson(record);
    }).toList();
  }
}

class HistoryTimelineEntry {
  String? id;
  String? leadId;
  String? tenantId;
  String? action;
  HistoryTimelineAgent? changedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  Map<String, dynamic> changes = {};
  HistoryTimelineCall? callLog;
  HistoryTimelineTemplateUsage? templateUsage;

  HistoryTimelineEntry({
    this.id,
    this.action,
    this.changedBy,
    this.createdAt,
    this.updatedAt,
    Map<String, dynamic>? changes,
    this.callLog,
    this.templateUsage,
  }) : changes = changes ?? {};

  HistoryTimelineEntry.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString();
    leadId = json['lead_id']?.toString();
    tenantId = json['tenantId']?.toString();
    action = json['action']?.toString();

    final changedByJson = _asStringKeyedMap(json['changedBy']);
    changedBy = changedByJson == null
        ? null
        : HistoryTimelineAgent.fromJson(changedByJson);

    createdAt = _parseDateTime(json['createdAt']);
    updatedAt = _parseDateTime(json['updatedAt']);
    changes = _asStringKeyedMap(json['changes']) ?? {};

    final callLogJson = _asStringKeyedMap(json['call_log']);
    callLog = callLogJson == null
        ? null
        : HistoryTimelineCall.fromJson(callLogJson);

    final templateUsageJson = _asStringKeyedMap(json['template_usage']);
    templateUsage = templateUsageJson == null
        ? null
        : HistoryTimelineTemplateUsage.fromJson(templateUsageJson);
  }

  bool get isWhatsAppTemplate {
    if (templateUsage == null) return false;
    final channels = [
      templateUsage?.template?.channel,
      templateUsage?.usedBy?.channel,
    ].whereType<String>();
    return channels.any((channel) {
          final normalizedChannel = channel.toLowerCase();
          return normalizedChannel.contains('whatsapp') ||
              normalizedChannel == 'wa';
        }) ||
        action?.toLowerCase().contains('whatsapp') == true;
  }

  List<String> get changeDetails {
    return changes.entries
        .where((entry) => !_isIdentifier(entry.key))
        .map((entry) {
          final value = _formatValue(entry.value);
          if (value == null) return null;
          return '${_formatFieldName(entry.key)}: $value';
        })
        .whereType<String>()
        .toList();
  }

  List<String> get callDetails {
    final call = callLog;
    if (call == null) return [];

    return [
      if (_hasText(call.direction)) 'Direction: ${call.direction}',
      if (_hasText(call.status)) 'Status: ${call.status}',
      if (call.duration != null) 'Duration: ${call.duration}',
    ];
  }

  static String? _formatValue(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }
    if (value is num || value is bool) return value.toString();

    if (value is List) {
      final values = value.map(_formatValue).whereType<String>().toList();
      return values.isEmpty ? null : values.join(', ');
    }

    final map = _asStringKeyedMap(value);
    if (map == null) return null;

    final name = map['name'];
    if (name is String && name.trim().isNotEmpty) return name.trim();

    final values = map.entries
        .where((entry) => !_isIdentifier(entry.key))
        .map((entry) {
          final nestedValue = _formatValue(entry.value);
          if (nestedValue == null) return null;
          return '${_formatFieldName(entry.key)}: $nestedValue';
        })
        .whereType<String>()
        .toList();
    return values.isEmpty ? null : values.join(', ');
  }

  static bool _isIdentifier(String key) {
    return key == '_id' || key == 'lead_id' || key == 'tenantId';
  }

  static String _formatFieldName(String key) {
    switch (key) {
      case 'lead_stage_id':
        return 'Lead stage';
      case 'sub_status_id':
        return 'Sub-status';
      case 'assignedTo':
        return 'Assigned agent';
    }

    final words = key
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
        )
        .replaceAll('_', ' ');
    return words.isEmpty
        ? words
        : '${words[0].toUpperCase()}${words.substring(1)}';
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class HistoryTimelineAgent {
  String? id;
  String? name;
  String? email;

  HistoryTimelineAgent({this.id, this.name, this.email});

  HistoryTimelineAgent.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString();
    name = json['name']?.toString();
    email = json['email']?.toString();
  }
}

class HistoryTimelineCall {
  String? id;
  String? direction;
  dynamic duration;
  String? status;

  HistoryTimelineCall({this.id, this.direction, this.duration, this.status});

  HistoryTimelineCall.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString();
    direction = json['direction']?.toString();
    duration = json['duration'];
    status = json['status']?.toString();
  }
}

class HistoryTimelineTemplateUsage {
  HistoryTimelineTemplate? template;
  HistoryTimelineTemplateSender? usedBy;

  HistoryTimelineTemplateUsage({this.template, this.usedBy});

  HistoryTimelineTemplateUsage.fromJson(Map<String, dynamic> json) {
    final templateJson = _asStringKeyedMap(json['template_id']);
    template = templateJson == null
        ? null
        : HistoryTimelineTemplate.fromJson(templateJson);

    final usedByJson = _asStringKeyedMap(json['used_by']);
    usedBy = usedByJson == null
        ? null
        : HistoryTimelineTemplateSender.fromJson(usedByJson);
  }
}

class HistoryTimelineTemplate {
  String? name;
  String? channel;
  String? body;

  HistoryTimelineTemplate({this.name, this.channel, this.body});

  HistoryTimelineTemplate.fromJson(Map<String, dynamic> json) {
    name = json['name'] is String ? json['name'] as String : null;
    channel = json['channel'] is String ? json['channel'] as String : null;
    body = json['body'] is String ? json['body'] as String : null;
  }
}

class HistoryTimelineTemplateSender {
  String? name;
  String? channel;

  HistoryTimelineTemplateSender({this.name, this.channel});

  HistoryTimelineTemplateSender.fromJson(Map<String, dynamic> json) {
    name = json['name'] is String ? json['name'] as String : null;
    channel = json['channel'] is String ? json['channel'] as String : null;
  }
}

Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
  if (value is! Map) return null;
  return value.map((key, value) => MapEntry(key.toString(), value));
}

DateTime? _parseDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
