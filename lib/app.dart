import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/map/bloc/map_bloc.dart';
import 'features/orders/bloc/order_bloc.dart';
import 'features/orders/bloc/order_event.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/chat/bloc/chat_event.dart';

/// Root application widget
class GobanApp extends StatelessWidget {
  const GobanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
        BlocProvider<MapBloc>(
          create: (_) => MapBloc(),
        ),
        BlocProvider<OrderBloc>(
          create: (_) => OrderBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final appRouter = AppRouter(authBloc: authBloc);

          return MaterialApp.router(
            title: 'Goban',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
