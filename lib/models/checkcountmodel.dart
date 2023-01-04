// To parse this JSON data, do
//
//     final count = countFromJson(jsonString);

import 'dart:convert';

List<Count> countFromJson(String str) =>
    List<Count>.from(json.decode(str).map((x) => Count.fromJson(x)));

String countToJson(List<Count> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Count {
  Count({
    this.count,
  });

  String? count;

  factory Count.fromJson(Map<String, dynamic> json) => Count(
        count: json["count"] == null ? null : json["count"],
      );

  Map<String, dynamic> toJson() => {
        "count": count == null ? null : count,
      };
}
