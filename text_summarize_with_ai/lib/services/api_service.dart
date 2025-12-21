import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiKey = String.fromEnvironment('HF_TOKEN');
  static const Map<String, String> modeller = {
    "BART (Dengeli)": "facebook/bart-large-cnn",
    "DistilBART (Hızlı)": "sshleifer/distilbart-cnn-12-6",
    "Pegasus (Akademik)": "google/pegasus-xsum",
  };
  static Future<String> metniOzetle(String metin, String modelPath) async {
    final String apiUrl =
        "https://router.huggingface.co/hf-inference/models/$modelPath";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
          "x-wait-for-model": "true",
        },
        body: jsonEncode({"inputs": metin}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> result = jsonDecode(response.body);
        return result[0]['summary_text'];
      } else {
        return "Hata: API yanıt vermedi (${response.statusCode})";
      }
    } catch (e) {
      return "Bağlantı Hatası: $e";
    }
  }
}
