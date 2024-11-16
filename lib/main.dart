import 'package:data_strings/src/pages/home.dart';
import 'package:data_strings/src/question.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

final questions = [
  const Question(text: 'Educational Attainment', choices: [
    'Elementary',
    'Junior High School',
    'Senior High School',
    'Undergraduate',
    'Graduate',
    'No Formal Education',
  ]),
  const Question(text: 'Sex Assigned at Birth', choices: [
    'Male',
    'Female',
  ]),
  const Question(text: 'I think, STEM is...', choices: [
    'Fulfilling',
    'Rewarding',
    'Fun',
    'Exciting',
  ]),
  const Question(text: 'What do I enjoy the most?', choices: [
    'Taking care of animals/plants',
    'Cooking',
    'Reading medical/scientific articles',
    'Being an advocate for climate change',
    'Going outdoors',
    'Volunteering to teach',
    'Coding and programming',
    'Managing content in social media',
    'Painting',
    'Tinkering, altering, and creating things',
    'Working with numbers and/or solving complex problems',
    'Budgeting money'
  ]),
  const Question(text: 'What field in STEM do I want to pursue?', choices: [
    'Agricultural Sciences',
    'Health and Clinical Sciences',
    'Life Sciences',
    'Natural Resources and Conservation',
    'Physical Sciences',
    'Science and Mathematics Education',
    'Computer Science',
    'Information Science',
    'Visual Arts and Design',
    'Engineering',
    'Mathematics',
    'Statistics',
  ]),
  const Question(
      text: 'What motivates me to pursue a career in STEM?',
      choices: [
        'Solving complex challenges',
        'Making a positive impact to society',
        'Financial stability and growth',
        'Passion for science, technology, and innovation',
      ]),
  const Question(text: 'How can I get closer to my dream career?', choices: [
    'Upskill',
    'Apply for college entrance exams',
    'Apply for scholarships',
    'Pursue graduate studies locally and/or abroad',
  ]),
  const Question(text: 'Will you be a DOST scholar?', choices: [
    'I WILL BE A DOST SCHOLAR!',
  ])
];
