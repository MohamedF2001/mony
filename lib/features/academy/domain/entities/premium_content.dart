import 'package:equatable/equatable.dart';

enum ContentType { ebook, course, template }

class PremiumContent extends Equatable {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final String category;
  final String url;
  final String thumbnailUrl;
  final bool isPremium;
  final String duration;

  const PremiumContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.url,
    this.thumbnailUrl = '',
    this.isPremium = true,
    this.duration = '',
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        category,
        url,
        thumbnailUrl,
        isPremium,
        duration,
      ];
}
