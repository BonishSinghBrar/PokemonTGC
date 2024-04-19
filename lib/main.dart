import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    debugShowCheckedModeBanner: false, // Remove debug banner
  ));
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Adding a delay before navigating to MyApp
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/a.jpg'), // Assuming 'a.jpg' is in the 'assets' folder
            SizedBox(height: 20),
            Text(
              'Welcome to PokemonGO TGC',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'by BONISH SINGH BRAR',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pokemon Cards'),
        ),
        body: PokemonList(), // Add PokemonList back to the body
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Navigation Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // You can add any logic here for navigating to the home screen if needed
                },
              ),
              ListTile(
                title: Text('Logout'), // Changed Login to Logout
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  showLogoutDialog(context); // Show logout dialog
                },
              ),
              // Add more list tiles for other menu items if necessary
            ],
          ),
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("User successfully logged out"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PokemonList())); // Navigate back to PokemonList
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class PokemonList extends StatefulWidget {
  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<dynamic> pokemonData = [];
  bool isLoggedIn = false; // Track if user is logged in

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  Future<void> fetchPokemonData() async {
    final Uri url =
    Uri.parse('https://api.pokemontcg.io/v2/cards?q=name:gardevoir');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        pokemonData = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void showPaymentSuccessfulDialog(
      String itemName, String itemImage, double marketPrice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Successful"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Item Name: $itemName"),
              SizedBox(height: 8),
              Image.network(itemImage),
              SizedBox(height: 8),
              Text("Market Price: \$${marketPrice.toStringAsFixed(2)}"),
              if (isLoggedIn) Text("User: John Doe"), // Display user name if logged in
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void handleBuyNow(String itemName, String itemImage, double marketPrice) {
    if (isLoggedIn) {
      showPaymentSuccessfulDialog(itemName, itemImage, marketPrice);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()))
          .then((isLoggedIn) {
        if (isLoggedIn != null && isLoggedIn) {
          showPaymentSuccessfulDialog(itemName, itemImage, marketPrice);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pokemonData.length,
      itemBuilder: (BuildContext context, int index) {
        final pokemon = pokemonData[index];
        final marketPrice =
        pokemon['tcgplayer']['prices']['holofoil']['market'];
        return ListTile(
          leading: Image.network(pokemon['images']['small']),
          title: Text(pokemon['name']),
          subtitle: Text('Market Price: \$${marketPrice.toStringAsFixed(2)}'),
          trailing: ElevatedButton(
            onPressed: () {
              handleBuyNow(
                pokemon['name'],
                pokemon['images']['small'],
                marketPrice,
              );
            },
            child: Text("Buy Now"),
          ),
        );
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Card Number'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'CVV'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Expiry Date'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add login logic here
                // For demo purpose, just set isLoggedIn to true
                Navigator.pop(context, true); // Close the login screen and return isLoggedIn
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('User Detail saved successfully!')));
              },
              child: Text('Save Details'),
            ),
          ],
        ),
      ),
    );
  }
}
