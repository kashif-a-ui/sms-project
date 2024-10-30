

class StudentModel {
  StudentModel({
    required this.name,
    required this.email,
    required this.id,
    required this.password,
    required this.fatherName,
    required this.rollNo,
    required this.studentClass,
  });

  String name, fatherName, email, id, password, studentClass, rollNo;

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        name: json["name"],
        fatherName: json["father_name"],
        email: json["email"],
        studentClass: json["class"],
        rollNo: json["roll_no"],
        id: json["id"],
        password: json["password"] ?? '123123',
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "id": id,
        "password": password,
        "father_name": fatherName,
        "class": studentClass,
        "roll_no": rollNo,
      };
}
