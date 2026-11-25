import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/books/presentation/bloc/book_cubit.dart';
import 'features/books/presentation/bloc/wishlist_bloc.dart';
import 'features/books/presentation/bloc/wishlist_event.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/orders/presentation/bloc/order_bloc.dart';
import 'features/orders/presentation/bloc/order_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo sqflite cho desktop (Windows / Linux / macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const BookVerseApp());
}

/// Root widget ứng dụng BookVerse
class BookVerseApp extends StatelessWidget {
  const BookVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit.instance,
        ),
        BlocProvider<BookCubit>(
          create: (_) => BookCubit.instance,
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc()..add(const LoadCart()),
        ),
        BlocProvider<WishlistBloc>(
          create: (_) => WishlistBloc()..add(const LoadWishlist()),
        ),
        BlocProvider<OrderBloc>(
          create: (_) => OrderBloc()..add(const LoadOrders()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'BookVerse',
            debugShowCheckedModeBanner: false,

            // Theme Material 3
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,

            // GoRouter
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
