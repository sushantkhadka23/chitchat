class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String userProfileUrl;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.userProfileUrl,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'userProfileUrl': userProfileUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      userProfileUrl: json['userProfileUrl'],
    );
  }
}
