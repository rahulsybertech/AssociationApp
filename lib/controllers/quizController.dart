// ignore_for_file: body_might_complete_normally_nullable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class QuizController extends GetxController {
  var isDataLoading = false.obs;
  var timeLeft = 25.obs;
  Timer? timer;
  var currentQuestionIndex = 0.obs;
  var selectedAnswer = ''.obs;
  var answered = false.obs;
  var isCorrect = false.obs;
  late List<Map<String, dynamic>> mcqs = [];
  var selectedCategory = "Easy".obs; //default easy
  var score = 0.obs;
  late var question;
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      mcqs = Get.arguments['mcqs'];
      selectedCategory.value = Get.arguments['category'];
      question = mcqs[currentQuestionIndex.value];
    }
    startTimer();
  }

  void startTimer() {
    timeLeft.value = 20;
    timer?.cancel(); // cancel existing timer
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        timer.cancel();
        generateNextQuestion(); //move the next question when timer finished
      }
    });
  }

  void generateNextQuestion() {
    if (currentQuestionIndex.value < mcqs.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswer.value = '';
      answered.value = false;
      question = mcqs[currentQuestionIndex.value];
      startTimer(); //restart timer for next question
    } else {
      showCompletionDialog();
    }
  }

  void showCompletionDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false, //prevent dismiss
      builder:
          (context) => AlertDialog(
            title: const Text("Quiz Completed!"),
            content: const Text("Congrats! You have finished all questions."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  showResultScreen(); // Go back to result screen
                  saveScore(); // save the score
                },
                child: const Text("Show result!"),
              ),
            ],
          ),
    );
  }

  void showResultScreen() {
   // Get.to(ResultScreen(score: score.value, total: mcqs.length, mcqs: mcqs));
  }

  Future<void> saveScore() async {
    var pastScores = GetStorage().read('past_scores') ?? [];
    pastScores.add('Score: ${score.value} ($selectedCategory)');
    GetStorage().write('past_scores', pastScores);
  }

  void checkAnswer(String selectedKey) {
    if (answered.value) return; //prevent multiple selections

    timer?.cancel(); //stop timer on selection
    final correctAnswer = mcqs[currentQuestionIndex.value]['correct_answer'];
    isCorrect.value = selectedKey == correctAnswer;

    selectedAnswer.value = selectedKey;
    answered.value = true;
    isCorrect = isCorrect;

    if (isCorrect.value) {
      score.value++;
    }
    // Store user's answer in mcqs list
    mcqs[currentQuestionIndex.value]['user_answer'] = selectedKey;

    //move to the next question after a short delay
    Future.delayed(const Duration(seconds: 1), generateNextQuestion);
  }

  @override
  void dispose() {
    timer?.cancel();

    Get.delete<QuizController>();
    super.dispose();
  }
}
