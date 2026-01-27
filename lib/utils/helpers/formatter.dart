import 'package:intl/intl.dart';

class CFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    final onlyDate = DateFormat('dd/MM/yyyy').format(date);
    final onlyTime = DateFormat('hh:mm a').format(date);
    return '$onlyDate at $onlyTime';
  }

  /// -- format time range and return result toString() --
  static int computeTimeRangeFromNow(String end) {
    final startTime = DateTime.now();
    final endTime = DateTime.parse(end);

    var differenceInDays = endTime.difference(startTime).inDays;

    return differenceInDays;
  }

  /// -- format time range and return result toString() --
  static String formatTimeRangeFromNow(String end) {
    final startTime = DateTime.now();
    final endTime = DateTime.parse(end);

    var differenceInDays = endTime.difference(startTime).inDays;
    var differenceInHours = endTime.difference(startTime).inHours;
    var differenceInMinutes = endTime.difference(startTime).inMinutes % 60;
    var formattedRange = '';

    switch (differenceInDays) {
      case < 0 && <= -1:
        differenceInDays = endTime.difference(startTime).inDays.abs();
        formattedRange = '$differenceInDays day(s) ago';
        break;
      case < 0 && > -1:
        differenceInHours = endTime.difference(startTime).inHours.abs();

        // formattedRange =
        //     '$differenceInHours hour(s) $differenceInMinutes minute(s) ago';
        formattedRange = '$differenceInHours hour(s) ago';
        break;
      case >= 0 && < 1:
        differenceInHours = endTime.difference(startTime).inHours.abs();
        differenceInMinutes = endTime.difference(startTime).inMinutes.abs();
        if (differenceInMinutes < 1) {
          formattedRange = 'just now';
          break;
        }
        if (differenceInHours < 1) {
          formattedRange = '$differenceInMinutes minute(s) ago';
          break;
        }
        if (differenceInHours >= 1) {
          formattedRange = '$differenceInHours hour(s) ago';
          break;
        }
        // formattedRange =
        //     '$differenceInHours hour(s) $differenceInMinutes minute(s) ago';

        break;
      case >= 1:
        differenceInDays = endTime.difference(startTime).inDays;
        differenceInHours = endTime.difference(startTime).inHours % 24;
        // formattedRange =
        //     'in $differenceInDays day(s) $differenceInHours hour(s)';
        formattedRange = 'in $differenceInDays day(s)';
        break;
      default:
        differenceInDays = 0;
        formattedRange = endTime.toString();
    }

    return formattedRange;
  }

  /// -- display values greater than 1000 with a 'K' suffix --
  static String kSuffixFormatter(double amount) {
    final formatter = NumberFormat.compact(locale: 'en_US');
    return formatter.format(amount);
  }

  /// -- extract time from dateTime string --
  static String extractTime(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('hh:mm:ss').format(dateTime);
  }
}
