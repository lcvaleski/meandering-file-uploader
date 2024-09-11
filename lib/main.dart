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
  AudioRecorder? _audioRecorder;
  bool _isRecording = false;
  final String _filePath =
      '/Users/loganvaleski/git_projects/file_uploader/lib/file.wav';

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder?.dispose();
    super.dispose();
  }

  Future<void> _recordFile() async {
    if (_isRecording) return;

    try {
      if (await _audioRecorder!.hasPermission()) {
        await _audioRecorder!.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: _filePath,
        );
        setState(() => _isRecording = true);
      } else {
        print("Permission not granted");
      }
    } catch (e) {
      print("An error occurred while starting recording: $e");
    }
  }

  List<double> _parseEmbedding(String jsonString) {
    Map<String, dynamic> jsonResponse = json.decode(jsonString);
    List<dynamic> embeddingList = jsonResponse['embedding'];
    return embeddingList.map((e) {
      if (e is double) return e;
      if (e is int) return e.toDouble();
      return double.parse(e.toString());
    }).toList();
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

  Future<Object> _generateSample(List<double> embedding) async {
    final msg = jsonEncode({
      'transcript': 'My name is Giacomo and I like the Jets, which is a hard thing to like.',
      'id': embedding
    });
    final response = await http.post(
        Uri.parse('http://localhost:8787/generate-audio-segment'),
        headers: {'Content-Type': 'application/json'},
        body: msg);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      return "Error ${response.statusCode}: ${response.body}";
    }
    return response.statusCode;
  }

  Future<void> _stopRecord() async {
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder!.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        final file = File(path);
        final embeddingJsonString = await _createVoice(file);
        if (embeddingJsonString != null) {
          List<double> embedding = _parseEmbedding(embeddingJsonString);
          print(await _generateSample(embedding));
        }
      }
    } catch (e) {
      print("An error occurred while stopping recording: $e");
    }
  }
  
  Future<String> _textSegmentRoute() async {
    var uri = Uri.parse('http://localhost:8787/generate-text-segment');
    var request = await http.post(uri);
    print(request.body);
    return request.body;
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
              onPressed: _isRecording ? null : _recordFile,
              child: Text(_isRecording ? "Recording..." : "Start recording"),
            ),

            ElevatedButton(
              onPressed: _isRecording ? _stopRecord : null,
              child: const Text("Stop recording"),
            ),
            ElevatedButton(
                onPressed: _textSegmentRoute,
                child: const Text("Test text segment route"),
            ),
            const Text(
                'Hi there! I’m cloning my voice on Cartesia. Cartesias Sonic model offers the fastest voice cloning on the planet—just record 10 to 15 seconds of audio, and youre all done. To clone your own voice, you can head over to the Cartesia playground at play.cartesia.ai.')
          ],
        ),
      ),
    );
  }
}