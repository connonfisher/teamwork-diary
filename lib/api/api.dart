import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:moodiary/common/models/ark.dart';
import 'package:moodiary/common/models/geo.dart';
import 'package:moodiary/common/models/hitokoto.dart';
import 'package:moodiary/common/models/image.dart';
import 'package:moodiary/common/models/weather.dart';
import 'package:moodiary/l10n/l10n.dart';
import 'package:moodiary/persistence/pref.dart';
import 'package:moodiary/utils/http_util.dart';
import 'package:moodiary/utils/notice_util.dart';

class Api {
  static Future<Stream<String>?> getArkChat(
    String apiKey,
    String endpoint,
    List<ArkMessage> messages,
    int model, {
    bool showErrorToast = true,
  }) async {
    final arkModel = switch (model) {
      0 => 'doubao-seed-2.0-lite',
      1 => 'doubao-seed-2.0-pro',
      2 => 'doubao-seed-2.0-code',
      _ => 'doubao-seed-2.0-lite',
    };

    final body = {
      'model': arkModel,
      'messages': messages.map((value) => value.toJson()).toList(),
      'stream': true,
    };

    final header = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    // 简化路径处理：只在必要时补全 /chat/completions
    String url = endpoint;
    if (!url.endsWith('/chat/completions')) {
      if (url.endsWith('/')) {
        url += 'chat/completions';
      } else {
        url += '/chat/completions';
      }
    }

    if (showErrorToast) {
      return await HttpUtil().postStream(url, header: header, data: body);
    } else {
      return await HttpUtil().postStreamNoErrorToast(
        url,
        header: header,
        data: body,
      );
    }
  }

  static Future<Uint8List?> getImageData(String url) async {
    return (await HttpUtil().get(url, type: ResponseType.bytes)).data;
  }

  static Future<List<String>?> updatePosition(BuildContext context) async {
    Position? position;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && context.mounted) {
        toast.info(message: context.l10n.noticeEnableLocation);
        return null;
      }
      if (permission == LocationPermission.deniedForever && context.mounted) {
        toast.info(message: context.l10n.noticeEnableLocation2);
        return null;
      }
    }
    if (await Geolocator.isLocationServiceEnabled()) {
      position = await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true,
      );
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(forceLocationManager: true),
      );
    }
    if (position != null && context.mounted) {
      final local = Localizations.localeOf(context);
      final parameters = {
        'location':
            '${double.parse(position.longitude.toStringAsFixed(2))},${double.parse(position.latitude.toStringAsFixed(2))}',
        'key': PrefUtil.getValue<String>('qweatherKey'),
        'lang': local,
      };
      final res = await HttpUtil().get(
        'https://${PrefUtil.getValue<String>('qweatherApiHost')}/geo/v2/city/lookup',
        parameters: parameters,
      );
      final geo = await compute(
        GeoResponse.fromJson,
        res.data as Map<String, dynamic>,
      );
      if (geo.location != null && geo.location!.isNotEmpty) {
        final city = geo.location!.first;
        return [
          position.latitude.toString(),
          position.longitude.toString(),
          '${city.adm2} ${city.name}',
        ];
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<List<String>?> updateWeather({
    required BuildContext context,
    required LatLng position,
  }) async {
    final local = Localizations.localeOf(context);
    final parameters = {
      'location':
          '${double.parse(position.longitude.toStringAsFixed(2))},${double.parse(position.latitude.toStringAsFixed(2))}',
      'key': PrefUtil.getValue<String>('qweatherKey'),
      'lang': local,
    };
    final res = await HttpUtil().get(
      'https://${PrefUtil.getValue<String>('qweatherApiHost')}/v7/weather/now',
      parameters: parameters,
    );
    final weather = await compute(
      WeatherResponse.fromJson,
      res.data as Map<String, dynamic>,
    );
    if (weather.now != null) {
      return [weather.now!.icon!, weather.now!.temp!, weather.now!.text!];
    } else {
      return null;
    }
  }

  static Future<List<String>?> updateHitokoto() async {
    final res = await HttpUtil().get('https://v1.hitokoto.cn');
    final hitokoto = await compute(
      HitokotoResponse.fromJson,
      res.data as Map<String, dynamic>,
    );
    return [hitokoto.hitokoto!];
  }

  static Future<List<String>?> updateImageUrl() async {
    final res = await HttpUtil().get(
      'https://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1',
    );
    final BingImage bingImage = await compute(
      BingImage.fromJson,
      res.data as Map<String, dynamic>,
    );
    return ['https://cn.bing.com${bingImage.images?[0].url}'];
  }
}
