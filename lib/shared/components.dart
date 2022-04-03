import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  return TextFormField(
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
  );
}

DefaultButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return Container(
    height: 50,
    width: double.infinity,
    child: Expanded(
      child: TextButton(
        onPressed: onPressed,
        child: Text(text.toUpperCase()),
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Color(0xff00b4d8),
        ),
      ),
    ),
  );
}

DefaultIconButton({
  required String text,
  required VoidCallback onPressed,
  required IconData icon,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: smallPadding),
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
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        primary: Colors.white,
        backgroundColor: Color(0xff00b4d8),
      ),
    ),
  );
}

DefaultCircularNetworkImage({
  required String? imageUrl,
  var width = 70.0,
  var height = 70.0,
}) {
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
            'https://firebasestorage.googleapis.com/v0/b/realtime-quizzes.appspot.com/o/user.png?alt=media&token=00fedb4a-b751-47f1-a8b6-34673648033a',
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
  var width = 70.0,
  var height = 70.0,
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
            ? const CircleAvatar(
                backgroundColor: Colors.green,
                radius: 8,
              )
            : const CircleAvatar(
                backgroundColor: Colors.red,
                radius: 8,
              ),
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
            primary: Colors.white,
            backgroundColor: Colors.blue,
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
