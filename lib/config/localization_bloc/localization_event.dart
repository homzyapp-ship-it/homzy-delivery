import 'package:equatable/equatable.dart';

abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedLocale extends LocalizationEvent {}

class ChangeLocale extends LocalizationEvent {
  final String languageCode;

  const ChangeLocale(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class ResetLocale extends LocalizationEvent {}
