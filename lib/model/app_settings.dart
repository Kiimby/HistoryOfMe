import 'package:hive/hive.dart';

part 'app_settings.g.dart';

/// A model class storing app-specific data, which may only be client-specific.
@HiveType(typeId: 3)
class AppSettings {
  @HiveField(0)
  final bool privacyPolicyAgreed;
  @HiveField(1)
  final bool darkMode;
  @HiveField(2)
  final int tabIndex;

  /// Creates a [AppSettings] object.
  const AppSettings({
    required this.privacyPolicyAgreed,
    required this.darkMode,
    required this.tabIndex,
  });

  /// Creates a [AppSettings] object by serializing the provided `Map` data.
  ///
  /// `JSON` decoding must be done before serialization.
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      privacyPolicyAgreed: json['privacyPolicyAgreed'] as bool,
      darkMode: json['darkMode'] as bool,
      tabIndex: json['tabIndex'] as int,
    );
  }

  /// Creates a `Map` object based on this [AppSettings] object.
  ///
  /// `JSON` encoding must be done after serialization.
  Map<String, dynamic> toJson() => {
        'privacyPolicyAgreed': privacyPolicyAgreed,
        'darkMode': darkMode,
        'tabIndex': tabIndex,
      };
}
