

class FeedbackModel {
  FeedbackModel(
      {required this.name,
      required this.email,
      required this.id,
      required this.date,
      required this.feedback});

  final String name, feedback, email, id, date;

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        name: json["name"],
        feedback: json["feedback"],
        email: json["email"],
        id: json["id"],
        date: json["date"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "id": id,
        "date": date,
        "feedback": feedback,
      };
}
