import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteMapPage extends StatefulWidget {
  const RouteMapPage({super.key});

  @override
  RouteMapPageState createState() => RouteMapPageState();
}

class RouteMapPageState extends State<RouteMapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _stopController = TextEditingController();
  final List<Map<String, dynamic>> _stops = [];
  List<LatLng> _routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    _mapController.mapEventStream.listen((event) {
      if (_stops.isNotEmpty) {
        _mapController.move(
            LatLng(_stops.last['lat'], _stops.last['lon']), 13.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus Route Planner')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child:
                            _buildTownSearch('Start Point', _startController)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildTownSearch('End Point', _endController)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _buildTownSearch(
                            'Intermediate Stop', _stopController)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: _addIntermediateStop,
                    ),
                  ],
                ),
                _buildStopList(),
                const SizedBox(height: 10),
                _buildControlButtons(),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(9.5916, 76.5223),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: _stops
                      .map((stop) => Marker(
                            point: LatLng(stop['lat'], stop['lon']),
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin,
                                color: Colors.red, size: 40),
                          ))
                      .toList(),
                ),
                PolylineLayer(
                  polylines: _routeCoordinates.isNotEmpty
                      ? [
                          Polyline(
                            points: _routeCoordinates,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          )
                        ]
                      : [
                          Polyline(points: [], color: Colors.transparent)
                        ], // Empty polyline instead of `[]`
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTownSearch(String label, TextEditingController controller) {
    return TypeAheadField<Map<String, dynamic>>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration:
              InputDecoration(labelText: label, border: OutlineInputBorder()),
        );
      },
      suggestionsCallback: (pattern) async {
        return await _searchTowns(pattern);
      },
      itemBuilder: (context, suggestion) =>
          ListTile(title: Text(suggestion['name'])),
      onSelected: (suggestion) => _confirmAddStop(suggestion, controller),
    );
  }

  Widget _buildStopList() {
    return Column(
      children:
          _stops.map((stop) => ListTile(title: Text(stop['name']))).toList(),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _stops.length >= 2 ? _submitRoute : null,
          child: const Text('Submit Route'),
        ),
        TextButton(
          onPressed: _resetForm,
          child: const Text('Clear All'),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _searchTowns(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5'),
      headers: {'User-Agent': 'BusRouteApp/1.0'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
          jsonDecode(response.body).map((item) => {
                'name': item['display_name'],
                'lat': double.parse(item['lat']),
                'lon': double.parse(item['lon']),
              }));
    }
    return [];
  }

  void _confirmAddStop(
      Map<String, dynamic> stop, TextEditingController controller) {
    setState(() {
      _stops.add(stop);
      controller.clear();
    });
  }

  void _addIntermediateStop() {
    if (_stopController.text.isNotEmpty) {
      _searchTowns(_stopController.text).then((results) {
        if (results.isNotEmpty) {
          _confirmAddStop(results.first, _stopController);
        }
      });
    }
  }

  void _resetForm() {
    setState(() {
      _stops.clear();
      _routeCoordinates.clear();
    });
  }

  Future<void> _submitRoute() async {
    if (_stops.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter at least a start and end location.')),
      );
      return;
    }

    final String apiKey =
        "YOUR_OPENROUTESERVICE_API_KEY"; // Replace with your key
    final List<LatLng> coordinates =
        _stops.map((stop) => LatLng(stop['lat'], stop['lon'])).toList();

    final String requestUrl = _buildRoutingUrl(coordinates, apiKey);

    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> routePoints =
            data['routes'][0]['geometry']['coordinates'];

        setState(() {
          _routeCoordinates =
              routePoints.map((point) => LatLng(point[1], point[0])).toList();
        });
      } else {
        throw Exception('Failed to fetch route');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching route: $e')),
      );
    }
  }

  String _buildRoutingUrl(List<LatLng> points, String apiKey) {
    final String waypoints =
        points.map((p) => "${p.longitude},${p.latitude}").join(";");
    return "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&coordinates=$waypoints&format=geojson";
  }
}
