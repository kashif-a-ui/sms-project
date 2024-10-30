

class AttendanceModel {
  AttendanceModel({
    required this.name,
    required this.rollNo,
    required this.date,
    required this.present,
  });

  final String name, rollNo, date;
  final bool present;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        name: json["name"],
        date: json["date"],
        present: json["present"],
        rollNo: json["roll_no"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "roll_no": rollNo,
        "present": present,
        "date": date,
      };
}

class AttendanceSheet {
  final String name, rollNo;
  final num present, absent;
  num total, percentage;

  AttendanceSheet({
    required this.name,
    required this.rollNo,
    required this.present,
    required this.absent,
    this.total = 1,
    this.percentage = 0.0,
  });

  factory AttendanceSheet.fromJson(Map<String, dynamic> json) =>
      AttendanceSheet(
        name: json["name"],
        rollNo: json["roll_no"],
        present: json["present"],
        absent: json["absent"],
      );
}

class AssignmentModel {
  final String date, description, subject, dueDate, id, title;

  AssignmentModel(
      {required this.date,
      required this.description,
      required this.subject,
      required this.dueDate,
      required this.id,
      required this.title});

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      AssignmentModel(
        date: json["date"],
        description: json["description"],
        subject: json["subject"],
        dueDate: json["due_date"],
        id: json["id"],
        title: json["title"],
      );
}

class SubjectModel {
  final String subject, id;

  SubjectModel({required this.subject, required this.id});

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json["id"],
        subject: json["subject"] ?? '',
      );
}

class TimetableModel {
  final String subject, id, time;

  TimetableModel({required this.subject, required this.id, required this.time});

  factory TimetableModel.fromJson(Map<String, dynamic> json) => TimetableModel(
        id: json["id"],
        subject: json["subject"] ?? '',
        time: json["time"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "subject": subject,
        "time": time,
      };
}

class ResultModel {
  final String name, rollNo;
  List<SubjectSheet> subjectsMarks;

  ResultModel(
      {required this.name, required this.rollNo, required this.subjectsMarks});
}

class SubjectSheet {
  final String subject, total, obtained;

  SubjectSheet(
      {required this.subject, required this.total, required this.obtained});

  factory SubjectSheet.fromJson(Map<String, dynamic> json) => SubjectSheet(
        subject: json["subject"],
        obtained: json["obtained"],
        total: json["total"],
      );
}
