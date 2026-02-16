import 'package:carpe_diem/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/database/database_helper.dart';
import 'package:carpe_diem/providers/label_provider.dart';
import 'package:carpe_diem/providers/task_provider.dart';
import 'package:carpe_diem/providers/project_provider.dart';
import 'package:carpe_diem/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initialize();

  runApp(const CarpeDiemApp());
}

class CarpeDiemApp extends StatelessWidget {
  const CarpeDiemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LabelProvider()..loadLabels()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()..loadProjects()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
