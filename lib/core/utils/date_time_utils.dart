class DateTimeUtils {
  const DateTimeUtils._();

  static String relativeShort(DateTime? date, {DateTime? now}) {
    if (date == null) return '';

    final current = now ?? DateTime.now();
    final diff = current.difference(date.toLocal());
    if (diff.isNegative || diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${(diff.inDays / 365).floor()}y';
  }
}
