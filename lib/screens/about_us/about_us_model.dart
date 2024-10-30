class AboutUsModel {
  AboutUsModel({
    required this.title,
    required this.id,
    required this.description,
  });

  final String title, id, description;

  factory AboutUsModel.fromJson(Map<String, dynamic> json) => AboutUsModel(
        title: json["title"],
        id: json["id"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "id": id,
        "description": description,
      };
}
