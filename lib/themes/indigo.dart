import 'package:flutter/material.dart';

class IndigoTheme {
  static final primaryColor = Colors.indigo[400];
  static final primaryFullColor = Colors.indigo[800];
  static final disableColor = Colors.grey[400];
  static final texContrastColor = Colors.blueGrey[100];
  static final hoverColor = Colors.indigo[50];

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: primaryColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: texContrastColor,
      titleTextStyle: TextStyle(fontSize: 20, color: texContrastColor),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      // style: ButtonStyle(
      //     foregroundColor: WidgetStateProperty.all(primaryColor),
      //     textStyle: WidgetStateProperty.all(TextStyle(
      //       fontSize: 16,
      //     )))
      style: TextButton.styleFrom(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        foregroundColor: texContrastColor,
        backgroundColor: primaryColor,
        disabledBackgroundColor: texContrastColor,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        // side: BorderSide(),
        textStyle: TextStyle(fontSize: 18),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: TextStyle(color: primaryColor),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor!),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor!),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    ),
    // dropdownMenuTheme: DropdownMenuThemeData(
    //   inputDecorationTheme:InputDecorationTheme(
    //     labelStyle: TextStyle(
    //       fontWeight: FontWeight.normal
    //     )
    //   ),
    //   textStyle: TextStyle(
    //     fontWeight: FontWeight.normal
    //   )
    // ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom()),

    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
    ),
  );
}
