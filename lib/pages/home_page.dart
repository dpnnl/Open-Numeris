import 'package:flutter/material.dart';
import 'package:numeris/core/shared_preferences_service.dart';
import 'package:numeris/core/widgets.dart';
import 'package:numeris/main.dart';
import 'package:numeris/pages/quiz_page.dart';

// PÁGINA PRINCIPAL - HOME

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  // Quando a página inicia
  @override
  void initState() {
    loadData();
    super.initState();
  }

  // Observador de rota
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Atualiza página ao retornar
    setState(() {});
  }

  // Carrega os dados de SharedPreferencesService
  void loadData() async {
    await SharedPreferencesService.loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Utiliza HomeAppBar em widgets.dart
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: HomeAppBar(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(30),
          child: SingleChildScrollView(
            child: Column(
              spacing: 15.0,
              children: [
                // CATEGORIAS DE OPERAÇÕES
                Column(
                  spacing: 15.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryTitle(label: "Categorias"),
                    Column(
                      spacing: 5.0,
                      children: [
                        Row(
                          spacing: 5.0,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // CARD DE ADIÇÕES
                            CategoryCard(
                              operationTypeName: "Adições",
                              categoryIconPath: "assets/UI/shape_1.svg",
                              operationType: OperationType.addition,
                              operationDifficulty: OperationDifficulty.easy,
                              levelToUnlock: 0,
                            ),
                            // CARD DE SUBTRAÇÕES
                            CategoryCard(
                              operationTypeName: "Subtrações",
                              categoryIconPath: "assets/UI/shape_2.svg",
                              operationType: OperationType.subtraction,
                              operationDifficulty: OperationDifficulty.easy,
                              levelToUnlock: 2,
                            ),
                          ],
                        ),
                        Row(
                          spacing: 5.0,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // CARD DE MULTIPLICAÇÕES
                            CategoryCard(
                              operationTypeName: "Multiplicações",
                              categoryIconPath: "assets/UI/shape_3.svg",
                              operationType: OperationType.multiplication,
                              operationDifficulty: OperationDifficulty.easy,
                              levelToUnlock: 4,
                            ),
                            // CARD DE DIVISÕES
                            CategoryCard(
                              operationTypeName: "Divisões",
                              categoryIconPath: "assets/UI/shape_4.svg",
                              operationType: OperationType.division,
                              operationDifficulty: OperationDifficulty.easy,
                              levelToUnlock: 6,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                CustomSpacer(height: 500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
