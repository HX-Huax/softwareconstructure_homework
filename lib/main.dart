import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as ph;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Question generateQuestion() {
  var rng = Random();
  var number1 = rng.nextDouble() * 100;
  List<String> operators = ['+', '-', '*', '/'];
  String equation = number1.toStringAsFixed(2);
  String nextoperator = "*";
  for (var i = 1; i <= 3; i++) {
    var number2 = rng.nextDouble() * 100;
    String operator = operators[rng.nextInt(operators.length)];
    if (operator == '+') {
      number1 = number1 + number2;
    } else if (operator == '-') {
      number1 = number1 - number2;
    } else if (operator == '*') {
      number1 = number1 * number2;
    } else {
      number1 = number1 / number2;
    }
    if ((operator == '*' || operator == '/') &&
        (nextoperator == '+' || nextoperator == '-')) {
      equation = '(' + equation + ')';
    }
    equation = equation + operator + number2.toStringAsFixed(2);
    nextoperator = operator;
  }
  DateTime now = new DateTime.now();
  Question out = Question(
      questionset: now.year.toString() +
          '/' +
          now.month.toString() +
          '/' +
          now.day.toString() +
          ' ' +
          now.hour.toString() +
          ':' +
          now.minute.toString() +
          ':' +
          now.second.toString(),
      content: equation,
      options: [],
      correctAnswer: number1.toStringAsFixed(2));
  _addQuestion(out);
  dataListRefresh();
  return out;
}

class Question {
  String questionset;
  String content;
  List<String> options;
  String correctAnswer;

  Question(
      {required this.questionset,
      required this.content,
      required this.options,
      required this.correctAnswer});
  Map<String, dynamic> toMap() {
    return {
      'questionset': questionset,
      'content': content,
      'options': jsonEncode(options),
      'correctAnswer': correctAnswer
    };
  }
}

void _addQuestion(Question question) async {
  await DatabaseHelper.instance.insertQuestion(question);
  await DatabaseHelper.instance.insertGeneralHistory(question.questionset);
}

class Account {
  final int? id; // 可以用作主键
  final String username;
  final String password;

  Account({this.id, required this.username, required this.password});

  // 将Account对象转换为Map对象，用于数据库操作
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }
}

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  // 单例模式
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // 延迟实例化db直到需要的时候
    _database = await _initDatabase();
    return _database!;
  }

  // 打开并创建数据库
  _initDatabase() async {
    String path = ph.join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL代码创建数据库表
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE questions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      questionset TEXT NOT NULL,
      content TEXT NOT NULL,
      options TEXT NOT NULL,
      correctAnswer TEXT NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE useranswers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      content TEXT NOT NULL,
      correctAnswer TEXT NOT NULL,
      answer TEXT NOT NULL,
      time TEXT NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE generalhistory (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      time TEXT NOT NULL
    )
  ''');
  }

  // 帮助方法
  // 插入、查询、更新、删除...
  // 例如插入操作
  //添加账户
  Future<void> insertAccount(Account account) async {
    final Database db = await database;
    await db.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //添加题
  Future<void> insertQuestion(Question question) async {
    final Database db = await database;
    await db.insert(
      'questions',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertGeneralHistory(String time) async {
    final Database db = await database;
    await db.insert(
      'generalhistory',
      {'time': time},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //查询账户
  Future<Account?> getAccountByUsername(String username) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return Account(
        id: maps[0]['id'],
        username: maps[0]['username'],
        password: maps[0]['password'],
      );
    } else {
      // 如果没有找到任何记录，则返回null
      return null;
    }
  }

  Future<List<String>> getGeneralHistory() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'generalhistory',
    );
    if (maps.isNotEmpty) {
      return List.generate(maps.length, (i) {
        return maps[i]['time'];
      });
    }
    return [];
  }

  Future<String?> getGeneralHistoryByTime(String time) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'generalhistory',
      where: 'time = ?',
      whereArgs: [time],
    );
    if (maps.isNotEmpty) {
      return maps[0]['time'];
    } else {
      return null;
    }
  }
}

List<String> dataList = [
  "2023/11/12-21:05_example1",
  "2023/11/12-21:05_example2",
  // Add more items as needed
];
void dataListRefresh() {
  DatabaseHelper.instance.getGeneralHistory().then((data) {
    dataList = data; // 处理异步操作的结果
  });
}

class ArithmeticApp extends StatelessWidget {
  const ArithmeticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '算术练习',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class ArithmeticHomePage extends StatefulWidget {
  const ArithmeticHomePage({super.key, required String username});
  @override
  // ignore: library_private_types_in_public_api
  _ArithmeticHomePageState createState() =>
      _ArithmeticHomePageState(username: '');
}

class _ArithmeticHomePageState extends State<ArithmeticHomePage> {
  final String username;
  _ArithmeticHomePageState({required this.username});
  String question = '';
  String questionWithoutAnswer = '';
  int score = 0;
  var sta = '';
  final answerController = TextEditingController();
  @Deprecated('use username instead')
  void checkAnswer() {
    // 这里你需要包括逻辑来检查用户的答案是否正确。
    // 目前，它只是打印输入值。
    if (question.split(" ")[1] == answerController.text) {
      // print(answerController.text);
      score++;
    }

    // print(answerController.text);
    // 检查后，生成一个新问题。
    setState(() {
      // question = generateQuestion();
      // questionWithoutAnswer = question.split(" ")[0];
      // sta = question;

      answerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('算术练习 '),
        leading: const Icon(Icons.home),
        backgroundColor: Colors.blue[100],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                height: 50,
                width: 100,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "结果分析",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                  height: 50,
                  width: 100,
                  child: TextButton(
                    onPressed: () {
                      generateQuestion();
                    },
                    child: const Text(
                      "生成试题集",
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  )),
            ],
          ),
          //TODO :添加listview显示多个可点击文本
          Expanded(
              child: Column(
            children: [
              const Text(
                '试题集',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    // String quizset = dataList[index];
                    return ListTile(
                      title: Text(
                        dataList[index],
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        // TODO: Implement your logic for what happens when the text is clicked
                        // 在其他页面中，当你需要导航到QuizPage时：
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizPage(
                                quizSetId: 'set1'), // 假设试题集ID为'set1'
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  void _findAccountPassword() async {
    Account? account = await DatabaseHelper.instance
        .getAccountByUsername(_usernameController.text);

    if (account != null) {
      // 如果找到了账号，打印密码
      if (account.password == _passwordController.text) {
        _login(true);
      }
      // 注意：实际应用中不应该这样打印密码，这里只是为了演示
    } else {
      // 如果没有找到账号，可能需要处理这种情况
      _login(false);
    }
  }

  void _login(bool loginValid) {
    Map<String, String> account = {};
    // bool loginValid = false; // 你需要替换这里的逻辑来真正验证用户凭证
    account['HX'] = 'hh';
    // 假设登录验证是通过的
    if (account[_usernameController.text] == _passwordController.text) {
      loginValid = true;
    }

    if (loginValid) {
      // 使用 Navigator.push 来跳转到 HomePage，并传递用户名
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ArithmeticHomePage(username: _usernameController.text),
        ),
      );
    } else {
      // 如果登录失败，可以显示一个错误提示
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Invalid username or password.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _findAccountPassword,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String quizSetId;
  const QuizPage({super.key, required this.quizSetId});
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late int remainingTime;
  late Timer timer;
  late List<Question> questions;
  int score = 0;
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
    questions = loadQuizSet(widget.quizSetId);
  }

  List<Question> loadQuizSet(String quizSetId) {
    // 加载题库
    List<Question> question = [];
    for (int cnt = 0; cnt < 50; cnt++) {
      question.add(generateQuestion());
    }
    return question;
  }

  void checkAnswer(String userAnswer) {
    if (userAnswer == questions[currentQuestionIndex].correctAnswer) {
      setState(() {
        score++;
      });
    }
  }

  void startTimer() {
    remainingTime = 1800; // 假设倒计时时间是30min
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (remainingTime < 1) {
        t.cancel();
        goToScorePage(); // 倒计时结束，跳转到分数页面
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void goToScorePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScorePage(score: score),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel(); // 确保timer被取消
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Page'),
        ),
        body: Flex(direction: Axis.vertical, children: [
          Expanded(
            child: Column(
              children: [
                Text('Time Remaining: $remainingTime seconds'),
                Expanded(
                  child: Row(
                    children: [
                      // 题目的导航栏
                      NavigationPane(
                        questions: questions,
                        onSelectQuestion: (index) {
                          setState(() {
                            currentQuestionIndex = index;
                          });
                        },
                      ),
                      // 显示题目内容和答案输入框
                      Expanded(
                        child: Column(
                          children: [
                            QuestionDisplay(
                                question: questions[currentQuestionIndex]),
                            AnswerInputField(
                              question: questions[currentQuestionIndex],
                              onSubmitted: (answer) {
                                checkAnswer(answer);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ]));
  }
}

class NavigationPane extends StatelessWidget {
  final List<Question> questions;
  final ValueChanged<int> onSelectQuestion;

  const NavigationPane(
      {super.key, required this.questions, required this.onSelectQuestion});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, // 给导航栏一个固定宽度
      child: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Question ${index + 1}'),
            onTap: () => onSelectQuestion(index),
          );
        },
      ),
    );
  }
}

class QuestionDisplay extends StatelessWidget {
  final Question question;

  const QuestionDisplay({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.content, style: const TextStyle(fontSize: 24.0)),
            // 在此处添加选项的显示，如果有的话
          ],
        ),
      ),
    );
  }
}

class AnswerInputField extends StatelessWidget {
  final Question question;
  final Function(String) onSubmitted;
  const AnswerInputField(
      {super.key, required this.question, required this.onSubmitted});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Your Answer',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          onSubmitted(value);
        },
      ),
    );
  }
}

class ScorePage extends StatelessWidget {
  final int score;

  const ScorePage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Your score is: $score'),
            // 可以添加更多的信息或者按钮
          ],
        ),
      ),
    );
  }
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const ArithmeticApp());
}
