import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/multiplayer_quiz/multiplayer_quiz_controller.dart';
import 'package:realtime_quizzes/shared/shared.dart';
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
  String? text,
  VoidCallback? onPressed,
  bool isLoading = false,
}) {
  return Container(
    margin: const EdgeInsets.all(smallPadding),
    height: 50,
    width: double.infinity,
    child: Expanded(
      child: TextButton(
        onPressed: onPressed ?? () {/*do nothing*/},
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white))))
            : Text(
                '${text}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
        style: TextButton.styleFrom(
          primary: darkText,
          backgroundColor: darkBg,
          textStyle: TextStyle(fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 14, color: bgColor),
          ),
        ],
      ),
      style: TextButton.styleFrom(
        primary: lightBg,
        backgroundColor: darkBg,
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
  return Container(
    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
    decoration: BoxDecoration(
      color: multiPlayerQuizController.getIsCorrectAnswer(text)
          ? Colors.green[200]
          : multiPlayerQuizController.getIsSelectedWrongAnswer(text)
              ? Colors.red[200]
              : multiPlayerQuizController.getIsSelectedLocalAnswer(text)
                  ? Colors.orange[200]
                  : Colors.white,
      border: Border.all(color: darkText),
      borderRadius: BorderRadius.circular(4),
    ),
    padding: EdgeInsets.all(4),
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: TextButton(
      onPressed: onPressed,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          multiPlayerQuizController.getIsSelectedLoggedPlayer(text)
              ? DefaultCircularNetworkImage(
                  imageUrl: loggedPlayerImageUrl, width: 30, height: 30)
              : const SizedBox(),
          multiPlayerQuizController.getIsSelectedOpponent(text)
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
    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
    decoration: BoxDecoration(
      color: text == correctAnswer &&
              singlePlayerQuizController.isQuestionAnswered.value
          ? Colors.green[200]
          : text != correctAnswer &&
                  singlePlayerQuizController.isQuestionAnswered.value &&
                  singlePlayerQuizController.selectedAnswer.value == text
              ? Colors.red[200]
              : Colors.white,
      border: Border.all(color: darkText),
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
}) {
  return Container(
      child: CircleAvatar(
    radius: width / 2 + 3,
    backgroundColor: Colors.blueGrey,
    child: CachedNetworkImage(
      imageUrl: imageUrl ?? DEFAULT_PLAYER_IMAGE_URL,
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
        bottom: 3,
        right: 3,
        child: isOnline
            ? CircleAvatar(
                backgroundColor: Colors.green,
                radius: (width.toInt() / 8.0),
              )
            : CircleAvatar(
                backgroundColor: Colors.red,
                radius: (width.toInt() / 8.0),
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
              )
            : const SizedBox(),
      )
    ],
  );
}

/*LoadingButton() {
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
}*/

CircleBorderContainer({
  child,
}) {
  return Container(
    padding: const EdgeInsets.all(smallPadding),
    margin: const EdgeInsets.all(smallPadding),
    decoration: BoxDecoration(
      color: lightBg,
      borderRadius: BorderRadius.circular(smallPadding),
      /*gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          darkBg,
          lightBg,
        ],
      ),*/
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

Widget CustomChip({required String label, Color? color, VoidCallback? onTap}) {
  color ??= darkBg;
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 4),
      child: Chip(
        /*avatar: CircleAvatar(
          backgroundColor: Colors.white70,
          child: Text(label[0].toUpperCase()),
        ),*/
        label: Text(
          '$label',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        backgroundColor: color,
      ),
    ),
  );
}

Widget CustomChipWithIcon(
    {required String label,
    Color? color,
    VoidCallback? onTap,
    required IconData icon}) {
  color ??= darkBg;
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 4),
      child: Chip(
        /*avatar: CircleAvatar(
          backgroundColor: Colors.white70,
          child: Text(label[0].toUpperCase()),
        ),*/
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            Text(
              '$label',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: color,
      ),
    ),
  );
}

//turns MillisecondsSinceEpoch into date time ago (ex: 5 minutes ago)
String formatTimeAgo(int? millisecondsSinceEpoch) {
  return timeago
      .format(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch ?? 0));
}

//extension function to update item of list using index
extension ListUpdate<T> on List<T> {
  List<T> update(int pos, T t) {
    List<T> list = [];
    list.add(t);
    replaceRange(pos, pos + 1, list);
    return this;
  }
}
