import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movement App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Movement App Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum AxisType { X, Y, Z }

class _MyHomePageState extends State<MyHomePage> {
  // * Variables
  AxisType _currentAxisType = AxisType.X;
  final List<AccelerometerEvent> _accelerometerEvents = [];
  final List<FlSpot> _accelerometerGraphData = [];
  late double _currentTime = 0;
  double _latestX = 0;
  double _latestY = 0;
  double _latestZ = 0;
  bool _movementDetected = false;
  double _thresholdX = 0;
  double _thresholdY = 0;
  double _thresholdZ = 0;

  double _getValueForAxis(AccelerometerEvent event) {
    switch (_currentAxisType) {
      case AxisType.X:
        return event.x;
      case AxisType.Y:
        return event.y;
      case AxisType.Z:
        return event.z;
    }
  }

  double _calculateThreshold(List<double> values) {
    double sum = values.reduce((value, element) => value + element);
    return sum / values.length + 0.08; // Add some margin
  }

  void _showMovementMessage(String axis) async {
    //TODO: Make API call
    try {
      final response = await http.post(
        Uri.parse(
            'https://4cfa-122-169-45-27.ngrok-free.app/api/movement-detected'),
        headers: {
          'Authorization': '0279767642',
        },
        body: '',
      );

      if (response.statusCode == 200) {
        print('Movement detected request successful');
      } else {
        print('Movement detected request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error triggering movement detected request: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Movement detected by axis: $axis'),
        duration: Duration(seconds: 5),
      ),
    );

    // Reset _movementDetected after 5 seconds
    Timer(Duration(seconds: 5), () {
      _movementDetected = false;
    });
  }

  void _checkMovement(AccelerometerEvent event) {
    // print(event);
    if (_accelerometerEvents.length > 100 && !_movementDetected) {
      if (event.x.abs() > _thresholdX.abs()) {
        _movementDetected = true;
        print("Movement detected in X");
        _showMovementMessage('X');
      }
      if (event.y.abs() > _thresholdY.abs()) {
        _movementDetected = true;
        print("Movement detected in Y");
        _showMovementMessage('Y');
      }
      if (event.z.abs() > _thresholdZ.abs()) {
        _movementDetected = true;
        print("Movement detected in Z");
        _showMovementMessage('Z');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Make a request every 30 seconds
    Timer.periodic(Duration(seconds: 30), (timer) async {
      try {
        final response = await http.post(
          Uri.parse('https://4cfa-122-169-45-27.ngrok-free.app/api/alive'),
          headers: {
            'Authorization': '0279767642',
          },
          body: '',
        );

        if (response.statusCode == 200) {
          print('Request successful');
        } else {
          print('Request failed: ${response.statusCode}');
        }
      } catch (e) {
        print('Error making request: $e');
      }
    });

    accelerometerEventStream().listen((AccelerometerEvent event) {
      print(event);
      setState(() {
        _accelerometerEvents.add(event); // To detect movement

        if (_accelerometerEvents.length == 100) {
          // Calculate threshold values
          _thresholdX = _calculateThreshold(
              _accelerometerEvents.map((event) => event.x.abs()).toList());
          _thresholdY = _calculateThreshold(
              _accelerometerEvents.map((event) => event.y.abs()).toList());
          _thresholdZ = _calculateThreshold(
              _accelerometerEvents.map((event) => event.z.abs()).toList());
          print("Threshold X: " + _thresholdX.toString());
          print("Threshold Y: " + _thresholdY.toString());
          print("Thresholdz: " + _thresholdZ.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recalibration successful'),
              duration: Duration(seconds: 1),
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {
                  _movementDetected = false;
                },
              ),
            ),
          );
        }

        _latestX = event.x;
        _latestY = event.y;
        _latestZ = event.z;

        _checkMovement(event);

        _accelerometerGraphData
            .add(FlSpot(_currentTime, _getValueForAxis(event)));
        _currentTime += 1;
      });
    });
  }

  void _resetGraph() {
    setState(() {
      _accelerometerGraphData.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentAxisType = AxisType.X;
                _resetGraph();
              });
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                return _currentAxisType == AxisType.X
                    ? Colors.blue
                    : Colors.grey;
              }),
            ),
            child: const Text('X'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentAxisType = AxisType.Y;
                _resetGraph();
              });
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                return _currentAxisType == AxisType.Y
                    ? Colors.blue
                    : Colors.grey;
              }),
            ),
            child: const Text('Y'),
          ),
          ElevatedButton(
            onPressed: () {
              _currentAxisType = AxisType.Z;
              _resetGraph();
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                return _currentAxisType == AxisType.Z
                    ? Colors.blue
                    : Colors.grey;
              }),
            ),
            child: const Text('Z'),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: LineChart(
                    LineChartData(
                      minY: -5,
                      maxY: 10,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _accelerometerGraphData.isNotEmpty
                              ? _accelerometerGraphData
                              : [FlSpot(0, 0)],
                          isCurved: false,
                          colors: [
                            _currentAxisType == AxisType.X
                                ? Colors.red
                                : Colors.grey,
                            _currentAxisType == AxisType.Y
                                ? Colors.green
                                : Colors.grey,
                            _currentAxisType == AxisType.Z
                                ? Colors.blue
                                : Colors.grey,
                          ],
                          belowBarData: BarAreaData(show: false),
                          show: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (_) => const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        bottomTitles:
                            SideTitles(showTitles: false), // Hide bottom titles
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('X: ${_latestX.abs().toStringAsFixed(2)}'),
                      Text(
                        'Y: ${_latestY.abs().toStringAsFixed(2)}',
                      ),
                      Text('Z: ${_latestZ.abs().toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
