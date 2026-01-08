import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:module_dompet/data/datasource/sync_service.dart';
import 'package:module_dompet/persentation/bloc/sync_bloc.dart';

// Mock classes
class MockSyncService extends Mock implements SyncService {}

void main() {
  group('SyncBloc', () {
    late SyncBloc syncBloc;
    late MockSyncService mockSyncService;

    setUp(() {
      mockSyncService = MockSyncService();
      syncBloc = SyncBloc(mockSyncService);
    });

    tearDown(() {
      syncBloc.close();
    });

    test('initial state is SyncInitial', () {
      expect(syncBloc.state, isA<SyncInitial>());
    });

    blocTest<SyncBloc, SyncState>(
      'emits [SyncInProgress, SyncSuccess] when StartSync is added and sync succeeds',
      setUp: () {
        when(() => mockSyncService.performSync(any())).thenAnswer(
          (_) async => SyncResult(
            success: true,
            message: 'Sync complete',
            uploaded: 1,
            downloaded: 0,
            deleted: 0,
          ),
        );
      },
      build: () => syncBloc,
      act: (bloc) => bloc.add(StartSync(1)),
      expect: () => [isA<SyncInProgress>(), isA<SyncSuccess>()],
      verify: (_) {
        verify(() => mockSyncService.performSync(1)).called(1);
      },
    );

    blocTest<SyncBloc, SyncState>(
      'emits [SyncInProgress, SyncError] when StartSync is added and sync fails',
      setUp: () {
        when(() => mockSyncService.performSync(any())).thenAnswer(
          (_) async =>
              SyncResult(success: false, message: 'Sync failed: Network error'),
        );
      },
      build: () => syncBloc,
      act: (bloc) => bloc.add(StartSync(1)),
      expect: () => [isA<SyncInProgress>(), isA<SyncError>()],
    );

    blocTest<SyncBloc, SyncState>(
      'emits [SyncInProgress, SyncError] when StartSync throws an exception',
      setUp: () {
        when(
          () => mockSyncService.performSync(any()),
        ).thenThrow(Exception('Connection error'));
      },
      build: () => syncBloc,
      act: (bloc) => bloc.add(StartSync(1)),
      expect: () => [isA<SyncInProgress>(), isA<SyncError>()],
    );

    blocTest<SyncBloc, SyncState>(
      'emits [SyncPendingCount] when CheckPendingSync is added',
      setUp: () {
        when(
          () => mockSyncService.getPendingSyncCount(),
        ).thenAnswer((_) async => 5);
      },
      build: () => syncBloc,
      act: (bloc) => bloc.add(CheckPendingSync()),
      expect: () => [
        isA<SyncPendingCount>().having((s) => s.count, 'count', 5),
      ],
    );
  });
}
