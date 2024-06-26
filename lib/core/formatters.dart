import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Converts a [DateTime] to a text that shows the time difference
/// between the current time and [date] passed.
String dateToTimeAgo(DateTime date) {
  return timeago.format(date);
}

String formatDate(DateTime date, [String pattern = 'h:mm a']) {
  return DateFormat(pattern).format(date);
}
