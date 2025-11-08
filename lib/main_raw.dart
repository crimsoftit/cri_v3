import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mpesa_flutter_plugin/initializer.dart';
import 'package:mpesa_flutter_plugin/payment_enums.dart';

void main() {
  MpesaFlutterPlugin.setConsumerKey(
    "mSwDCUzDh1nhmpGVhkwbhrHolsXl70kGR55syLDpEfLwQZor",
  );
  MpesaFlutterPlugin.setConsumerSecret(
    "4lDGNPJue6FUQsA7W5oUE4R1D9tnKLLsF127RzX3BuDbPO9Rkyi7ej5kXdtUbaQ6",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  Future<dynamic> initializeMpesaTxn(double amount, String phoneNumber) async {
    dynamic txnInit;
    try {
      txnInit = await MpesaFlutterPlugin.initializeMpesaSTKPush(
        businessShortCode: "174379",
        // transactionType: "CustomerPayBillOnline",
        transactionType: TransactionType.CustomerPayBillOnline,
        amount: amount,
        //partyA: "254708374149",
        partyA: phoneNumber,
        partyB: "174379",
        callBackURL: Uri.parse("https://mydomain.com/path"),
        accountReference: "payment test",
        //phoneNumber: "254708374149",
        phoneNumber: phoneNumber,
        baseUri: Uri(scheme: "https", host: "sandbox.safaricom.co.ke"),
        transactionDesc: "Test Payment",
        passKey:
            "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
      );

      //HashMap response = txnInit as HashMap;
      if (kDebugMode) {
        print("Response: $txnInit");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception Caught: $e");
      }
      rethrow;
    }
    return txnInit;
  }

  final int _counter = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          initializeMpesaTxn(1.0, "254746683785");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
