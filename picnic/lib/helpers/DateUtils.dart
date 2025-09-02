class DateUtils {
  // Helper method to parse DateTime from various formats
  static DateTime? parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;

    // Handle Firestore Timestamp
    if (dateTime.runtimeType.toString() == 'Timestamp') {
      return (dateTime as dynamic).toDate();
    }

    // Handle ISO8601 String
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return null;
      }
    }

    // Handle DateTime object
    if (dateTime is DateTime) {
      return dateTime;
    }

    return null;
  }

}