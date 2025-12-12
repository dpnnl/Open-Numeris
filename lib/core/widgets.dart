import 'dart:async';
import 'dart:math';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:numeris/core/colors.dart';
import 'package:numeris/core/shared_preferences_service.dart';
import 'package:numeris/pages/quiz_page.dart';

// CATEGORY CARD
// Card da categoria da operação, deve ter definido, nome do tipo da operação, ícone, tipo e dificuldade
class CategoryCard extends StatefulWidget {
  final String operationTypeName;
  final OperationType operationType;
  final OperationDifficulty operationDifficulty;
  final String categoryIconPath;
  final int levelToUnlock;

  const CategoryCard({
    super.key,
    required this.operationTypeName,
    required this.categoryIconPath,
    required this.operationType,
    required this.operationDifficulty,
    required this.levelToUnlock,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return widget.levelToUnlock >= SharedPreferencesService.currentLevel
        ? GestureDetector(
            onTap: () {
              showToast(
                "Desbloqueia no nível ${widget.levelToUnlock}",
                context: context,
                animation: StyledToastAnimation.fade,
                reverseAnimation: StyledToastAnimation.fade,
                backgroundColor: black,
                position: StyledToastPosition(align: Alignment.center),
              );
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0, bottom: 32.0),
                    child: Align(
                      alignment: AlignmentGeometry.bottomLeft,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/UI/locked.svg",
                            color: themeColor,
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Align(
                      alignment: AlignmentGeometry.topRight,
                      child: SvgPicture.asset(
                        widget.categoryIconPath,
                        color: backgroundColor,
                        height: 65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : OpenContainer(
            transitionType: ContainerTransitionType.fade,
            transitionDuration: const Duration(milliseconds: 500),
            openBuilder: (context, _) => QuizPage(
              operationDifficulty: widget.operationDifficulty,
              operationType: widget.operationType,
            ),
            closedElevation: 0,
            openElevation: 0,
            closedColor: white,
            openColor: backgroundColor,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            openShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            closedBuilder: (context, openContainer) => GestureDetector(
              onTap: openContainer,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.45,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, bottom: 32.0),
                      child: Align(
                        alignment: AlignmentGeometry.bottomLeft,
                        child: Row(children: [Text(widget.operationTypeName)]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Align(
                        alignment: AlignmentGeometry.topRight,
                        child: SvgPicture.asset(
                          widget.categoryIconPath,
                          color: themeColor,
                          height: 65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

// HOME APPBAR
// AppBar exclusiva da HomePage
class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar>
    with SingleTickerProviderStateMixin {
  // LEVEL TOOLTIP
  // Exibe quantidade atual de XP e necessária para subir de nível
  final JustTheController levelTooltipController = JustTheController();
  Timer? levelTooltipTimer;

  // COINS TOOLTIP
  // Exibe quantidade atual de moedas
  final JustTheController coinsTooltipController = JustTheController();
  Timer? coinsTooltipTimer;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool showAvatar = true;

  Timer? toggleTimer;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.75,
      upperBound: 1.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );

    _scaleController.value = 1.0;

    toggleTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _scaleController.reverse();
      setState(() => showAvatar = !showAvatar);
      await _scaleController.forward();
    });
  }

  @override
  void dispose() {
    levelTooltipController.dispose();
    coinsTooltipController.dispose();
    toggleTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TITLE
            Text(
              "Open Numeris",
              style: const TextStyle(fontFamily: "poppins-bold", fontSize: 25),
            ),
            const Spacer(),
            const SizedBox(width: 10),
            // PROFILE
            SizedBox(
              height: 65,
              width: 65,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularLevelProgress(
                    strokeWidth: 5,
                    progressColor: themeColor,
                    backgroundColor: white,
                    size: 65,
                    currentProgress: SharedPreferencesService.currentXp,
                    totalProgress: SharedPreferencesService.totalXpRequired,
                  ),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: showAvatar
                        // AVATAR
                        ? UserAvatar(size: 50)
                        // NÍVEL ATUAL
                        : Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${SharedPreferencesService.currentLevel}",
                              style: TextStyle(
                                color: white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "poppins-bold",
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// COMMON APPBAR
class CommonAppBar extends StatefulWidget {
  final String title;
  const CommonAppBar({super.key, required this.title});

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            // BACK ARROW
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/UI/back_arrow.svg",
                      height: 25,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),

            // TITLE
            Align(
              alignment: AlignmentGeometry.center,
              child: Text(
                widget.title,
                style: TextStyle(fontFamily: "poppins-bold", fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QUIZ APPBAR
// AppBar exclusiva do quiz
class QuizAppBar extends StatefulWidget {
  final int totalOperations;
  final int currentOperations;
  final String title;
  const QuizAppBar({
    super.key,
    required this.totalOperations,
    required this.currentOperations,
    required this.title,
  });

  @override
  State<QuizAppBar> createState() => _QuizAppBarState();
}

class _QuizAppBarState extends State<QuizAppBar> {
  // PROGRESS TOOLTIP
  // Exibe questão atual e total
  final JustTheController progressTooltipController = JustTheController();
  Timer? progressTooltipTimer;

  @override
  void dispose() {
    // Descarta progresstooltip
    progressTooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            // BACK ARROW
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/UI/back_arrow.svg",
                      height: 25,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),

            // TITLE
            Align(
              alignment: AlignmentGeometry.center,
              child: Text(
                widget.title,
                style: TextStyle(fontFamily: "poppins-bold", fontSize: 25),
              ),
            ),

            // CURRENT PROGRESS
            Align(
              alignment: AlignmentGeometry.centerRight,
              child: Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    JustTheTooltip(
                      controller: progressTooltipController,
                      backgroundColor: themeColor,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      fadeInDuration: Duration(milliseconds: 1000),
                      fadeOutDuration: Duration(milliseconds: 1000),
                      tailBaseWidth: 15.0,
                      tailLength: 10.0,
                      tailBuilder: roundedTipTailBuilder,
                      elevation: 0.0,
                      content: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Questão atual: ${widget.currentOperations}/${widget.totalOperations}",
                          style: TextStyle(color: white),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          progressTooltipController.showTooltip();
                          // Cancelar timer anterior, se existir
                          progressTooltipTimer?.cancel();

                          // Iniciar um novo timer para fechar
                          progressTooltipTimer = Timer(
                            Duration(seconds: 2),
                            () {
                              progressTooltipController.hideTooltip();
                            },
                          );
                        },
                        child: CircularLevelProgress(
                          strokeWidth: 5,
                          progressColor: themeColor,
                          backgroundColor: white,
                          size: 50,
                          currentProgress: widget.currentOperations,
                          totalProgress: widget.totalOperations,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// OPERATION CARD
// Exibe em um card a operação/questão atual
class OperationCard extends StatelessWidget {
  final String currentQuestion;

  const OperationCard({super.key, required this.currentQuestion});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            currentQuestion,
            style: TextStyle(
              fontSize: 50,
              fontFamily: "poppins-bold",
              color: themeColor,
            ),
          ),
        ),
      ),
    );
  }
}

// OPERATION OPTION
// Botão exclusivo para opções do quiz
// Status de selecionado ou não, a cor muda!
class OperationOption extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final bool isSelected;

  OperationOption({
    super.key,
    required this.onTap,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: isSelected ? white : themeColor,
            borderRadius: isSelected
                ? BorderRadius.circular(30)
                : BorderRadius.circular(100),
          ),

          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: isSelected ? themeColor : white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// OPERATION SEND
// Botão exclusivo para envio da resposta do quiz
class OperationSend extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;

  final bool showCorrect;
  final bool showIncorrect;

  const OperationSend({
    super.key,
    required this.onTap,
    this.isSelected = false,
    this.showCorrect = false,
    this.showIncorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    double borderRadius;
    String assetIconPath;
    Color iconColor;

    if (showCorrect) {
      backgroundColor = Colors.green;
      assetIconPath = "assets/UI/correct.svg";
      iconColor = Colors.white;
    } else if (showIncorrect) {
      backgroundColor = Colors.red;
      assetIconPath = "assets/UI/incorrect.svg";
      iconColor = Colors.white;
    } else {
      backgroundColor = isSelected ? themeColor : white;
      assetIconPath = "assets/UI/send.svg";
      iconColor = isSelected ? white : themeColor;
    }

    return GestureDetector(
      onTap: (isSelected && !showCorrect && !showIncorrect) ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(isSelected ? 100 : 30),
          ),
          child: Center(
            child: SvgPicture.asset(
              assetIconPath,
              height: 40,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

// BUTTON
// Botão comum
class CommonButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Color color;
  final double? width;
  final double? height;

  CommonButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          height: height ?? MediaQuery.of(context).size.height * 0.075,
          width: width ?? MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 15, color: white)),
          ),
        ),
      ),
    );
  }
}

// CHIP
// chip com ícone e label
class CommonChip extends StatelessWidget {
  final String iconPath;
  final String label;
  final Color color;

  const CommonChip({
    super.key,
    required this.iconPath,
    required this.label,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, height: 25, color: color),
            Padding(padding: const EdgeInsets.all(8.0), child: Text(label)),
          ],
        ),
      ),
    );
  }
}

// CATEGORY TITLE
class CategoryTitle extends StatelessWidget {
  final String label;

  const CategoryTitle({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    return // SELETOR DE HEAD
    Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 16.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Text(label),
      ),
    );
  }
}

// AVATAR
class UserAvatar extends StatelessWidget {
  final double size;

  const UserAvatar({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: transparent, shape: BoxShape.circle),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(100),
          child: SvgPicture.asset(
            "assets/UI/profile.svg",
            color: themeColor,
            height: 30,
          ),
        ),
      ),
    );
  }
}

class CustomSpacer extends StatelessWidget {
  final double? height;
  final double? width;

  const CustomSpacer({super.key, this.height, this.width});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width);
  }
}

// CICULAR LEVEL PROGRESS
// Widget personalizado para progresso, circular e animado
class CircularLevelProgress extends StatefulWidget {
  final int currentProgress;
  final int totalProgress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final double size;
  final Duration animationDuration;

  const CircularLevelProgress({
    Key? key,
    required this.currentProgress,
    required this.totalProgress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
    required this.size,
    this.animationDuration = const Duration(seconds: 1),
  }) : assert(totalProgress > 0, 'totalProgress deve ser > 0'),
       assert(
         currentProgress >= 0 && currentProgress <= totalProgress,
         'currentProgress deve estar entre 0 e totalProgress',
       ),
       super(key: key);

  @override
  _CircularLevelProgressState createState() => _CircularLevelProgressState();
}

class _CircularLevelProgressState extends State<CircularLevelProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldProgress = 0.0;
  bool _firstBuild = true;

  double _calculateProgress(int current, int total) {
    if (total == 0) return 0;
    return (current / total).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    // Para animação sempre inicia em 0
    _oldProgress = 0.0;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    final newProgress = _calculateProgress(
      widget.currentProgress,
      widget.totalProgress,
    );
    _animation = Tween<double>(
      begin: _oldProgress,
      end: newProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCirc));
    _controller.forward();
    _oldProgress = newProgress;
  }

  @override
  void didUpdateWidget(covariant CircularLevelProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newProgress = _calculateProgress(
      widget.currentProgress,
      widget.totalProgress,
    );
    if (newProgress != _oldProgress || _firstBuild) {
      _firstBuild = false;
      _animation = Tween<double>(
        begin: _oldProgress,
        end: newProgress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCirc));
      _oldProgress = newProgress;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularLevelProgressPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              progressColor: widget.progressColor,
              backgroundColor: widget.backgroundColor,
            ),
          );
        },
      ),
    );
  }
}

class _CircularLevelProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _CircularLevelProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Círculo do fundo
    canvas.drawCircle(center, radius, backgroundPaint);

    // Arco do progresso
    final startAngle = -90 * 3.1415926535 / 180;
    final sweepAngle = 2 * 3.1415926535 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularLevelProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// Setinha customizada do tooltip
Path roundedTipTailBuilder(
  Offset tip,
  Offset left,
  Offset right, {
  double radius = 3,
}) {
  final path = Path();
  final tipDirLeft = (tip - left).direction;
  final tipDirRight = (tip - right).direction;
  final curveStart = Offset(
    tip.dx - radius * cos(tipDirLeft),
    tip.dy - radius * sin(tipDirLeft),
  );
  final curveEnd = Offset(
    tip.dx - radius * cos(tipDirRight),
    tip.dy - radius * sin(tipDirRight),
  );
  path.moveTo(left.dx, left.dy);
  path.lineTo(curveStart.dx, curveStart.dy);
  path.quadraticBezierTo(tip.dx, tip.dy, curveEnd.dx, curveEnd.dy);
  path.lineTo(right.dx, right.dy);
  path.close();

  return path;
}
