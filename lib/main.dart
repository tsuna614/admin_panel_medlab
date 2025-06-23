import 'package:admin_panel_medlab/bloc/doctor-bloc/doctor_bloc.dart';
import 'package:admin_panel_medlab/bloc/order-bloc/order_bloc.dart';
import 'package:admin_panel_medlab/bloc/product-bloc/product_bloc.dart';
import 'package:admin_panel_medlab/bloc/user-bloc/user_bloc.dart';
import 'package:admin_panel_medlab/bloc/voucher-bloc/voucher_bloc.dart';
import 'package:admin_panel_medlab/services/api_client.dart';
import 'package:admin_panel_medlab/services/doctor_service.dart';
import 'package:admin_panel_medlab/services/order_service.dart';
import 'package:admin_panel_medlab/services/product_service.dart';
import 'package:admin_panel_medlab/services/user_service.dart';
import 'package:admin_panel_medlab/services/voucher_service.dart';
import 'package:admin_panel_medlab/view/navigating_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final dio = Dio();
  final apiClient = ApiClient(dio);

  getIt.registerLazySingleton(() => UserServiceImpl(apiClient));
  getIt.registerLazySingleton(() => ProductServiceImpl(apiClient));
  getIt.registerLazySingleton(() => OrderServiceImpl(apiClient));
  getIt.registerLazySingleton(() => DoctorServiceImpl(apiClient));
  getIt.registerLazySingleton(() => VoucherServiceImpl(apiClient));
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
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(userService: getIt<UserServiceImpl>()),
        ),
        BlocProvider<ProductBloc>(
          create: (context) =>
              ProductBloc(productService: getIt<ProductServiceImpl>()),
        ),
        BlocProvider<OrderBloc>(
          create: (context) =>
              OrderBloc(orderService: getIt<OrderServiceImpl>()),
        ),
        BlocProvider<DoctorBloc>(
          create: (context) =>
              DoctorBloc(doctorService: getIt<DoctorServiceImpl>()),
        ),
        BlocProvider<VoucherBloc>(
          create: (context) =>
              VoucherBloc(voucherService: getIt<VoucherServiceImpl>()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: NavigatingScreen(),
      ),
    );
  }
}
