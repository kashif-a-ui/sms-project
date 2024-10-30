import 'dart:convert';

TeacherModel teacherModelFromJson(String str) =>
    TeacherModel.fromJson(json.decode(str));

String teacherModelToJson(TeacherModel data) => json.encode(data.toJson());

class TeacherModel {
  TeacherModel({
    required this.name,
    required this.email,
    required this.id,
    required this.password,
    required this.qualification,
    required this.mClass,
    required this.incharge,
  });

  String name, email, id, password, qualification, mClass;
  bool incharge;

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        name: json["name"],
        email: json["email"],
        id: json["id"],
        password: json["password"],
        qualification: json["qualification"],
        mClass: json["class"],
        incharge: json["incharge"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "id": id,
        "password": password,
        "qualification": qualification,
        "class": mClass,
        "incharge": incharge,
      };
}
