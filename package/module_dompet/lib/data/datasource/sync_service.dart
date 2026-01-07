import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/data/datasource/db/dao.dart';
import 'package:module_dompet/data/datasource/db/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// SyncService handles offline-first sync with Firestore
class SyncService {
  final TransactionDao _transactionDao;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _lastSyncKey = 'last_sync_time';
  static const _uuid = Uuid();

  SyncService({
    required TransactionDao transactionDao,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _transactionDao = transactionDao,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  /// Generate a new UUID for transactions
  static String generateUuid() => _uuid.v4();

  /// Get the current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Get last sync time from SharedPreferences
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Save last sync time to SharedPreferences
  Future<void> saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }

  /// Clear last sync time (for testing or logout)
  Future<void> clearLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
  }

  /// Main sync method
  Future<SyncResult> performSync(int dompetId) async {
    final userId = _userId;
    if (userId == null) {
      return SyncResult(success: false, message: 'User not logged in');
    }

    try {
      final lastSync = await getLastSyncTime();

      int uploaded = 0;
      int deleted = 0;
      int downloaded = 0;

      // IMPORTANT: Process pending deletes FIRST before checking if local is empty
      // Otherwise deleted items make local appear empty and trigger download
      final pendingDeletes = await _transactionDao.getPendingDeletes();
      if (pendingDeletes.isNotEmpty) {
        print(
          'SyncService: Processing ${pendingDeletes.length} pending deletes first',
        );
        deleted = await processPendingDeletes(userId);
        print('SyncService: Processed $deleted pending deletes');
      }

      // Also upload pending changes first
      final pendingUploads = await _transactionDao.getPendingUploads();
      if (pendingUploads.isNotEmpty) {
        print(
          'SyncService: Uploading ${pendingUploads.length} pending uploads',
        );
        uploaded = await uploadPendingTransactions(userId);
        print('SyncService: Uploaded $uploaded pending transactions');
      }

      // Now check if local database is empty (after processing local changes)
      final localTransactions = await _transactionDao
          .getAllTransactionsForDompet(dompetId);
      final isLocalEmpty = localTransactions.isEmpty;

      if (lastSync == null || isLocalEmpty) {
        // New install/login OR local DB is empty - download everything
        print(
          'SyncService: Downloading all from Firestore (lastSync=$lastSync, isLocalEmpty=$isLocalEmpty)',
        );
        downloaded = await downloadAllFromFirestore(userId, dompetId);
        await saveLastSyncTime(DateTime.now());
        return SyncResult(
          success: true,
          message:
              'Sync complete: $uploaded uploaded, $deleted deleted, $downloaded downloaded',
          uploaded: uploaded,
          deleted: deleted,
          downloaded: downloaded,
        );
      }

      // Pull if > 1 day since last sync
      if (DateTime.now().difference(lastSync).inDays >= 1) {
        downloaded = await pullFromFirestore(userId, dompetId, since: lastSync);
        print('SyncService: Downloaded $downloaded from Firestore');
      }

      await saveLastSyncTime(DateTime.now());

      return SyncResult(
        success: true,
        message:
            'Sync complete: $uploaded uploaded, $deleted deleted, $downloaded downloaded',
        uploaded: uploaded,
        deleted: deleted,
        downloaded: downloaded,
      );
    } catch (e) {
      print('SyncService: Sync failed with error: $e');
      return SyncResult(success: false, message: 'Sync failed: $e');
    }
  }

  /// Upload all pending transactions to Firestore
  Future<int> uploadPendingTransactions(String userId) async {
    final pending = await _transactionDao.getPendingUploads();
    int count = 0;

    for (final tx in pending) {
      try {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(tx.uuid);

        await docRef.set({
          'amount': tx.amount,
          'description': tx.description ?? '',
          'expenseCategory': tx.expenseCategory?.name ?? '',
          'tanggal': Timestamp.fromDate(tx.tanggal),
          'type': tx.type.name,
          'updated_at': Timestamp.fromDate(tx.updatedAt),
        });

        await _transactionDao.markAsUploaded(tx.uuid);
        count++;
      } catch (e) {
        // Log error but continue with other transactions
        print('Failed to upload transaction ${tx.uuid}: $e');
      }
    }

    return count;
  }

  /// Process pending deletes - delete from Firestore and create deleted_log
  Future<int> processPendingDeletes(String userId) async {
    final pending = await _transactionDao.getPendingDeletes();
    int count = 0;

    for (final tx in pending) {
      try {
        // 1. Delete from Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(tx.uuid)
            .delete();

        // 2. Create deleted_log entry (for other devices)
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('deleted_log')
            .doc(tx.uuid)
            .set({'deletedAt': Timestamp.now()});

        // 3. Hard delete locally
        await _transactionDao.hardDeleteByUuid(tx.uuid);
        count++;
      } catch (e) {
        print('Failed to process delete for ${tx.uuid}: $e');
      }
    }

    return count;
  }

  /// Download all transactions from Firestore (first sync)
  Future<int> downloadAllFromFirestore(String userId, int dompetId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();

    int count = 0;

    for (final doc in snapshot.docs) {
      try {
        await _upsertFromDoc(doc, dompetId);
        count++;
      } catch (e) {
        print('Failed to download transaction ${doc.id}: $e');
      }
    }

    // Also check deleted_logs
    await applyDeletedLogs(userId);

    return count;
  }

  /// Pull changes from Firestore since last sync
  Future<int> pullFromFirestore(
    String userId,
    int dompetId, {
    required DateTime since,
  }) async {
    // Get transactions updated after lastSync
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('updated_at', isGreaterThan: Timestamp.fromDate(since))
        .get();

    int count = 0;

    for (final doc in snapshot.docs) {
      try {
        await _upsertFromDoc(doc, dompetId);
        count++;
      } catch (e) {
        print('Failed to pull transaction ${doc.id}: $e');
      }
    }

    // Check for deleted items
    await applyDeletedLogs(userId, since: since);

    return count;
  }

  /// Apply deleted_logs - remove local copies of deleted transactions
  Future<void> applyDeletedLogs(String userId, {DateTime? since}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(userId)
        .collection('deleted_log');

    if (since != null) {
      query = query.where(
        'deletedAt',
        isGreaterThan: Timestamp.fromDate(since),
      );
    }

    final snapshot = await query.get();

    for (final doc in snapshot.docs) {
      final uuid = doc.id;
      await _transactionDao.hardDeleteByUuid(uuid);
    }
  }

  /// Helper to upsert from Firestore document
  Future<void> _upsertFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    int dompetId,
  ) async {
    final data = doc.data();
    if (data == null) return;

    final tanggal = (data['tanggal'] as Timestamp).toDate();
    final updatedAt = (data['updated_at'] as Timestamp?)?.toDate() ?? tanggal;

    // Get or create dompet month for this transaction
    final dompetMonthId = await _transactionDao.getOrCreateDompetMonth(
      dompetId,
      tanggal.month,
      tanggal.year,
    );

    // Parse type
    TypeTransaction type = TypeTransaction.pengeluaran;
    final typeStr = data['type'] as String?;
    if (typeStr != null) {
      type = TypeTransaction.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => TypeTransaction.pengeluaran,
      );
    }

    // Parse expense category
    ExpenseCategory? category;
    final catStr = data['expenseCategory'] as String?;
    if (catStr != null && catStr.isNotEmpty) {
      category = ExpenseCategory.values.firstWhere(
        (c) => c.name == catStr,
        orElse: () => ExpenseCategory.lainnya,
      );
    }

    await _transactionDao.upsertFromFirestore(
      uuid: doc.id,
      amount: (data['amount'] as num).toDouble(),
      tanggal: tanggal,
      type: type,
      dompetMonthId: dompetMonthId,
      description: data['description'] as String?,
      expenseCategory: category,
      updatedAt: updatedAt,
    );
  }

  /// Check if there are pending items to sync
  Future<bool> hasPendingSync() async {
    final uploads = await _transactionDao.getPendingUploads();
    final deletes = await _transactionDao.getPendingDeletes();
    return uploads.isNotEmpty || deletes.isNotEmpty;
  }

  /// Get pending sync count
  Future<int> getPendingSyncCount() async {
    final uploads = await _transactionDao.getPendingUploads();
    final deletes = await _transactionDao.getPendingDeletes();
    return uploads.length + deletes.length;
  }
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String message;
  final int uploaded;
  final int deleted;
  final int downloaded;

  SyncResult({
    required this.success,
    required this.message,
    this.uploaded = 0,
    this.deleted = 0,
    this.downloaded = 0,
  });
}
