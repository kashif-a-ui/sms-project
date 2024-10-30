

class NoticeModel {
  NoticeModel(
      {required this.title,
      required this.image,
      required this.id,
      required this.date,
      required this.description,
      required this.active});

  final String title, description, image, id, date;
  bool active;

  factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
        title: json["title"],
        description: json["description"],
        image: json["image"],
        id: json["id"],
        active: json["active"],
        date: json["date"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "image": image,
        "id": id,
        "date": date,
        "description": description,
      };
}
