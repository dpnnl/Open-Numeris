import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:numeris/core/colors.dart';
import 'package:numeris/core/shared_preferences_service.dart';
import 'package:numeris/core/widgets.dart';
import 'package:vibration/vibration.dart';

// PÁGINA DO QUIZ

// Define tipo de quiz, pode ser acessado externamente
enum OperationType { addition, subtraction, multiplication, division }

// Define dificuldade do quiz, pode ser acessado externamente
enum OperationDifficulty { easy, medium, hard }

class QuizPage extends StatefulWidget {
  final OperationDifficulty operationDifficulty;
  final OperationType operationType;

  const QuizPage({
    super.key,
    required this.operationDifficulty,
    required this.operationType,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  int? selectedOption;
  int score = 0;

  late AnimationController scaleController;
  late Animation<double> scaleAnimation;

  // Variáveis para mostrar feedback visual no botão
  bool showCorrect = false;
  bool showIncorrect = false;

  @override
  void initState() {
    super.initState();

    // Ao entrar na página, redefine score
    score = 0;

    // Controlador da animação de escala
    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
    );

    scaleAnimation = CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeIn,
    );

    // Chama a geração de questões, com base no tipo de operação e dificuldade
    generateQuestions(widget.operationType);

    // Embaralha as questões
    questions.shuffle();

    // Começa pela primeira questão
    currentQuestionIndex = 0;

    scaleController.forward();
  }

  // Gera questões, com base no tipo de operação e dificuldades definidos quando for chamada
  void generateQuestions(OperationType operationType) {
    int maxNumber = 10;

    // Com base no maior número definido gera os termos/números (apenas 2 - x + x)
    final r = Random();

    // Quantidade de questões
    int questionsCount = 0;

    switch (SharedPreferencesService.currentLevel) {
      case <= 10:
        questionsCount = 10;
        maxNumber = 10;
      case <= 20:
        questionsCount = 15;
        maxNumber = 20;
      case < 30 && > 30:
        questionsCount = 20;
        maxNumber = 20;
    }

    questions = List.generate(questionsCount, (_) {
      int a = r.nextInt(maxNumber) + 1;
      int b = r.nextInt(maxNumber) + 1;

      // Define a resposta correta, com base no tipo de operação
      late int correct;
      String questionText;

      switch (operationType) {
        case OperationType.addition:
          correct = a + b;
          questionText = "$a + $b ?";
          break;
        case OperationType.subtraction:
          // Garante que a resposta correta não seja negativa
          if (a < b) {
            int temp = a;
            a = b;
            b = temp;
          }
          correct = a - b;
          questionText = "$a - $b ?";
          break;
        case OperationType.multiplication:
          correct = a * b;
          questionText = "$a × $b ?";
          break;
        case OperationType.division:
          // Evita divisão por 0
          b = r.nextInt(maxNumber - 1) + 1; // b != 0
          int product = a * b;
          correct = a;
          questionText = "$product ÷ $b ?";
          break;
      }

      // Define opções e embaralha elas
      List<int> options = [correct, correct + 1, max(0, correct - 1)];
      options.shuffle();

      // Retorna questão, opções e opção correta
      return {'question': questionText, 'options': options, 'answer': correct};
    });
  }

  // Define título da pagina com base no tipo de operação
  String getOperationTitle(OperationType type) {
    switch (type) {
      case OperationType.addition:
        return "Additions";
      case OperationType.subtraction:
        return "Subtractions";
      case OperationType.multiplication:
        return "Multiplications";
      case OperationType.division:
        return "Divisions";
    }
  }

  @override
  void dispose() {
    // Descarta controlador da animação de escala
    scaleController.dispose();
    super.dispose();
  }

  void onOptionTap(int option) {
    setState(() {
      selectedOption = option;
    });
  }

  // Anima questão, opções e botão de enviar resposta
  Future<void> animateAndNext() async {
    await scaleController.reverse();

    // Verifica se a opção selecionada está correta
    bool isCorrect =
        selectedOption == questions[currentQuestionIndex]['answer'];

    // Feedback visual no botão
    setState(() {
      showCorrect = isCorrect;
      showIncorrect = !isCorrect;
    });

    // Remove opção selecionada
    selectedOption = null;

    // Mostra diálogo de correto/incorreto, fecha automaticamente

    // VIBRATION
    if (isCorrect) {
      Vibration.vibrate(duration: 150);
    } else {
      Vibration.vibrate(duration: 250);
    }

    // Aguarda um tempo para mostrar o feedback no botão antes de prosseguir
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      showCorrect = false;
      showIncorrect = false;

      // Incrementa o score se estiver correto
      if (isCorrect) {
        score++;
      }

      // Avança para próxima questão ou exibe diálogo final se for a última
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        scaleController.forward();
      } else {
        double acertosPercent = (score / questions.length) * 100;

        // Se acertos >= 60%, dá XP e mostra diálogo final de sucesso
        if (acertosPercent >= 60) {
          int XPgained = 10;
          int coinsGained = 10;
          bool levelUP = SharedPreferencesService.addXp(XPgained);

          SharedPreferencesService.addCoins(coinsGained);

          // VIBRATION
          Vibration.vibrate(duration: 250);

          showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: backgroundColor,
            builder: (_) => PopScope(
              canPop: false,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 15.0,
                    children: [
                      SvgPicture.asset(
                        "assets/UI/correct.svg",
                        color: themeColor,
                        height: 100,
                      ),
                      Text(
                        "Uau! Muito bem!",
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: "poppins-bold",
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 10.0,
                          children: [
                            CommonChip(
                              label: "$score",
                              iconPath: "assets/UI/correct_2.svg",
                              color: green,
                            ),
                            CommonChip(
                              label: "${questions.length - score}",
                              iconPath: "assets/UI/incorrect_2.svg",
                              color: red,
                            ),
                            CommonChip(
                              label: "$XPgained",
                              iconPath: "assets/UI/xp.svg",
                              color: blue,
                            ),
                          ],
                        ),
                      ),
                      if (levelUP)
                        SizedBox(
                          width: 150,
                          child: CommonChip(
                            label: "Subiu de nível!",
                            iconPath: "assets/UI/level_up.svg",
                            color: blue,
                          ),
                        ),
                      CommonButton(
                        onTap: () {
                          // Fecha diálogo e depois fecha página do quiz
                          Navigator.of(context).pop();
                          Navigator.of(context).maybePop();
                        },
                        label: "FECHAR",
                        color: themeColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // Se acertos < 60%, mostra diálogo final informando que não ganhou XP
          // VIBRATION
          Vibration.vibrate(duration: 500);

          showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: backgroundColor,
            builder: (_) => PopScope(
              canPop: false,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 15.0,
                    children: [
                      SvgPicture.asset(
                        "assets/UI/incorrect.svg",
                        color: red,
                        height: 100,
                      ),
                      Text(
                        "Quase lá...",
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: "poppins-bold",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Você não se saiu muito bem neste desafio... que tal tentar novamente?",
                        ),
                      ),
                      CommonButton(
                        onTap: () {
                          // Fecha diálogo e depois fecha página do quiz
                          Navigator.of(context).pop();
                          Navigator.of(context).maybePop();
                        },
                        label: "FECHAR",
                        color: red,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }
    });
  }

  // Verifica e executa ação ao enviar resposta
  void onSendTap() {
    if (selectedOption == null || showCorrect || showIncorrect) return;
    animateAndNext();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];
    final options = question['options'] as List<int>;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: QuizAppBar(
            totalOperations: questions.length,
            currentOperations: currentQuestionIndex + 1,
            title: getOperationTitle(widget.operationType),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 25.0,
          children: [
            ScaleTransition(
              scale: scaleAnimation,
              child: Center(
                child: OperationCard(currentQuestion: question['question']),
              ),
            ),
            ...options.map(
              (opt) => ScaleTransition(
                scale: scaleAnimation,
                child: OperationOption(
                  label: opt.toString(),
                  onTap: () => onOptionTap(opt),
                  isSelected: selectedOption == opt,
                ),
              ),
            ),
            ScaleTransition(
              scale: scaleAnimation,
              child: OperationSend(
                onTap: onSendTap,
                isSelected: selectedOption != null,
                showCorrect: showCorrect,
                showIncorrect: showIncorrect,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
