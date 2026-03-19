class Project {
  final String id;
  final String title;
  final String description;
  final String? imageAsset;
  final List<String> techStack;
  final String? githubUrl;
  final String? liveUrl;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    this.imageAsset,
    required this.techStack,
    this.githubUrl,
    this.liveUrl,
  });
}
