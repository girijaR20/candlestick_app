import 'dart:math';

import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'data_service.dart'; // Your FakeDataService script

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candlestick Chart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FakeDataService _fakeDataService;
  List<Candle> candles = [];
  String currentInterval = "1m";

  @override
  void initState() {
    super.initState();
    _fakeDataService = FakeDataService();
    candles = _fakeDataService.initialCandles;
  }

  @override
  void dispose() {
    _fakeDataService.dispose();
    super.dispose();
  }

  void updateCandlesFromSnapshot(AsyncSnapshot<double> snapshot) {
      // get latest candle
      if (candles.isNotEmpty && snapshot.data != null) {
        Candle latestCandle = candles.first;
        final priceTick = snapshot.data!.toDouble();
        final int timeDifference = DateTime.now().difference(latestCandle.date).inSeconds;

        if (timeDifference >= 60) {
          Candle nextCandle = _fakeDataService.createNextCandleByPriceTick(priceTick);
          candles.insert(0, nextCandle);

        } else {
          latestCandle = Candle(
              date: latestCandle.date,
              high: max(latestCandle.high, priceTick),
              low: min(latestCandle.low, priceTick),
              open: latestCandle.open,
              close: priceTick,
              volume: latestCandle.volume);

          //update the latest candle
          candles.removeAt(0);
          candles.insert(0, latestCandle);
        }
      }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candlestick Chart'),
      ),
      body: StreamBuilder<double>(
        stream: _fakeDataService.priceTickStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {

           updateCandlesFromSnapshot(snapshot);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Candlesticks(
                key: const Key("SYM"),
                candles: candles,
              ),
            );
          } else {
            return const Center(child: Text('No Data Available Yet'));
          }
        },
      ),
    );
  }
}