String timeAgo(String isoDateStr) {
  DateTime pastDate = DateTime.parse(isoDateStr).toUtc();
  DateTime now = DateTime.now().toUtc();

  Duration diff = now.difference(pastDate);

  int seconds = diff.inSeconds;
  int minutes = diff.inMinutes;
  int hours = diff.inHours;
  int days = diff.inDays;
  int months = (days / 30).floor();
  int years = (days / 365).floor();

  if (years > 0) {
    return "$years YEARS AGO";
  } else if (months > 0) {
    return "$months MONTHS AGO";
  } else if (days > 0) {
    return "$days DAYS AGO";
  } else if (hours > 0) {
    return "$hours HOURS AGO";
  } else if (minutes > 0) {
    return "$minutes MINUTES AGO";
  } else {
    return "JUST NOW";
  }
}
