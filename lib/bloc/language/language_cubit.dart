import 'package:hydrated_bloc/hydrated_bloc.dart';

class LanguageCubit extends HydratedCubit<String> {
  LanguageCubit() : super('en');
  
  void changeLanguage(String languageCode) {
    emit(languageCode);
  }

  @override
  String? fromJson(Map<String, dynamic> json) =>
      json['languageCode'] as String?;

  @override
  Map<String, dynamic>? toJson(String state) => {'languageCode': state};
}
