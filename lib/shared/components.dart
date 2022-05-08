import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/multiplayer_quiz/multiplayer_quiz_controller.dart';
import 'package:realtime_quizzes/shared/constants.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/single_player_quiz/single_player_quiz_controller.dart';

DefaultFormField({
  required String labelText,
  required TextEditingController controller,
  bool obscureText = false,
  Icon? prefixIcon,
  IconButton? suffixIcon,
  TextInputType? keyboardType,
  GestureTapCallback? onFieldTap,
  bool? isReadOnly,
  FormFieldValidator? validator,
  ValueChanged<String>? onFieldChanged,
  ValueChanged<String>? onFieldSubmitted,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: smallPadding),
    child: TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onFieldChanged,
      onTap: onFieldTap,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: obscureText,
      readOnly: isReadOnly ?? false,
      validator: validator,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelText: labelText,
      ),
    ),
  );
}

DefaultButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return Container(
    margin: const EdgeInsets.all(smallPadding),
    height: 50,
    width: double.infinity,
    child: Expanded(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(fontSize: 16),
        ),
        style: TextButton.styleFrom(
          primary: lighterCardColor,
          backgroundColor: cardColor,
        ),
      ),
    ),
  );
}

DefaultIconButton({
  required String text,
  required VoidCallback onPressed,
  required IconData? icon,
  double? height,
}) {
  height ??= 35;
  return Container(
    margin: EdgeInsets.all(smallPadding),
    height: height,
    child: TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(
            width: smallPadding,
          ),
          Text(
            text.toUpperCase(),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      style: TextButton.styleFrom(
        primary: lighterCardColor,
        backgroundColor: cardColor,
      ),
    ),
  );
}

MultiPlayerAnswerButton({
  required String text,
  required VoidCallback onPressed,
  required MultiPlayerQuizController multiPlayerQuizController,
  required BuildContext context,
  String? loggedPlayerImageUrl,
  String? otherPlayerImageUrl,
}) {
  bool useLoggedUserFallbackImage = false;
  if (loggedPlayerImageUrl == null) useLoggedUserFallbackImage = true;

  return Container(
    decoration: BoxDecoration(
      color: multiPlayerQuizController.getIsCorrectAnswer(text)
          ? Colors.green[200]
          : multiPlayerQuizController.getIsSelectedWrongAnswer(text)
              ? Colors.red[200]
              : multiPlayerQuizController.getIsSelectedLocalAnswer(text)
                  ? Colors.orange[200]
                  : Colors.white,
      border: Border.all(color: primaryTextColor),
      borderRadius: BorderRadius.circular(4),
    ),
    padding: EdgeInsets.all(4),
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          multiPlayerQuizController.getIsSelectedLoggedPlayer(text)
              ? DefaultCircularNetworkImage(
                  imageUrl: loggedPlayerImageUrl,
                  useLoggedUserFallbackImage: useLoggedUserFallbackImage,
                  width: 30,
                  height: 30)
              : const SizedBox(),
          multiPlayerQuizController.getIsSelectedOtherPlayer(text)
              ? DefaultCircularNetworkImage(
                  imageUrl: otherPlayerImageUrl, width: 30, height: 30)
              : const SizedBox(),
          const SizedBox(
            width: smallPadding,
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        primary: Colors.white,
      ),
    ),
  );
}

SinglePlayerAnswerButton({
  required String text,
  required String correctAnswer,
  required VoidCallback onPressed,
  required BuildContext context,
  required SinglePlayerQuizController singlePlayerQuizController,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: text == correctAnswer &&
              singlePlayerQuizController.isQuestionAnswered.value
          ? Colors.green[200]
          : text != correctAnswer &&
                  singlePlayerQuizController.isQuestionAnswered.value &&
                  singlePlayerQuizController.selectedAnswer.value == text
              ? Colors.red[200]
              : Colors.white,
      border: Border.all(color: primaryTextColor),
      borderRadius: BorderRadius.circular(4),
    ),
    padding: EdgeInsets.all(4),
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        primary: Colors.white,
      ),
    ),
  );
}

DefaultCircularNetworkImage({
  required String? imageUrl,
  double width = 70.0,
  double height = 70.0,
  bool useLoggedUserFallbackImage = false,
}) {
  return Container(
      margin: const EdgeInsets.all(smallPadding),
      child: CircleAvatar(
        radius: width / 2 + 3,
        backgroundColor: Colors.blueGrey,
        child: CachedNetworkImage(
          imageUrl: imageUrl ??
              (useLoggedUserFallbackImage
                  ? Constants.YOU_IMAGE
                  : 'https://firebasestorage.googleapis.com/v0/b/realtime-quizzes.appspot.com/o/user.png?alt=media&token=00fedb4a-b751-47f1-a8b6-34673648033a'),
          imageBuilder: (context, imageProvider) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ));

  return Container(
    margin: const EdgeInsets.all(smallPadding),
    width: width,
    height: height,
    child: ClipOval(
      child: CachedNetworkImage(
        fit: BoxFit.fill,
        placeholder: (context, url) => const SizedBox(
            width: 20, height: 20, child: CircularProgressIndicator()),
        imageUrl: imageUrl ??
            (useLoggedUserFallbackImage
                ? Constants.YOU_IMAGE
                : 'https://firebasestorage.googleapis.com/v0/b/realtime-quizzes.appspot.com/o/user.png?alt=media&token=00fedb4a-b751-47f1-a8b6-34673648033a'),
        errorWidget: (context, url, error) =>
            Image.asset('assets/images/user.png'),
      ),
    ),
  );
}

//show if user online or offline
DefaultStatusImage({
  required String? imageUrl,
  required bool? isOnline,
  double width = 70.0,
  double height = 70.0,
}) {
  isOnline ??= false;
  return Stack(
    children: [
      DefaultCircularNetworkImage(
          imageUrl: imageUrl, width: width, height: height),
      Positioned(
        bottom: 10,
        right: 10,
        child: isOnline
            ? CircleAvatar(
                backgroundColor: Colors.green,
                radius: (width.toInt() / 10.0),
              )
            : CircleAvatar(
                backgroundColor: Colors.red,
                radius: (width.toInt() / 10.0),
              ),
      )
    ],
  );
}

//show winner badge if user won
DefaultResultImage({
  required String? imageUrl,
  required bool? isWinner,
  var width = 100.0,
  var height = 100.0,
}) {
  isWinner ??= false;
  return Stack(
    children: [
      DefaultCircularNetworkImage(
          imageUrl: imageUrl, width: width, height: height),
      Positioned(
        bottom: 0,
        right: 0,
        child: isWinner
            ? Image.asset(
                'assets/images/win.png',
                width: 55,
                height: 55,
                color: lighterCardColor,
              )
            : const SizedBox(),
      )
    ],
  );
}

LoadingButton() {
  return Stack(children: [
    Container(
      height: 50,
      width: double.infinity,
      child: Expanded(
        child: TextButton(
          style: TextButton.styleFrom(
            primary: lighterCardColor,
            backgroundColor: cardColor,
          ),
          onPressed: () {},
          child: const Text(''),
        ),
      ),
    ),
    const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
    )
  ]);
}

GradientContainer({child}) {
  return Container(
    padding: const EdgeInsets.all(smallPadding),
    margin: const EdgeInsets.all(smallPadding),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(smallPadding),
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          lightCardColor,
          lighterCardColor,
        ],
      ),
    ),
    child: child,
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

//turns MillisecondsSinceEpoch into date time ago (ex: 5 minutes ago)
String formatTimeAgo(int millisecondsSinceEpoch) {
  return timeago
      .format(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch));
}
