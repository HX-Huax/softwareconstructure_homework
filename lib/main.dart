import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

Question generateQuestion() {
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
  Question out = Question(
      content:
          '${number1.toStringAsFixed(2)} $operator ${number2.toStringAsFixed(2)}',
      options: [],
      correctAnswer: answer.toStringAsFixed(2));
  return out;
}

class Question {
  String content;
  List<String> options;
  String correctAnswer;

  Question(
      {required this.content,
      required this.options,
      required this.correctAnswer});
}

List<String> dataList = [
  "2023/11/12-21:05_example1",
  "2023/11/12-21:05_example2",
  // Add more items as needed
];
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
                    onPressed: () {},
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
                    String quizset = dataList[index];
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

  void _login() {
    Map<String,String>account ={};
    bool loginValid = false; // 你需要替换这里的逻辑来真正验证用户凭证
    account['HX'] = 'hh';
    // 假设登录验证是通过的
    if(account[_usernameController.text] == _passwordController.text){
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
              onPressed: _login,
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
    remainingTime = 10; // 假设倒计时时间是10秒
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
        body: Expanded(
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
        ));
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
