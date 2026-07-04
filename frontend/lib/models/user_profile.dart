class UserProfile {
  final String fullName;
  final String email;
  final String mode;
  final String plan;
  final String? phoneNumber;
  final bool pushNotifications;
  final bool emailAlerts;
  final bool highRiskAlerts;
  final bool screeningReminders;

  const UserProfile({
    required this.fullName,
    required this.email,
    this.mode = 'parent',
    this.plan = 'free',
    this.phoneNumber,
    this.pushNotifications = true,
    this.emailAlerts = true,
    this.highRiskAlerts = true,
    this.screeningReminders = false,
  });

  bool get isClinical => mode == 'clinical';

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    return UserProfile(
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      mode: data['mode'] as String? ?? 'parent',
      plan: data['plan'] as String? ?? 'free',
      phoneNumber: data['phoneNumber'] as String?,
      pushNotifications: settings['pushNotifications'] as bool? ?? true,
      emailAlerts: settings['emailAlerts'] as bool? ?? true,
      highRiskAlerts: settings['highRiskAlerts'] as bool? ?? true,
      screeningReminders: settings['screeningReminders'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'mode': mode,
        'plan': plan,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'settings': {
          'pushNotifications': pushNotifications,
          'emailAlerts': emailAlerts,
          'highRiskAlerts': highRiskAlerts,
          'screeningReminders': screeningReminders,
        },
      };
}
