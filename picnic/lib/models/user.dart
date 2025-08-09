class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final bool isPrivate;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.isPrivate = false,
  });

  User copyWith({
    String? name,
    String? email,
    String? profileImageUrl,
    String? bio,
    bool? isPrivate,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}