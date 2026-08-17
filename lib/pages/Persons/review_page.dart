import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final Map<String, dynamic> formData;
  const ReviewPage({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    // Convert lists (like emails and numbers) into pretty strings
    final emails =
        (formData['email_ids'] as String)
            .split(RegExp(r'[,\n;]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final contacts =
        (formData['contact_numbers'] as String)
            .split(RegExp(r'[,\n;]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Review Person Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text("Name: ${formData['name']}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              "Job Title: ${formData['job_title']}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "Organization: ${formData['organization_id']}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text("Email IDs:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...emails.map((e) => Text("- $e")),
            SizedBox(height: 20),
            Text(
              "Contact Numbers:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...contacts.map((n) => Text("- $n")),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                ); // You can replace this with final submission logic
              },
              child: Text("Confirm & Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}
