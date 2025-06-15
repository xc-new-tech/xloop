class OnboardingStep {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? animationUrl;
  final bool isRequired;
  final Map<String, dynamic>? metadata;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.animationUrl,
    this.isRequired = true,
    this.metadata,
  });

  OnboardingStep copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? animationUrl,
    bool? isRequired,
    Map<String, dynamic>? metadata,
  }) {
    return OnboardingStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      animationUrl: animationUrl ?? this.animationUrl,
      isRequired: isRequired ?? this.isRequired,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingStep &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.animationUrl == animationUrl &&
        other.isRequired == isRequired;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        animationUrl.hashCode ^
        isRequired.hashCode;
  }

  @override
  String toString() {
    return 'OnboardingStep(id: $id, title: $title, description: $description, imageUrl: $imageUrl, animationUrl: $animationUrl, isRequired: $isRequired, metadata: $metadata)';
  }
} 