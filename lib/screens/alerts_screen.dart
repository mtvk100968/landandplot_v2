import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  AlertsScreenState createState() => AlertsScreenState();
}

class AlertsScreenState extends State<AlertsScreen> {
  // ADDED: a method that refreshes whatever data you want. Right now, it just triggers setState.
  Future<void> _refreshAlerts() async {
    // If you have any logic to re-fetch alerts, do it here
    setState(() {
      // Example: re-fetch data from server or Firestore
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      // ADDED: Wrap the body in a RefreshIndicator
      body: RefreshIndicator(
        onRefresh: _refreshAlerts,
        child: SingleChildScrollView(
          // Make sure we can always scroll, even if content is small
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                kToolbarHeight, // So pull-down works
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Find all your alerts here!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  // Add more widgets here that represent the content of the screen
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
