import 'package:admin_panel_medlab/bloc/product-bloc/product_bloc.dart';
import 'package:admin_panel_medlab/services/api_client.dart';
import 'package:admin_panel_medlab/services/product_service.dart';
import 'package:admin_panel_medlab/view/main_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final dio = Dio();
  final apiClient = ApiClient(dio);

  getIt.registerLazySingleton(() => ProductServiceImpl(apiClient));
}

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (context) =>
              ProductBloc(productService: getIt<ProductServiceImpl>()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MainScreen(),
      ),
    );
  }
}
