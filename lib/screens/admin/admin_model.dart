import 'dart:convert';

AdminModel adminModelFromJson(String str) =>
    AdminModel.fromJson(json.decode(str));

String adminModelToJson(AdminModel data) => json.encode(data.toJson());

class AdminModel {
  AdminModel({
    required this.name,
    required this.email,
    required this.id,
    required this.password,
  });

  String name;
  String email;
  String id;
  String password;

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
        name: json["name"],
        email: json["email"],
        id: json["id"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "id": id,
        "password": password,
      };
}
