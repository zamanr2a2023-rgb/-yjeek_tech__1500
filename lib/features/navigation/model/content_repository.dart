import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';

class AboutContent {
  const AboutContent({
    required this.title,
    required this.description,
    required this.platformTitle,
    required this.platformBody,
    required this.companyDetails,
    this.version,
    this.website,
  });

  final String title;
  final String description;
  final String platformTitle;
  final String platformBody;
  final List<(String, String)> companyDetails;
  final String? version;
  final String? website;

  factory AboutContent.fromJson(Map<String, dynamic> json) {
    final details = <(String, String)>[];
    final rawDetails = json['companyDetails'];
    if (rawDetails is List) {
      for (final row in rawDetails) {
        if (row is! Map) continue;
        final label = row['label']?.toString() ?? '';
        final value = row['value']?.toString() ?? '';
        if (label.isNotEmpty && value.isNotEmpty) {
          details.add((label, value));
        }
      }
    }
    if (details.isEmpty) {
      final company = json['company']?.toString();
      final country = json['country']?.toString();
      final website = json['website']?.toString();
      if (company != null && company.isNotEmpty) {
        details.add(('Operator', company));
      }
      if (country != null && country.isNotEmpty) {
        details.add(('Governing law', country));
      }
      if (website != null && website.isNotEmpty) {
        details.add(('Web', website.replaceFirst(RegExp(r'^https?://'), '')));
      }
    }

    final platform = json['platformIncludes'];
    final platformMap =
        platform is Map<String, dynamic> ? platform : const <String, dynamic>{};

    return AboutContent(
      title: json['title']?.toString() ?? 'About Yjeek',
      description: json['description']?.toString() ??
          json['tagline']?.toString() ??
          '',
      platformTitle:
          platformMap['title']?.toString() ?? 'The Yjeek platform includes',
      platformBody: platformMap['body']?.toString() ?? '',
      companyDetails: details,
      version: json['version']?.toString(),
      website: json['website']?.toString(),
    );
  }
}

class PolicyDocumentContent {
  const PolicyDocumentContent({
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<PolicySection> sections;

  factory PolicyDocumentContent.fromJson(Map<String, dynamic> json) {
    final sections = <PolicySection>[];
    final raw = json['sections'];
    if (raw is List) {
      for (final row in raw) {
        if (row is! Map) continue;
        final heading =
            row['heading']?.toString() ?? row['title']?.toString() ?? '';
        final body = row['body']?.toString() ?? '';
        if (heading.isEmpty && body.isEmpty) continue;
        sections.add(PolicySection(title: heading, body: body));
      }
    }

    final reference = json['reference']?.toString();
    final intro = json['intro']?.toString() ??
        [
          if (reference != null && reference.isNotEmpty) reference,
          if (json['updatedAt'] != null) 'Updated ${json['updatedAt']}',
        ].whereType<String>().join(' · ');

    return PolicyDocumentContent(
      title: json['title']?.toString() ?? 'Policy',
      intro: intro,
      sections: sections,
    );
  }
}

class HelpContent {
  const HelpContent({
    required this.title,
    required this.supportEmail,
    required this.supportPhone,
    required this.faq,
    this.topics = const [],
  });

  final String title;
  final String supportEmail;
  final String supportPhone;
  final List<({String q, String a})> faq;
  final List<({String id, String title, String body})> topics;

  factory HelpContent.fromJson(Map<String, dynamic> json) {
    final faq = <({String q, String a})>[];
    final raw = json['faq'];
    if (raw is List) {
      for (final row in raw) {
        if (row is! Map) continue;
        final q = row['q']?.toString() ?? row['question']?.toString() ?? '';
        final a = row['a']?.toString() ?? row['answer']?.toString() ?? '';
        if (q.isEmpty) continue;
        faq.add((q: q, a: a));
      }
    }
    final topics = <({String id, String title, String body})>[];
    final rawTopics = json['topics'];
    if (rawTopics is List) {
      for (final row in rawTopics) {
        if (row is! Map) continue;
        final title = row['title']?.toString() ?? '';
        if (title.isEmpty) continue;
        topics.add((
          id: row['id']?.toString() ?? title,
          title: title,
          body: row['body']?.toString() ?? '',
        ));
      }
    }
    return HelpContent(
      title: json['title']?.toString() ?? 'Help & Support',
      supportEmail: json['supportEmail']?.toString() ?? 'contact@yjeektech.com',
      supportPhone: json['supportPhone']?.toString() ?? '',
      faq: faq,
      topics: topics,
    );
  }

  /// Popular topic labels for Help & Support (FAQ first, else topic titles).
  List<String> get popularTopicLabels {
    if (faq.isNotEmpty) {
      return faq.take(4).map((e) => e.q).toList();
    }
    if (topics.isNotEmpty) {
      return topics.take(4).map((e) => e.title).toList();
    }
    return const [];
  }
}

class ContentRepository {
  const ContentRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AboutContent?> fetchAbout() async {
    final response = await _apiClient.getJson('/content/about');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return AboutContent.fromJson(data);
  }

  Future<PolicyDocumentContent?> fetchPolicy(String slug) async {
    final path = switch (slug) {
      'privacy' => '/content/privacy',
      'refund' || 'refund-policy' => '/content/refund-policy',
      'wallet' || 'wallet-terms' => '/content/wallet-terms',
      'consumer' || 'consumer-protection' => '/content/consumer-protection',
      _ => '/content/terms',
    };
    final response = await _apiClient.getJson(path);
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return PolicyDocumentContent.fromJson(data);
  }

  Future<HelpContent?> fetchHelp() async {
    final response = await _apiClient.getJson('/content/help');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return null;
    return HelpContent.fromJson(data);
  }

  /// GET /content/translations?lang= — full UI string catalog from backend.
  Future<Map<String, String>> fetchTranslations(String lang) async {
    final code = Uri.encodeQueryComponent(lang.trim().toLowerCase());
    final response = await _apiClient.getJson('/content/translations?lang=$code');
    final data = response?['data'];
    if (data is! Map<String, dynamic>) return const {};
    final strings = data['strings'];
    if (strings is! Map) return const {};
    final out = <String, String>{};
    strings.forEach((key, value) {
      if (key is! String) return;
      if (value is String && value.isNotEmpty) {
        out[key] = value;
      }
    });
    return out;
  }
}
