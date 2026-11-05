import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

abstract final class AppTheme {
  static ThemeData get claro => _build(Brightness.light);
  static ThemeData get escuro => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.laranja,
      brightness: brightness,
      primary: isDark ? AppColors.laranja : AppColors.laranjaEscuro,
      onPrimary: AppColors.branco,
      surface: isDark ? AppColors.grafite : AppColors.offWhite,
      onSurface: isDark ? AppColors.offWhite : AppColors.grafite,
      error: AppColors.erro,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.raio),
    );
    const textoBotao = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    const tamanhoBotao = Size.fromHeight(AppDimens.alturaBotao);

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final texto = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: texto.copyWith(
        bodyLarge: texto.bodyLarge?.copyWith(fontSize: 18),
        bodyMedium: texto.bodyMedium?.copyWith(fontSize: 16),
        titleLarge: texto.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.grafite,
        foregroundColor: AppColors.offWhite,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.offWhite,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: tamanhoBotao,
          shape: shape,
          textStyle: textoBotao,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: tamanhoBotao,
          shape: shape,
          textStyle: textoBotao,
          side: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: shape,
        color: isDark ? AppColors.grafiteClaro : AppColors.branco,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.grafiteClaro : AppColors.branco,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.espacoM,
          vertical: 20,
        ),
        labelStyle: const TextStyle(fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.raio),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(fontSize: 16),
      ),
    );
  }
}
