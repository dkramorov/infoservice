part of dash_chat_2;

/// {@category Models}
class ChatUser {
  ChatUser({
    required this.id,
    this.phone,
    this.name,
    this.profileImage,
    this.customProperties,
  });

  /// Create a ChatUser instance from json data
  factory ChatUser.fromJson(Map<String, dynamic> jsonData) {
    return ChatUser(
      id: jsonData['id'].toString(),
      profileImage: jsonData['profileImage']?.toString(),
      name: jsonData['name']?.toString(),
      phone: jsonData['phone']?.toString(),
      customProperties: jsonData['customProperties'] as Map<String, dynamic>,
    );
  }

  /// Id of the user
  String id;

  /// Profile image of the user
  String? profileImage;

  /// A list of custom properties to extend the existing ones
  /// in case you need to store more things.
  /// Can be useful to extend existing features
  Map<String, dynamic>? customProperties;

  /// First name of the user,
  /// if you only have the name as one string
  /// you can put the entire value in the [fristName] field
  String? name;

  /// Last name of the user
  String? phone;

  String getName() {
    return name ?? id;
  }

  /// Convert a ChatUser into a json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profileImage': profileImage,
      'name': name,
      'phone': phone,
      'customProperties': customProperties,
    };
  }
}
