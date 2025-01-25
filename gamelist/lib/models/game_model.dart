class Game {
  final String id;
  final String name;
  final String backgroundImage;
  final String releaseDate;

  Game({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.releaseDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Game && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Convert
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'backgroundImage': backgroundImage,
      'releaseDate': releaseDate,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'],
      backgroundImage: json['backgroundImage'],
      releaseDate: json['releaseDate'],
    );
  }
}