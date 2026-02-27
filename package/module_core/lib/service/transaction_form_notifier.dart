import 'package:flutter/foundation.dart';

/// Notifier for cross-widget communication between TransactionPage and MainScaffold.
///
/// TransactionPage updates [hasUnsavedChanges] when form data is modified.
/// MainScaffold calls [triggerSave] when center FAB is pressed on transaction tab.
/// MainScaffold checks [hasUnsavedChanges] before allowing tab switch.
class TransactionFormNotifier extends ChangeNotifier {
  bool _hasUnsavedChanges = false;
  VoidCallback? _onSaveRequested;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  /// Called by TransactionPage to register the save callback
  void registerSaveCallback(VoidCallback callback) {
    _onSaveRequested = callback;
  }

  /// Called by TransactionPage to unregister the save callback
  void unregisterSaveCallback() {
    _onSaveRequested = null;
  }

  /// Called by TransactionPage when form data changes
  void markAsChanged() {
    if (!_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  /// Called by TransactionPage after successful save or form reset
  void markAsSaved() {
    if (_hasUnsavedChanges) {
      _hasUnsavedChanges = false;
      notifyListeners();
    }
  }

  /// Called by MainScaffold center FAB to trigger save
  void triggerSave() {
    _onSaveRequested?.call();
  }
}
