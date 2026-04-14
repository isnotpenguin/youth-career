class PolicyBenefit {
  final String label;
  final String value;

  const PolicyBenefit({required this.label, required this.value});

  Map<String, dynamic> toJson() => {"label": label, "value": value};
  static PolicyBenefit fromJson(Map<String, dynamic> json) =>
      PolicyBenefit(label: json["label"] as String, value: json["value"] as String);
}

enum PolicyCardStatus { eligible, maybe, ineligible, saved }

class PolicyCardData {
  final String id;
  final String title;
  final String? summary;
  final List<PolicyBenefit> benefits;
  final String? location;
  final String? educationBackground;
  final PolicyCardStatus status;
  final String? sourceUrl;
  final String updatedAtISO;

  const PolicyCardData({
    required this.id,
    required this.title,
    required this.benefits,
    required this.status,
    required this.updatedAtISO,
    this.summary,
    this.location,
    this.educationBackground,
    this.sourceUrl,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "summary": summary,
        "benefits": benefits.map((b) => b.toJson()).toList(),
        "location": location,
        "educationBackground": educationBackground,
        "status": status.name,
        "sourceUrl": sourceUrl,
        "updatedAtISO": updatedAtISO,
      };

  static PolicyCardData fromJson(Map<String, dynamic> json) => PolicyCardData(
        id: json["id"] as String,
        title: json["title"] as String,
        summary: json["summary"] as String?,
        benefits: (json["benefits"] as List<dynamic>)
            .map((e) => PolicyBenefit.fromJson(e as Map<String, dynamic>))
            .toList(),
        location: json["location"] as String?,
        educationBackground: json["educationBackground"] as String?,
        status: PolicyCardStatus.values.firstWhere((s) => s.name == (json["status"] as String)),
        sourceUrl: json["sourceUrl"] as String?,
        updatedAtISO: json["updatedAtISO"] as String,
      );
}

