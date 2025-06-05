import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

//Now lets make a variable that stores a person's information
class Person {
  final String name;
  final int age;
  final String email;
  final String address; 

  Person({required this.name, required this.age, required this.email, required this.address});
}

//Lets make an array of Person objects
final List<Person> people = [
  Person(name: 'Alice', age: 30, email: 'alice@gmail.com', address: '505 Cold Spring Road, New York, NY'),
  Person(name: 'Bob', age: 25, email: 'bob@gmail.com', address: '350 5th Ave, New York, NY 10118, USA'),
  Person(name: 'Charlie', age: 35, email: 'charlie@gmail.com', address: 'San Francsico, CA'),
  Person(name: 'Diana', age: 28, email: 'diana@gmail.com', address: '1600 Amphitheatre Parkway, Mountain View, CA 94043, USA'),
  Person(name: 'Ethan', age: 22, email: 'ethan@gmail.com', address: '1 Apple Park Way, Cupertino, CA 95014, USA'),
];


void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
      ),
      home: const MyHomePage(title: 'Profiles Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0; 
  void _incrementIndex() {
    setState(() {
      if (index < people.length - 1) {
        index++;
      }     
    });
  }
  void _decrementIndex() {
    setState(() {
      if (index > 0) {
        index--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showPrevious = index > 0;
    bool showNext = index < people.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: PersonInfo(person: people[index]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility( 
              visible: showPrevious, 
              child: FloatingActionButton(
                onPressed: _decrementIndex,
                child: const Icon(Icons.chevron_left),
              ),
            ),

            Visibility( 
              visible: showNext, 
              child: FloatingActionButton(
                onPressed: _incrementIndex,
                child: const Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonInfo extends StatelessWidget {
  final Person person;

  const PersonInfo({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    TextStyle labelStyle = theme.textTheme.bodyLarge!.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );

    TextStyle valueStyle = theme.textTheme.titleMedium!;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.4),
            blurRadius: 9,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 80, child: Text('Name:', style: labelStyle)),
              Expanded(child: Text(person.name, style: valueStyle)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 80, child: Text('Age:', style: labelStyle)),
              Expanded(child: Text(person.age.toString(), style: valueStyle)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 80, child: Text('Email:', style: labelStyle)),
              Expanded(child: Text(person.email, style: valueStyle)),
            ],
          ),
          Row( 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 80, child: Text('Map Info:', style: labelStyle)),
              Expanded(child: 
                SizedBox(
                  height: 500,
                  child: Map(person: person, key: ValueKey(person.email)),
                  ),
              ),
            ],
          )
        ],
      ),
    );
  }
}



class Map extends StatefulWidget {
  final Person person;
  const Map({super.key, required this.person});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  final Distance distance = const Distance();

  var isRemoving = false;
  

  @override
  void didUpdateWidget(covariant Map oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.person.address != widget.person.address) {
      getAddressAndAddMarker(widget.person.address);
    }
  }
  @override
  void initState() {
    super.initState();
  }

  Future<void> getAddressAndAddMarker(String address) async {
    if (address.trim().isEmpty) return;
    List<Location> locations = await locationFromAddress(address);
    if (locations.isEmpty) {
      return;
    }
    final coords = LatLng(locations.first.latitude, locations.first.longitude);

    setState(() {
      _mapController.move(coords, 20);
      _markers = [
        Marker(
          width: 40,
          height: 40,
          point: coords,
          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      ];
    });
  }

  Future<void> addMarker(LatLng latlng) async {
    setState(() {
      _markers.add(
        Marker(
          width: 40,
          height: 40,
          point: latlng,
          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      );
    });
  }
  Future<void> removeMarker(LatLng latlng) async {
    setState(() {
      final scale = _mapController.camera.zoom;
      _markers.removeWhere((marker) {
        return distance.as(LengthUnit.Meter, marker.point, latlng) < 5 * (scale / 20);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(40.7128, -74.0060), // e.g. New York
          initialZoom: 12,
          onMapReady: () {
            getAddressAndAddMarker(widget.person.address);
          },
          onTap: (tapPosition, latlng) {
            if (isRemoving) {
              removeMarker(latlng);
              isRemoving = false;
              return;
            }
            else { 
              addMarker(latlng);
            }

          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isRemoving = !isRemoving;
          });
        },
        child: Icon(isRemoving ? Icons.add_location : Icons.remove_outlined),
      ),
    );
  }
}
