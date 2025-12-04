class CDateTimeComputations {
  static int timeRangeFromNow(String comparison) {
    final currentTime = DateTime.now();
    final endTime = DateTime.parse(comparison);

    var differenceInHrs = (endTime.difference(currentTime).inHours / 24)
        .round();

    return differenceInHrs;
  }
}
