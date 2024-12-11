import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UsernameStatusChecker(),
    );
  }
}

class UsernameStatusChecker extends StatefulWidget {
  @override
  _UsernameStatusCheckerState createState() => _UsernameStatusCheckerState();
}

class _UsernameStatusCheckerState extends State<UsernameStatusChecker> {
  final TextEditingController _usernameController = TextEditingController();
  Map<String, String>? _statuses;
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
    _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      try {
        // Replace with your API endpoint for status check
        final response = await http.post(Uri.parse('http://localhost:6665/api/v1/indicator/$username'));
        if (response.statusCode == 200) {
          setState(() {
            _statuses = Map<String, String>.from(jsonDecode(response.body));
          });
        } else {
          print('Failed to fetch statuses: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching statuses: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Username Status Checker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Enter a username',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _startStatusCheck(value.trim());
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text.trim();
                if (username.isNotEmpty) {
                  _startStatusCheck(username);
                }
              },
              child: Text('Start Checking Status'),
            ),
            if (_statuses != null) ...[
              SizedBox(height: 16),
              Text(
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