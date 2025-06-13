import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get_storage/get_storage.dart';
import 'package:newapp/routes.dart';
import 'package:newapp/screen/DisputeDetailsScreen.dart';
import 'package:newapp/screen/RegisterAccountScreen.dart';
import 'package:newapp/screen/SplashScreen.dart';
import 'package:newapp/screen/detailsScreen.dart';
import 'package:newapp/screen/homeScreen.dart';
import 'package:newapp/screen/honharKhiladiScreen.dart';
import 'package:newapp/screen/loginScreen.dart';
import 'package:newapp/utils/appcolors.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Quiz App",
      debugShowCheckedModeBanner: false,
      initialRoute: RouteConstant.startScreen,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appThemeColor),
        useMaterial3: true,
      ),
      getPages: getPages,
    );
  }
}

List<GetPage> getPages = [
  GetPage(
    name: RouteConstant.startScreen,
    page: () => const StartScreen(),
    transition: Transition.noTransition,
  ),

  GetPage(
    name: RouteConstant.loginScreen,
    page: () => const loginScreen(),
    transition: Transition.noTransition,
  ),

  GetPage(
    name: RouteConstant.homeScreen,
    page: () => const homeScreen(),
    transition: Transition.noTransition,
  ),
  GetPage(
    name: RouteConstant.honharScreen,
    page: () => const honharKhiladiScreen(),
    transition: Transition.noTransition,
  ),
  GetPage(
    name: RouteConstant.registerAccountScreen,
    page: () => const RegisterAccountScreen(),
    transition: Transition.noTransition,
  ),
  GetPage(
    name: RouteConstant.disputeDetailsScreen,
    page: () => const DisputeDetailsScreen(),
    transition: Transition.noTransition,
  ),

  GetPage(
    name: RouteConstant.detailsScreen,
    page: () => const detailsScreen(),
    transition: Transition.noTransition,
  ),

  /*GetPage(
    name: RouteConstant.categotyScreen,
    page: () => const CategoryScreen(),
    transition: Transition.noTransition,
  ),

  GetPage(
    name: RouteConstant.quizScreen,
    page: () => const QuizScreen(),
    transition: Transition.noTransition,
  ),

  GetPage(
    name: RouteConstant.resultScreen,
    page: () => const ResultScreen(score: 0, mcqs: [], total: 0),
    transition: Transition.noTransition,
  ),*/
];
