import 'dart:convert';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/data/model/receipt_result_model.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Remote datasource for processing voice input with AI
abstract class VoiceRemoteDataSource {
  Future<bool> initialize();
  Future<void> startListening(void Function(String) onResult);
  Future<void> stopListening();
  Future<ReceiptAnalysisResult?> processVoiceText(String text);
  bool get isListening;
}

class VoiceRemoteDataSourceImpl implements VoiceRemoteDataSource {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  // Gemini Flash model for fast processing
  late final GenerativeModel _model;

  VoiceRemoteDataSourceImpl() {
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<void> startListening(void Function(String) onResult) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'id_ID', // Indonesian
    );
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
  }

  @override
  Future<ReceiptAnalysisResult?> processVoiceText(String text) async {
    try {
      final prompt = TextPart('''
Parse transaksi dari teks berikut: "$text"

PENTING: Kembalikan HANYA satu objek JSON (bukan array), dengan format:
{
  "total_amount": (Number, hitung total semua item jika ada beberapa),
  "category": "makanan|transportasi|belanja|hiburan|kesehatan|pendidikan|tagihan|lainnya",
  "items": "Deskripsi semua item dalam satu string"
}

Contoh:
- "beli makan ikan goreng 200 tempe 200" → {"total_amount": 400, "category": "makanan", "items": "Ikan goreng, tempe"}
- "beli makan 50 ribu" → {"total_amount": 50000, "category": "makanan", "items": "Makan"}
- "bayar gojek 25000" → {"total_amount": 25000, "category": "transportasi", "items": "Gojek"}

Catatan:
- Konversi "ribu" ke 1000 (50 ribu = 50000)
- Jika ada beberapa item, jumlahkan total_amount
- Gabungkan semua items dalam satu string
''');

      final response = await _model.generateContent([
        Content.multi([prompt]),
      ]);

      String? jsonString = response.text;
      if (jsonString != null) {
        jsonString = jsonString
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        // Handle case where AI returns array instead of object
        dynamic decoded = jsonDecode(jsonString);
        Map<String, dynamic> result;

        if (decoded is List) {
          // If array, take first item or combine all
          if (decoded.isEmpty) return null;
          if (decoded.length == 1) {
            result = decoded[0] as Map<String, dynamic>;
          } else {
            // Combine multiple items
            double totalAmount = 0;
            List<String> items = [];
            String? category;
            for (var item in decoded) {
              if (item is Map<String, dynamic>) {
                if (item['total_amount'] != null) {
                  totalAmount += (item['total_amount'] as num).toDouble();
                }
                if (item['items'] != null) {
                  items.add(item['items'].toString());
                }
                category ??= item['category']?.toString();
              }
            }
            result = {
              'total_amount': totalAmount,
              'category': category,
              'items': items.join(', '),
            };
          }
        } else if (decoded is Map<String, dynamic>) {
          result = decoded;
        } else {
          return null;
        }

        // Parse category
        ExpenseCategory? category;
        if (result['category'] != null) {
          final catStr = result['category'].toString().toLowerCase();
          category = ExpenseCategory.values
              .where((c) => c.name.toLowerCase() == catStr)
              .firstOrNull;
        }

        return ReceiptAnalysisResult(
          amount: result['total_amount'] != null
              ? (result['total_amount'] as num).toDouble()
              : null,
          description: result['items']?.toString(),
          category: category,
          date: DateTime.now(),
          receiptUrl: null,
        );
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }
}
