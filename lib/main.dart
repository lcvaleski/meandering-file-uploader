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

  final String _filePath = '/Users/loganvaleski/git_projects/file_uploader/lib/file.wav';
  File myFile = File('/Users/loganvaleski/git_projects/file_uploader/lib/file.wav');

  final record = AudioRecorder();

  Future<void> _recordFile() async {
    try {
      if (await record.hasPermission()) {
        await record.start(
            const RecordConfig(
              encoder: AudioEncoder.wav,
            ),
            path: _filePath
        );
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
    record.dispose();
    _createVoice(myFile);
  }

  Future<String?> _createVoice(File file) async {
    var uri = Uri.parse('http://meandering.loganvaleski.workers.dev/create-voice');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path, filename: basename(file.path)));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    await File(_filePath).delete();
    return response.reasonPhrase;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title) ,
      ),
      body:
        Center(
          child: Column(
            children: [
              ElevatedButton(onPressed: _recordFile, child: const Text("Start recording")),
              ElevatedButton(onPressed: _stopRecord, child: const Text("Stop recording")),
            ],
          ),
        ),
    );
  }
}
