// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fucking Application',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:math';

String generateQuestion() {
  var rng = Random();
  var number1 = rng.nextDouble() * 100;
  var number2 = rng.nextDouble() * 100;
  List<String> operators = ['+', '-', '*', '/'];
  String operator = operators[rng.nextInt(operators.length)];
  var answer = operator == '+'
      ? number1 + number2
      : operator == '-'
          ? number1 - number2
          : operator == '*'
              ? number1 * number2
              : number1 ~/ number2;
  String out = '${number1.toStringAsFixed(2)} $operator ${number2.toStringAsFixed(2)} ${answer.toStringAsFixed(2)}';
  return out;
}

void main() {
  runApp(const ArithmeticApp());
}

class ArithmeticApp extends StatelessWidget {
  const ArithmeticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '算术练习',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ArithmeticHomePage(),
    );
  }
}

class ArithmeticHomePage extends StatefulWidget {
  const ArithmeticHomePage({super.key});

  @override
  _ArithmeticHomePageState createState() => _ArithmeticHomePageState();
}

class _ArithmeticHomePageState extends State<ArithmeticHomePage> {
  String question = generateQuestion();
  String questionWithoutAnswer = '';
  int score = 0;
  var sta;
  final answerController = TextEditingController();

  void checkAnswer() {
    // 这里你需要包括逻辑来检查用户的答案是否正确。
    // 目前，它只是打印输入值。
    if (question.split(" ")[1] == answerController.text) {
      // print(answerController.text);
      score++;
    }
    print(answerController.text);
    // 检查后，生成一个新问题。
    setState(() {
      question = generateQuestion();
      questionWithoutAnswer = question.split(" ")[0];
      sta = question;

      answerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('算术练习 '),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '解决下面的题目：',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            questionWithoutAnswer,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: answerController,
              keyboardType: TextInputType.number,
              onSubmitted: (value) => checkAnswer(),
              decoration: const InputDecoration(
                labelText: '你的答案',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: checkAnswer,
            child: const Text('提交'),
          ),
          Text(
            'Score: $score',
          ),
          Text('Statul $sta')
        ],
      ),
      //TODO 添加Score分数显示在界面右上角
    );
  }
}
