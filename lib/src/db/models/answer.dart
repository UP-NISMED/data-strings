import 'package:hive/hive.dart';

part 'answer.g.dart';

@HiveType(typeId: 1)
class Answer  {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final List<int> choices;

  Answer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.choices,
  }); 
}
