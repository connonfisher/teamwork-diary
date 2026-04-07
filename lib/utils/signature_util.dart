import 'package:moodiary/persistence/pref.dart';
import 'package:moodiary/utils/notice_util.dart';

class SignatureUtil {
  static Map<String, String>? checkArk() {
    final apiKey = PrefUtil.getValue<String>('arkApiKey');
    final endpoint = PrefUtil.getValue<String>('arkEndpoint');
    if (apiKey == null || endpoint == null) {
      toast.info(message: '请先配置火山方舟API Key和Endpoint');
      return null;
    } else {
      return {'apiKey': apiKey, 'endpoint': endpoint};
    }
  }
}
