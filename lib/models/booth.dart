class boothPackage {
  String boothName;
  String boothDescription;
  String boothCapacity;
  String boothImage;

  boothPackage({
    required this.boothName,
    required this.boothDescription,
    required this.boothCapacity,
    required this.boothImage,
  });

  static List<boothPackage> getBoothPackages() {
    return [
      boothPackage(
        boothName: "Standard Booth",
        boothDescription:
            "3x3m space with table and 2 chairs. Ideal for startups and small vendors.",
        boothCapacity: "2 people",
        boothImage: 'assets/images/standardbooth.jpg',
      ),
      boothPackage(
        boothName: "Premium Booth",
        boothDescription:
            "4x4m space with premium decor, 4 chairs, spotlight lighting and name signage.",
        boothCapacity: "4 people",
        boothImage: "assets/images/premiumbooth.png",
      ),
      boothPackage(
        boothName: "VIP Lounge",
        boothDescription:
            "5x5m lounge setup with leather seating, carpet, and branded backdrop wall.",
        boothCapacity: "Up to 20+ people",
        boothImage: "assets/images/viplounge.jpg",
      ),
      boothPackage(
        boothName: "Outdoor Pavilion",
        boothDescription:
            "5x5m open-air booth, weather-proof tent, portable AC, suitable for food vendors.",
        boothCapacity: "Up to 50+ people",
        boothImage: "assets/images/outdoorpavilion.jpg",
      ),
      boothPackage(
        boothName: "Demo Stage Booth",
        boothDescription:
            "3x5m booth with a stage platform and microphone setup, ideal for product demos.",
        boothCapacity: "4 people",
        boothImage: "assets/images/demobooth.jpg",
      ),
      boothPackage(
        boothName: "Media Sponsor Booth",
        boothDescription:
            "Special 4x4m area for media & sponsors with high visibility and screen display.",
        boothCapacity: "4 people",
        boothImage: "assets/images/mediasponsor.jpeg",
      ),
    ];
  }
}
