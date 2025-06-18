class Booking {
  final int? id;
  final String userEmail;
  final String boothType;
  final List<String> additionalItems;
  final String date;

  Booking({
    this.id,
    required this.userEmail,
    required this.boothType,
    required this.additionalItems,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userEmail': userEmail,
        'boothType': boothType,
        'additionalItems': additionalItems.join(','),
        'date': date,
      };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        id: map['id'],
        userEmail: map['userEmail'],
        boothType: map['boothType'],
        additionalItems: map['additionalItems'].split(','),
        date: map['date'],
      );
}