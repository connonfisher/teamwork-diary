import 'package:json_annotation/json_annotation.dart';

part 'ark.g.dart';

@JsonSerializable()
class ArkMessage {
  @JsonKey(name: 'role')
  final String role;

  @JsonKey(name: 'content')
  final String content;

  ArkMessage({required this.role, required this.content});

  factory ArkMessage.fromJson(Map<String, dynamic> json) =>
      _$ArkMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ArkMessageToJson(this);
}

@JsonSerializable()
class ArkResponse {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'object')
  final String? object;

  @JsonKey(name: 'created')
  final int? created;

  @JsonKey(name: 'model')
  final String? model;

  @JsonKey(name: 'choices')
  final List<ArkChoice>? choices;

  @JsonKey(name: 'usage')
  final ArkUsage? usage;

  ArkResponse({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
  });

  factory ArkResponse.fromJson(Map<String, dynamic> json) =>
      _$ArkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ArkResponseToJson(this);
}

@JsonSerializable()
class ArkChoice {
  @JsonKey(name: 'index')
  final int? index;

  @JsonKey(name: 'delta')
  final ArkDelta? delta;

  @JsonKey(name: 'finish_reason')
  final String? finishReason;

  ArkChoice({this.index, this.delta, this.finishReason});

  factory ArkChoice.fromJson(Map<String, dynamic> json) =>
      _$ArkChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ArkChoiceToJson(this);
}

@JsonSerializable()
class ArkDelta {
  @JsonKey(name: 'role')
  final String? role;

  @JsonKey(name: 'content')
  final String? content;

  ArkDelta({this.role, this.content});

  factory ArkDelta.fromJson(Map<String, dynamic> json) =>
      _$ArkDeltaFromJson(json);

  Map<String, dynamic> toJson() => _$ArkDeltaToJson(this);
}

@JsonSerializable()
class ArkUsage {
  @JsonKey(name: 'prompt_tokens')
  final int? promptTokens;

  @JsonKey(name: 'completion_tokens')
  final int? completionTokens;

  @JsonKey(name: 'total_tokens')
  final int? totalTokens;

  ArkUsage({this.promptTokens, this.completionTokens, this.totalTokens});

  factory ArkUsage.fromJson(Map<String, dynamic> json) =>
      _$ArkUsageFromJson(json);

  Map<String, dynamic> toJson() => _$ArkUsageToJson(this);
}
