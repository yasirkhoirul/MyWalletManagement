import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/data/model/receipt_result_model.dart';
import 'package:uuid/uuid.dart';

/// Remote datasource for processing receipts with AI
abstract class ReceiptRemoteDataSource {
  Future<ReceiptAnalysisResult?> processReceipt(File imageFile);
}

class ReceiptRemoteDataSourceImpl implements ReceiptRemoteDataSource {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Gemini Flash model for fast processing
  late final GenerativeModel _model;

  ReceiptRemoteDataSourceImpl() {
    _model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  @override
  Future<ReceiptAnalysisResult?> processReceipt(File imageFile) async {
    Reference? uploadedRef;
    try {
      // 1. Check auth user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User belum login');
      }
      String uid = user.uid;

      // 2. Upload to Firebase Storage (temporary for AI processing)
      String fileName = 'users/$uid/receipts/${const Uuid().v4()}.jpg';
      uploadedRef = _storage.ref().child(fileName);

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded_by': uid},
      );

      await uploadedRef.putFile(imageFile, metadata);

      // 3. Process with Gemini AI
      final imageBytes = await imageFile.readAsBytes();

      final prompt = TextPart('''
Analisa gambar struk/receipt ini. Ekstrak data menjadi JSON murni (tanpa markdown):
{
  "total_amount": (Number, contoh: 50000),
  "date": "YYYY-MM-DD",
  "category": "makanan|transportasi|belanja|hiburan|kesehatan|pendidikan|tagihan|lainnya",
  "items": "Daftar item/detail pembelian dalam satu string dan harganya"
}

Catatan:
- total_amount harus angka saja tanpa simbol mata uang
- category harus salah satu dari: makanan, transportasi, belanja, hiburan, kesehatan, pendidikan, tagihan, lainnya
- items berisi ringkasan item yang dibeli
- Jika tidak bisa membaca, kembalikan null untuk field tersebut
''');

      final imagePart = InlineDataPart('image/jpeg', imageBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      // 4. Delete from Firebase Storage after getting AI response (save storage)
      try {
        await uploadedRef.delete();
      } catch (_) {
        // Ignore delete errors - file cleanup is best effort
      }

      // 5. Parse AI response
      String? jsonString = response.text;
      if (jsonString != null) {
        // Clean markdown if present
        jsonString = jsonString
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        Map<String, dynamic> result = jsonDecode(jsonString);

        // Parse category
        ExpenseCategory? category;
        if (result['category'] != null) {
          final catStr = result['category'].toString().toLowerCase();
          category = ExpenseCategory.values
              .where((c) => c.name.toLowerCase() == catStr)
              .firstOrNull;
        }

        // Parse date
        DateTime? date;
        if (result['date'] != null) {
          try {
            date = DateTime.parse(result['date']);
          } catch (_) {}
        }

        // Return local file path instead of URL (save locally only)
        return ReceiptAnalysisResult(
          amount: result['total_amount']?.toDouble(),
          description: result['items'],
          category: category,
          date: date,
          receiptUrl: imageFile.path, // Local path instead of download URL
        );
      }

      // Return just the local path if AI parsing failed
      return ReceiptAnalysisResult(receiptUrl: imageFile.path);
    } catch (e) {
      // Clean up if upload succeeded but processing failed
      if (uploadedRef != null) {
        try {
          await uploadedRef.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }
}
