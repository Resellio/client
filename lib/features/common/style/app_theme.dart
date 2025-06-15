import 'package:flutter/material.dart';
import 'package:resellio/features/common/style/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: AppColors.primaryText, // Text/icons on primary color

      secondary: AppColors.accent,
      onSecondary: AppColors.primaryText, // Text/icons on secondary color

      primaryContainer: AppColors.primaryLight,

      error: AppColors.error,
      onError: AppColors.onPrimaryIcon, // Text/icons on error color

      surface: AppColors.surface,
      onSurface:
          AppColors.primaryText, // Text/icons on surface color (Cards, Dialogs)
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      dividerColor: AppColors.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),

      // textTheme: baseTextTheme
      //     .copyWith(
      //         // Apply primary/secondary text colors more broadly if needed
      //         bodyLarge: baseTextTheme.bodyLarge
      //             ?.copyWith(color: AppColors.primaryText),
      //         bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      //             color: AppColors.secondaryText), // Default body text
      //         titleMedium: baseTextTheme.titleMedium?.copyWith(
      //             color: AppColors.primaryText), // e.g., ListTile title
      //         labelLarge: baseTextTheme.labelLarge
      //             ?.copyWith(fontWeight: FontWeight.w600) // e.g., Button text
      //         )
      //     .apply(
      //       // You can apply default colors this way too
      //       bodyColor: AppColors.primaryText, // Default color for most text
      //       displayColor: AppColors.primaryText, // Default color for headlines
      //     ),
      // elevatedButtonTheme: ElevatedButtonThemeData(
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: colorScheme.primary,
      //     foregroundColor: colorScheme.onPrimary,
      //     textStyle: baseTextTheme.labelLarge, // Use text theme style
      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //   ),
      // ),
      // textButtonTheme: TextButtonThemeData(
      //     style: TextButton.styleFrom(
      //   foregroundColor: colorScheme.primary, // Usually primary color
      //   textStyle: baseTextTheme.labelLarge,
      // )),
      // outlinedButtonTheme: OutlinedButtonThemeData(
      //     style: OutlinedButton.styleFrom(
      //   foregroundColor: colorScheme.primary, // Text color
      //   side: BorderSide(
      //       color: colorScheme.primary.withOpacity(0.5)), // Border color
      //   textStyle: baseTextTheme.labelLarge,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(8),
      //   ),
      // )),
      // inputDecorationTheme: InputDecorationTheme(
      //   filled: true,
      //   fillColor:
      //       colorScheme.surface, // Or a slightly different color like grey[100]
      //   contentPadding:
      //       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      //   border: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(8),
      //     borderSide: BorderSide(color: AppColors.divider),
      //   ),
      //   enabledBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(8),
      //     borderSide: BorderSide(color: AppColors.divider),
      //   ),
      //   focusedBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(8),
      //     borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
      //   ),
      //   labelStyle: TextStyle(color: AppColors.secondaryText),
      //   hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.7)),
      // ),
      // chipTheme: ChipThemeData(
      //   backgroundColor: colorScheme.primary.withOpacity(0.1),
      //   labelStyle: TextStyle(color: colorScheme.primary),
      //   secondaryLabelStyle: TextStyle(
      //       color: colorScheme.onSecondary), // For selected state maybe
      //   secondarySelectedColor: colorScheme.primary, // Color when selected
      //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20),
      //     side: BorderSide.none,
      //   ),
      // ),
      // cardTheme: CardTheme(
      //   elevation: 2.0,
      //   color: AppColors.primaryLight,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12.0),
      //   ),
      //   margin: const EdgeInsets.symmetric(
      //       vertical: 4.0, horizontal: 0), // Default card margin
      // ),
      // listTileTheme: ListTileThemeData(
      //   iconColor: AppColors.secondaryText, // Default icon color in list tiles
      //   titleTextStyle:
      //       baseTextTheme.titleMedium, // Already set color in textTheme
      //   subtitleTextStyle:
      //       baseTextTheme.bodyMedium, // Already set color in textTheme
      // ),
      // floatingActionButtonTheme: FloatingActionButtonThemeData(
      //   backgroundColor: colorScheme.secondary,
      //   foregroundColor: colorScheme.onSecondary,
      // ),
    );
  }
}
