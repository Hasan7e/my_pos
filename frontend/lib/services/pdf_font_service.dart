import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFontService {
  PdfFontService._();

  static Future<pw.ThemeData> buildTheme() async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    return pw.ThemeData.withFont(base: regular, bold: bold);
  }
}
