// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArkMessage _$ArkMessageFromJson(Map<String, dynamic> json) => ArkMessage(
  role: json['role'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$ArkMessageToJson(ArkMessage instance) =>
    <String, dynamic>{'role': instance.role, 'content': instance.content};

ArkResponse _$ArkResponseFromJson(Map<String, dynamic> json) => ArkResponse(
  id: json['id'] as String?,
  object: json['object'] as String?,
  created: (json['created'] as num?)?.toInt(),
  model: json['model'] as String?,
  choices: (json['choices'] as List<dynamic>?)
      ?.map((e) => ArkChoice.fromJson(e as Map<String, dynamic>))
      .toList(),
  usage: json['usage'] == null
      ? null
      : ArkUsage.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ArkResponseToJson(ArkResponse instance) =>
    <String, dynamic>{
      if (instance.id != null) 'id': instance.id,
      if (instance.object != null) 'object': instance.object,
      if (instance.created != null) 'created': instance.created,
      if (instance.model != null) 'model': instance.model,
      if (instance.choices != null) 'choices': instance.choices,
      if (instance.usage != null) 'usage': instance.usage,
    };

ArkChoice _$ArkChoiceFromJson(Map<String, dynamic> json) => ArkChoice(
  index: (json['index'] as num?)?.toInt(),
  delta: json['delta'] == null
      ? null
      : ArkDelta.fromJson(json['delta'] as Map<String, dynamic>),
  finishReason: json['finish_reason'] as String?,
);

Map<String, dynamic> _$ArkChoiceToJson(ArkChoice instance) => <String, dynamic>{
  if (instance.index != null) 'index': instance.index,
  if (instance.delta != null) 'delta': instance.delta,
  if (instance.finishReason != null) 'finish_reason': instance.finishReason,
};

ArkDelta _$ArkDeltaFromJson(Map<String, dynamic> json) => ArkDelta(
  role: json['role'] as String?,
  content: json['content'] as String?,
);

Map<String, dynamic> _$ArkDeltaToJson(ArkDelta instance) => <String, dynamic>{
  if (instance.role != null) 'role': instance.role,
  if (instance.content != null) 'content': instance.content,
};

ArkUsage _$ArkUsageFromJson(Map<String, dynamic> json) => ArkUsage(
  promptTokens: (json['prompt_tokens'] as num?)?.toInt(),
  completionTokens: (json['completion_tokens'] as num?)?.toInt(),
  totalTokens: (json['total_tokens'] as num?)?.toInt(),
);

Map<String, dynamic> _$ArkUsageToJson(ArkUsage instance) => <String, dynamic>{
  if (instance.promptTokens != null) 'prompt_tokens': instance.promptTokens,
  if (instance.completionTokens != null)
    'completion_tokens': instance.completionTokens,
  if (instance.totalTokens != null) 'total_tokens': instance.totalTokens,
};
