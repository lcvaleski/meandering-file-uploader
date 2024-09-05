import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Cartesia voice clone'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final record = AudioRecorder();

  final String _filePath =
      '/Users/loganvaleski/git_projects/file_uploader/lib/file.wav';
  File myFile =
      File('/Users/loganvaleski/git_projects/file_uploader/lib/file.wav');

  Future<void> _recordFile() async {
    final record = AudioRecorder();
    try {
      if (await record.hasPermission()) {
        await record.start(
            const RecordConfig(
              encoder: AudioEncoder.wav,
            ),
            path: _filePath);
      } else {
        print("Permission not granted");
      }
    } on PlatformException catch (e) {
      print("PlatformException: ${e.message}");
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> _stopRecord() async {
    record.stop();
    print(await _createVoice(myFile));
  }

  Future<String?> _createVoice(File file) async {
    var uri = Uri.parse('http://localhost:8787/create-voice');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path,
          filename: basename(file.path)));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    await File(_filePath).delete();
    return response.body;
  }

  Future<Object> _generateSample() async {
    final msg = jsonEncode({
      'transcript': 'Hello world',
      'id': 'a0e99841-438c-4a64-b679-ae501e7d6091'
    });
    final response = await http.post(
        Uri.parse('http://localhost:8787/generate-sample'),
        headers: {'Content-Type': 'application/json'},
        body: msg);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      return "Error ${response.statusCode}: ${response.body}";
    }
    await File(_filePath).delete();
    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: _recordFile, child: const Text("Start recording")),
            ElevatedButton(
                onPressed: _stopRecord, child: const Text("Stop recording")),
          ],
        ),
      ),
    );
  }
}
