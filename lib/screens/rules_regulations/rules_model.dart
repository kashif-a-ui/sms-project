
class RuleModel {
  RuleModel({required this.rule, required this.id});

  final String rule, id;

  factory RuleModel.fromJson(Map<String, dynamic> json) =>
      RuleModel(rule: json["rule"], id: json["id"]);

  Map<String, dynamic> toJson() => {"rule": rule, "id": id};
}
