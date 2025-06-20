class Booking {
  final int? bookID;
  final String userEmail;
  final String boothType;
  final List<String> additionalItems;
  final String date;

  Booking({
    this.bookID,
    required this.userEmail,
    required this.boothType,
    required this.additionalItems,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'bookID': bookID,
        'userEmail': userEmail,
        'boothType': boothType,
        'additionalItems': additionalItems.join(','),
        'date': date,
      };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        bookID: map['bookID'],
        userEmail: map['userEmail'],
        boothType: map['boothType'],
        additionalItems: map['additionalItems'].split(','),
        date: map['date'],
      );
}