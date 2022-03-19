import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/models/difficulty.dart';

import '../screens/create_quiz/create_quiz_controller.dart';

DefaultFormField(
  String labelText,
  TextEditingController controller, {
  bool obscureText = false,
  Icon? prefixIcon,
  Icon? suffixIcon,
  TextInputType? keyboardType,
  GestureTapCallback? onFieldTap,
  bool? isReadOnly,
  FormFieldValidator? validator,
  ValueChanged<String>? onFieldChanged,
}) {
  return TextFormField(
    onChanged: onFieldChanged,
    onTap: onFieldTap,
    keyboardType: keyboardType,
    controller: controller,
    obscureText: obscureText,
    readOnly: isReadOnly ?? false,
    validator: validator,
    decoration: InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelText: labelText,
    ),
  );
}

//same as map function but with index
Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;

  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}

DifficultySelector(
    Difficulty difficulty, CreateQuizController createQuizController) {
  return Container(
    margin: const EdgeInsets.all(MyTheme.smallPadding),
    child: InkWell(
      onTap: () {
        createQuizController.selectedDifficulty.value = difficulty;
      },
      child: CircleAvatar(
        radius: 25.0,
        backgroundColor:
            difficulty == createQuizController.selectedDifficulty.value
                ? Colors.grey[400]
                //todo handle unselected color in dark mode
                : Colors.white,
        child: CircleAvatar(
          backgroundColor: difficulty.difficultyType == 'easy'.tr
              ? Colors.green
              : difficulty.difficultyType == 'medium'.tr
                  ? Colors.yellow
                  : Colors.red,
          radius: 20.0,
        ),
      ),
    ),
  );
}
