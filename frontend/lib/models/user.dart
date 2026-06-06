class User {
  final int id;
  final String email;
  final String fullName;
  final bool onboardingComplete;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.onboardingComplete,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        fullName: json['full_name'],
        onboardingComplete: json['onboarding_complete'] ?? false,
      );
}
