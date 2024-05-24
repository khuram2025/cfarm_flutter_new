String calculateAge(DateTime dob) {
  final now = DateTime.now();
  final difference = now.difference(dob);

  final years = difference.inDays ~/ 365;
  final months = (difference.inDays % 365) ~/ 30;
  final days = (difference.inDays % 365) % 30;

  if (years > 0) {
    return '$years Year${years > 1 ? 's' : ''} ${months > 0 ? '$months Month${months > 1 ? 's' : ''}' : ''} ${days > 0 ? '$days Day${days > 1 ? 's' : ''}' : ''}';
  } else if (months > 0) {
    return '$months Month${months > 1 ? 's' : ''} ${days > 0 ? '$days Day${days > 1 ? 's' : ''}' : ''}';
  } else {
    return '$days Day${days > 1 ? 's' : ''}';
  }
}
