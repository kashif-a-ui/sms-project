class CalenderModel {
  CalenderModel(
      {required this.event,
      required this.description,
      required this.id,
      required this.date,
      required this.cDate,
      required this.month});

  final String event, description, id, date, cDate;
  final num month;

  factory CalenderModel.fromJson(Map<String, dynamic> json) => CalenderModel(
        event: json["event"],
        description: json["description"] ?? 'No description provided',
        id: json["id"],
        date: json["date"] ?? '',
        cDate: json["c_date"] ?? DateTime.now().toString(),
        month: json["month"] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        "event": event,
        "id": id,
        "date": date,
        "c_date": cDate,
        "feedback": description,
        "month": month,
      };
}
