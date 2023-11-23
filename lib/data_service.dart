import 'dart:async';
import 'dart:math';

import 'package:candlesticks/candlesticks.dart';

class FakeDataService {
  late Timer _timer;
  final _random = Random();
  final _candlesStreamController = StreamController<List<Candle>>.broadcast();
  final _priceTickStreamController = StreamController<double>.broadcast();

  Stream<List<Candle>> get candlesStream => _candlesStreamController.stream;
  Stream<double> get priceTickStream => _priceTickStreamController.stream;
  List<Candle> get initialCandles => _generateHistoricalData();

  FakeDataService() {
    _startEmittingCandles();
    _startEmittingPrices();
  }

  List<Candle> _generateHistoricalData() {
    List<Candle> historicalCandles = [];
    DateTime currentDate = DateTime.now().subtract(const Duration(minutes: 60));
    double lastClose = _generateRandomPrice(); // Initial random close value

    for (int i = 0; i < 120; i++) {
      final double open = lastClose; // Open is the last close
      final double close = _generateRandomPrice(); // New random close value
      final double high = max(open, close) + _random.nextDouble().roundToDouble() * 5; // Ensure high is greater than open and close
      final double low = min(open, close) - _random.nextDouble().roundToDouble() * 5; // Ensure low is less than open and close
      final double volume = _random.nextDouble() * 1000;

      historicalCandles.add(Candle(
        date: currentDate.add(Duration(minutes: i)),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      lastClose = close;
    }

    return historicalCandles;
  }

  double _generateRandomPrice() {
    return (500 + _random.nextDouble() * 1000).roundToDouble(); // Generates a random price between 500 and 1000
  }

  void _startEmittingCandles() {
    // Assuming we emit a new candle every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      Candle candle = _createNextCandle();

      _candlesStreamController.add([candle]); // Emit new candle data
    });
  }

  Candle _createNextCandle() {
    final DateTime now = DateTime.now();
    final double open = _generateRandomPrice();
    final double close = _generateRandomPrice();
    final double high = max(open, close) + _random.nextDouble() * 5;
    final double low = min(open, close) - _random.nextDouble() * 5;
    final double volume = _random.nextDouble() * 1000;

    final Candle candle = Candle(
      date: now,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
    return candle;
  }

  Candle createNextCandleByPriceTick(double priceTick) {
    final DateTime now = DateTime.now();
    final double open = priceTick;
    final double close = priceTick;
    final double high = priceTick;
    final double low = priceTick;
    final double volume = _random.nextDouble() * 1000;

    final Candle candle = Candle(
      date: now,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
    return candle;
  }

  void _startEmittingPrices() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          final double priceTick = _generateRandomPrice();
          _priceTickStreamController.add(priceTick);
    });
  }

  void dispose() {
    _timer.cancel();
    _candlesStreamController.close();
    _priceTickStreamController.close();
  }
}
