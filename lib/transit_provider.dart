import 'package:flutter/material.dart';
import 'BusOwnerDetailsPage.dart' as b;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/transit_provider': (context) => const TransitProviderPage(),
        '/bus_owner_details': (context) => b.BusOwnerDetailsPage(),
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF004d73),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/transit_provider');
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}

class TransitProviderPage extends StatefulWidget {
  const TransitProviderPage({super.key});

  @override
  _TransitProviderPageState createState() => _TransitProviderPageState();
}

class _TransitProviderPageState extends State<TransitProviderPage> {
  String? _selectedOption;
  String? _hoveredIcon;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transit Provider Dashboard',
              style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF004d73), Color(0xFF191970)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            _buildTaskBarIcons(context),
            _buildUserAvatar(context),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            setState(() {
              _hoveredIcon = null;
            });
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 4,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOptionCard(
                  context,
                  'Add Bus Route',
                  [
                    const Color.fromARGB(255, 255, 95, 108),
                    const Color.fromARGB(255, 238, 139, 164)
                  ],
                  '/bus_owner_details',
                ),
                _buildOptionCard(
                  context,
                  'Check Frequently Used Routes',
                  [const Color(0xFF42e695), const Color(0xFF3bb2b8)],
                  '/bus_owner_details',
                ),
                _buildOptionCard(
                  context,
                  'View Complaints',
                  [const Color(0xFFde6262), const Color(0xFFffb88c)],
                  '/bus_owner_details',
                ),
                _buildOptionCard(
                  context,
                  'Settings',
                  [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
                  '/bus_owner_details',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String label,
      List<Color> gradientColors, String routeName) {
    bool isHovered = _selectedOption == label;

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _selectedOption = label;
        });
      },
      onExit: (event) {
        setState(() {
          if (_selectedOption != null && _selectedOption == label) {
            _selectedOption = null;
          }
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedOption = label;
          });
          // Navigate to the specified route
          Navigator.pushNamed(context, routeName);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80.0,
          height: 30.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              if (isHovered)
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskBarIcons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTaskBarIcon(context, Icons.directions_bus, 'Bus', [
          'Add Bus Route',
          'Check Bus Route',
          'View Bus Location',
          'Frequently Searched Routes',
        ]),
        _buildTaskBarIcon(context, Icons.feedback, 'Feedback', [
          'Complaints',
          'Feedbacks',
        ]),
      ],
    );
  }

  Widget _buildTaskBarIcon(BuildContext context, IconData icon, String label,
      List<String> subOptions) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        final Offset tapPosition = details.globalPosition;
        showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            tapPosition.dx,
            tapPosition.dy,
            tapPosition.dx,
            tapPosition.dy,
          ),
          items: subOptions.map((String subOption) {
            return PopupMenuItem<String>(
              value: subOption,
              child:
                  Text(subOption, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
        ).then((String? value) {
          if (value != null) {
            // Handle menu item selection
            switch (value) {
              case 'Logout':
                // Perform logout action
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false);

                break;
              case ('Add Bus Route'):
                Navigator.pushNamed(context, '/bus_owner_details');
                break;
              default:
              // Handle other menu items
            }
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            Text(label,
                style: const TextStyle(fontSize: 12.0, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'Profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'Logout':
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (Route<dynamic> route) => false);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'Profile',
            child: Text('Profile', style: TextStyle(color: Colors.black)),
          ),
          const PopupMenuItem<String>(
            value: 'Logout',
            child: Text('Logout', style: TextStyle(color: Colors.black)),
          ),
        ];
      },
      child: const CircleAvatar(
        radius: 15, // Smaller size
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 20, color: Color(0xFF004d73)),
      ),
    );
  }
}
