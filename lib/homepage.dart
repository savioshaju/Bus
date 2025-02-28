import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D2B64), Color(0xFF8A2387)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: PopupMenuButton<int>(
          icon: const Icon(Icons.menu, color: Colors.white),
          onSelected: (value) {
            Navigator.pop(context); // Close menu before navigation
            switch (value) {
              case 1:
                // Handle Ticket Purchase
                break;
              case 2:
                // Handle View Bus Locations
                break;
              case 3:
                // Handle Settings
                break;
              case 4:
                Navigator.pushNamed(context, '/profile');
                break;
              case 5:
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 1, child: Text("Ticket Purchase")),
            const PopupMenuItem(value: 2, child: Text("View Bus Locations")),
            const PopupMenuItem(value: 3, child: Text("Settings")),
            const PopupMenuItem(value: 4, child: Text("Profile")),
            const PopupMenuItem(value: 5, child: Text("Logout")),
          ],
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/searchpage');
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8.0),
                Text('Search for Bus Route',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Advertisement Box
            Container(
              height: 200.0,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Advertisement Box',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
                ),
              ),
            ),
            // Task bar with icons
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTaskBarIcon(Icons.directions_bus, Colors.teal),
                  _buildTaskBarIcon(Icons.schedule, Colors.orange),
                  _buildTaskBarIcon(Icons.info, Colors.purple),
                  _buildTaskBarIcon(Icons.feedback, Colors.green),
                ],
              ),
            ),
            // Options Grid
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // First Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOption('Search for Bus Route', context,
                          '/searchpage', Colors.teal, Icons.search),
                      _buildOption('View Bus Schedule', context, '/schedule',
                          Colors.orange, Icons.schedule),
                    ],
                  ),
                  const SizedBox(height: 15), // Space between rows
                  // Second Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOption('Favorites or Recent Routes', context,
                          '/favorites', Colors.purple, Icons.favorite),
                      _buildOption('About Us/Help', context, '/about',
                          Colors.blue, Icons.help),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskBarIcon(IconData iconData, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4.0)],
      ),
      child: Icon(iconData, color: color, size: 28.0),
    );
  }

  Widget _buildOption(String text, BuildContext context, String route,
      Color color, IconData iconData) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        height: 120.0,
        width: MediaQuery.of(context).size.width * 0.4, // Dynamic width
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: Colors.white, size: 30.0),
            const SizedBox(height: 8.0),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
