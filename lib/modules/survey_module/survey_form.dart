import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/screens_controller.dart';
import '../../utils/color_constants.dart';

class SurveyFormScreen extends StatelessWidget {
  const SurveyFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Hostel Inspection Form", style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.primaryTeal,
            elevation: 4,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.tealAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryTeal.withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: AppColors.deepBlue, size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'Please fill the form below.',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Generate questions dynamically
                  ...controller.questionList.map((question) {
                    final answer = controller.answers[question.questionId];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${question.questionId}. ${question.questionText}',
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.deepBlue,
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (question.answerType == 'text')
                              TextFormField(
                                initialValue: answer,
                                onChanged: (value) => controller.setAnswer(question.questionId, value),
                                decoration: InputDecoration(
                                  hintText: 'Enter your answer here',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),

                            if (question.answerType == 'options')
                              ...?question.options?.map((opt) {
                                return RadioListTile<String>(
                                  title: Text(opt),
                                  value: opt,
                                  groupValue: answer,
                                  onChanged: (value) => controller.setAnswer(question.questionId, value!),
                                  activeColor: AppColors.primaryTeal,
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}