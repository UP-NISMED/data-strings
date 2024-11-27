import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:data_strings/src/db/models/answer.dart';
import 'package:http/http.dart' as http;

/* 
  This service is responsible for managing the answers.
  It can add answers, get all answers, and sync answers to a remote server.

  If the URL is set, the service will try to fetch the answers from the server.
*/

class AnswerService {
  final String _boxName = 'answerBox';
  String? url;

  Future<Box<Answer>> get _box async => await Hive.openBox<Answer>(_boxName);

  Future<void> testUrl(String url) async {
    // Try pinging the URL first
    final res = await http.get(Uri.parse(url));
    if (jsonDecode(res.body)['meta']['name'] != 'data-strings') {
      throw Exception('Unsupported server');
    }
  }

  Future<void> addAnswer(
      String firstName, String lastName, List<int> choices) async {
    final box = await _box;
    await box.add(
        Answer(firstName: firstName, lastName: lastName, choices: choices));
  }

  Future<List<Answer>> getAllAnswers() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> deleteAllAnswers() async {
    final box = await _box;
    box.clear();
  }

  Future<void> pullNewRemoteAnswers() async {
    final res = await http.get(Uri.parse(url!));
    final iterable = jsonDecode(res.body)['data'].map((answer) {
      return Answer(
          firstName: answer['firstName'],
          lastName: answer['lastName'],
          choices: List<int>.from(answer['choices']));
    });
    final remote = List<Answer>.from(iterable);

    final box = await _box;
    final local = box.values.toList();
    await box.addAll(remote.where((answer) {
      return !local.any((a) =>
          a.firstName == answer.firstName && a.lastName == answer.lastName);
    }));
  }

  Future<void> pushNewLocalAnswers() async {
    final box = await _box;
    final local = box.values.toList();
    final remote = await http.get(Uri.parse(url!)).then((res) {
      final iterable = jsonDecode(res.body)['data'].map((answer) {
        return Answer(
            firstName: answer['firstName'],
            lastName: answer['lastName'],
            choices: List<int>.from(answer['choices']));
      });
      return List<Answer>.from(iterable);
    });

    await Future.wait(local.where((answer) {
      return !remote.any((a) =>
          a.firstName == answer.firstName && a.lastName == answer.lastName);
    }).map((answer) async {
      await http.post(Uri.parse(url!),
          body: jsonEncode({
            'firstName': answer.firstName,
            'lastName': answer.lastName,
            'choices': answer.choices,
          }));
    }));
  }
}
