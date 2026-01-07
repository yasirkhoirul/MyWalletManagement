import 'package:equatable/equatable.dart';

abstract class AnalyzeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAnalyzeData extends AnalyzeEvent {
  final int dompetId;
  final int month;
  final int year;

  LoadAnalyzeData(this.dompetId, this.month, this.year);

  @override
  List<Object?> get props => [dompetId, month, year];
}
