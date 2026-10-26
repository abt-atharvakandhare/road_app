// class GoogleServiceAccount {
//   static Map<String, dynamic>? _json;

//   static Future<Map<String, dynamic>> get json async {
//     if (_json == null) {
//       final base64Json = Config.googleServiceAccountJson;
//       if (base64Json.isEmpty) {
//         throw Exception('Google service account JSON not configured');
//       }
//       try {
//         final bytes = base64.decode(base64Json);
//         final jsonString = utf8.decode(bytes);
//         _json = json.decode(jsonString);
//       } catch (e) {
//         throw Exception('Failed to decode Google service account JSON: $e');
//       }
//     }
//     return _json!;
//   }

//   static Future<String> get privateKey async {
//     final jsonData = await json;
//     return jsonData['private_key'] as String;
//   }

//   static Future<String> get clientEmail async {
//     final jsonData = await json;
//     return jsonData['client_email'] as String;
//   }

//   static Future<String> get projectId async {
//     final jsonData = await json;
//     return jsonData['project_id'] as String;
//   }
// }
