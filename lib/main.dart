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
      home: PokemonList(),
    );
  }
}

class PokemonList extends StatefulWidget {
  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<dynamic> pokemonData = [];

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

  void showPaymentSuccessfulDialog(String itemName, String itemImage, double marketPrice) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon Cards'),
      ),
      body: ListView.builder(
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
                showPaymentSuccessfulDialog(
                  pokemon['name'],
                  pokemon['images']['small'],
                  marketPrice,
                );
              },
              child: Text("Buy Now"),
            ),
          );
        },
      ),
    );
  }
}
