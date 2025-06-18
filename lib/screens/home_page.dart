import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> boothPackages = [
    {
      "title": "Standard Booth",
      "description":
          "3x3m space with table and 2 chairs. Ideal for startups and small vendors.\nCapacity: Up to 2 people.",
      "image": "assets/images/standard2.jpg",
    },
    {
      "title": "Premium Booth",
      "description":
          "4x4m space with premium decor, 4 chairs, spotlight lighting and name signage.\nCapacity: Up to 4 people.",
      "image": "assets/images/premium2.jpg",
    },
    {
      "title": "VIP Lounge",
      "description":
          "5x5m lounge setup with leather seating, carpet, and branded backdrop wall.\nCapacity: Up to 6 people.",
      "image": "assets/images/viplounge.jpg",
    },
    {
      "title": "Outdoor Pavilion",
      "description":
          "5x5m open-air booth, weather-proof tent, portable AC, suitable for food vendors.\nCapacity: Up to 5 people.",
      "image": "assets/images/outdoorpavilion.jpg",
    },
    {
      "title": "Demo Stage Booth",
      "description":
          "3x5m booth with a stage platform and microphone setup, ideal for product demos.\nCapacity: Up to 3 presenters.",
      "image": "assets/images/demobooth.jpg",
    },
    {
      "title": "Media Sponsor Booth",
      "description":
          "Special 4x4m area for media & sponsors with high visibility and screen display.\nCapacity: Up to 4 people.",
      "image": "assets/images/mediasponsor.jpeg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('EventSphere'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              children: [
                Text(
                  '🎉 Welcome to Kururin Exhibition 🎉',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Your one-stop platform for seamless exhibition booth reservations. '
                  'Discover flexible packages, book online, and manage your events with ease.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: boothPackages.length,
              itemBuilder: (context, index) {
                final booth = boothPackages[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: AspectRatio(
                          aspectRatio: 3 / 2,
                          child: Image.asset(
                            booth['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          booth['title']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          booth['description']!,
                          style: TextStyle(height: 1.4),
                        ),
                        trailing: Icon(Icons.info_outline),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: Text(booth['title']!),
                                  content: Text(booth['description']!),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Close"),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
