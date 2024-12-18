import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UsernameStatusChecker(),
    );
  }
}

class UsernameStatusChecker extends StatefulWidget {
  const UsernameStatusChecker({super.key});

  @override
  _UsernameStatusCheckerState createState() => _UsernameStatusCheckerState();
}

class _UsernameStatusCheckerState extends State<UsernameStatusChecker> {
  final TextEditingController _usernameController = TextEditingController();
  Map<String, String>? _statuses;
  String? _errorMessage;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _usernameController.dispose();
    super.dispose();
  }

  void _startStatusCheck(String username) {
    _statusTimer?.cancel(); // Cancel any existing timer
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        // Replace with your API endpoint for status check
        // final response = await http.post(Uri.parse('http://34.131.119.223:6665/api/v1/indicator/$username'));
        final response = await http.get(Uri.parse('http://localhost:6665/api/v1/indicator/$username'),
            headers: {'Referer': 'no-referrer'},);
        if (response.statusCode == 200) {
          setState(() {
            _statuses = Map<String, String>.from(jsonDecode(response.body));
            _errorMessage = null; // Clear any previous errors
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to fetch statuses: ${response.statusCode}';
            _statuses = null;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error fetching statuses: $e';
          _statuses = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Username Status Checker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter a username',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _startStatusCheck(value.trim());
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text.trim();
                if (username.isNotEmpty) {
                  _startStatusCheck(username);
                }
              },
              child: const Text('Start Checking Status'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
            if (_statuses != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Statuses:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView(
                  children: _statuses!.entries.map((entry) {
                    final color = entry.value == 'online' ? Colors.green : Colors.red;
                    return ListTile(
                      leading: Icon(Icons.circle, color: color),
                      title: Text(entry.key),
                      subtitle: Text(entry.value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
