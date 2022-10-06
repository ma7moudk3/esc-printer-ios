import 'package:flutter/material.dart';
import 'package:printer_esc/printer_order.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          List<String> myList = [];
          for (int i = 0; i < 4; ++i) {
            myList.add('Item nr $i');
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrinterOrder(
                  orderType: 'demo',
                  orderNumber: '123456',
                  customerName: 'John',
                  deliveryTime: 'asap',
                  instruction: 'Are you going to be able to print this one?',
                  items: myList,
                ),
              ));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
