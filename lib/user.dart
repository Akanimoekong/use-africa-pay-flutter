class User {
  final String email;
  final String? name;
  final String? phonenumber;
  final String? phone; // a fallback

  User({
    required this.email,
    this.name,
    this.phonenumber,
    this.phone,
  });
}
