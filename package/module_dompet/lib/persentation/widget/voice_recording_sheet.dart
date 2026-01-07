import 'package:flutter/material.dart';
import 'package:module_dompet/data/datasource/voice_remote_datasource.dart';
import 'package:module_dompet/data/model/receipt_result_model.dart';

/// Bottom sheet widget for voice recording with animation
class VoiceRecordingSheet extends StatefulWidget {
  final VoiceRemoteDataSource voiceDataSource;
  final void Function(ReceiptAnalysisResult result) onResult;

  const VoiceRecordingSheet({
    super.key,
    required this.voiceDataSource,
    required this.onResult,
  });

  @override
  State<VoiceRecordingSheet> createState() => _VoiceRecordingSheetState();
}

class _VoiceRecordingSheetState extends State<VoiceRecordingSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isListening = false;
  bool _isProcessing = false;
  String _transcribedText = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initializeAndStart();
  }

  Future<void> _initializeAndStart() async {
    try {
      final initialized = await widget.voiceDataSource.initialize();
      if (!initialized) {
        setState(() => _errorMessage = 'Gagal inisialisasi speech recognition');
        return;
      }
      _startListening();
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _transcribedText = '';
      _errorMessage = null;
    });

    widget.voiceDataSource.startListening((text) {
      setState(() => _transcribedText = text);
      _processVoice(text);
    });
  }

  Future<void> _processVoice(String text) async {
    await widget.voiceDataSource.stopListening();
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    try {
      final result = await widget.voiceDataSource.processVoiceText(text);
      if (result != null && mounted) {
        widget.onResult(result);
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Tidak dapat memproses suara. Coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Gagal memproses: $e';
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    widget.voiceDataSource.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            _isProcessing ? 'Memproses...' : 'Bicara sekarang',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Text(
            _isProcessing
                ? 'AI sedang menganalisis'
                : 'Contoh: "beli makan 50 ribu"',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Animated mic
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = _isListening
                  ? 1.0 + (_pulseController.value * 0.2)
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.grey.shade200,
                    border: Border.all(
                      color: _isListening ? Colors.orange : Colors.grey,
                      width: 3,
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : Icon(
                          _isListening ? Icons.mic : Icons.mic_off,
                          size: 48,
                          color: _isListening ? Colors.orange : Colors.grey,
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Transcribed text
          if (_transcribedText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$_transcribedText"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Retry button
          if (!_isListening && !_isProcessing)
            ElevatedButton.icon(
              onPressed: _startListening,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),

          const SizedBox(height: 16),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}
