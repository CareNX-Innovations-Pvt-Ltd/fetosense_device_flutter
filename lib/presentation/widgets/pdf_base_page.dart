import 'package:fetosense_device_flutter/core/utils/date_format_utils.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/core/utils/svg_strings.dart';
import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:get_it/get_it.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A class representing a base page for a PDF document.
class PfdBasePage extends pw.StatelessWidget {
  final pw.Widget body;
  final Test data;
  final Interpretations2? interpretation;
  final Interpretations2? interpretation2;
  final int index;
  final int total;

  /// Creates a new instance of [PfdBasePage].
  ///
  /// [index] is the current page index.
  /// [total] is the total number of pages.
  /// [data] contains the test data.
  /// [interpretation] is the first interpretation data.
  /// [interpretation2] is the second interpretation data.
  /// [body] is the main content of the page.
  PfdBasePage({
    required this.index,
    required this.total,
    required this.data,
    required this.interpretation,
    required this.interpretation2,
    required this.body,
  });

  @override
  pw.Widget build(dynamic context) {
    final doctorsComment = splitTextIntoLines(data.interpretationExtraComments??"",2, 8 * PdfPageFormat.cm, 4);
    return pw.Column(
      children: [
        Header(data: data),
        pw.Flexible(
            child: pw.Row(children: [
              body,
              pw.Container(
                width: 7.5 * PdfPageFormat.cm,
                margin: const pw.EdgeInsets.only(top: PdfPageFormat.mm * 7),
                padding: const pw.EdgeInsets.symmetric(
                    vertical: PdfPageFormat.mm * 1),
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("FHR1",
                          style: pw.TextStyle(
                              color: PdfColors.teal,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.normal,
                              letterSpacing: 1.0),
                          textAlign: pw.TextAlign.left),
                      pw.SizedBox(height: PdfPageFormat.mm * 1.5),
                      pw.Row(
                        children: [
                          pw.RichText(
                            text: pw.TextSpan(
                              text: "BASAL HR",
                              children: const [
                                pw.TextSpan(
                                  text: "\nACCELERATION",
                                ),
                                pw.TextSpan(
                                  text: "\nDECELERATION",
                                ),
                                pw.TextSpan(
                                  text: "\nMOVEMENTS",
                                ),
                                pw.TextSpan(
                                  text: "\nFISHER SCORE",
                                ),
                                pw.TextSpan(
                                  text: "\nSHORT TERM VARI  ",
                                ),
                                pw.TextSpan(
                                  text: "\nLONG TERM VARI ",
                                ),
                              ],
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey,
                                  lineSpacing: PdfPageFormat.mm * 1.5,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                          pw.RichText(
                            text: pw.TextSpan(
                              text:
                                  ": ${(interpretation?.basalHeartRate ?? "--")} bpm",
                              children: [
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation?.getnAccelerationsStr() ?? "--")}",
                                ),
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation?.getnDecelerationsStr() ?? "--")}",
                                ),
                                pw.TextSpan(
                                  text:
                                      "\n: ${(data.movementEntries?.length)} manual / ${(data.autoFetalMovement?.length)} auto",
                                ),
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation?.fisherScore)}", //todo need to verify
                                ),
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation?.getShortTermVariationBpmStr() ?? "--")} bpm /${(interpretation?.getShortTermVariationMilliStr() ?? "--")} milli",
                                ),
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation?.getLongTermVariationStr() ?? "--")} bpm",
                                ),
                              ],
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  lineSpacing: PdfPageFormat.mm * 1.5,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            textAlign: pw.TextAlign.left,
                            /*
                        style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold),*/
                          ),
                        ],
                      ),
                      pw.SizedBox(height: PdfPageFormat.mm * 4),
                      pw.Text("FHR2",
                          style: pw.TextStyle(
                              color: PdfColors.teal,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.0),
                          textAlign: pw.TextAlign.left),
                      pw.SizedBox(height: PdfPageFormat.mm * 1.5),
                      pw.Row(
                        children: [
                          pw.RichText(
                            text: pw.TextSpan(
                              text: "BASAL HR",
                              children: const [
                                pw.TextSpan(
                                  text: "\nACCELERATION",
                                ),
                                pw.TextSpan(
                                  text: "\nDECELERATION",
                                ),
                                pw.TextSpan(
                                  text: "\nFISHER SCORE",
                                ),
                                pw.TextSpan(
                                  text: "\nSHORT TERM VARI ",
                                ),
                                pw.TextSpan(
                                  text: "\nLONG TERM VARI ",
                                ),
                              ],
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey,
                                  lineSpacing: PdfPageFormat.mm * 1.5,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                          pw.RichText(
                            text: pw.TextSpan(
                              text:
                                  ": ${(interpretation2?.basalHeartRate ?? "--")}",
                              children: [
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation2?.getnAccelerationsStr() ?? "--")}",
                                ),
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation2?.getnDecelerationsStr() ?? "--")}",
                                ),
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation2?.fisherScore ?? "--")}", //todo need to check here MP
                                ),
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation2?.getShortTermVariationBpmStr() ?? "--")}/${(interpretation2?.getShortTermVariationMilliStr() ?? "--")}",
                                ),
                                pw.TextSpan(
                                  text:
                                      "\n: ${(interpretation2?.getLongTermVariationStr() ?? "--")}",
                                ),
                              ],
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  lineSpacing: PdfPageFormat.mm * 1.5,
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            textAlign: pw.TextAlign.left,
                            /*
                        style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold),*/
                          ),
                        ],
                      ),
                      pw.SizedBox(height: PdfPageFormat.mm * 4),
                      pw.Text( data.interpretationType?.isNotEmpty ?? false ? "NOTES: ${data.interpretationType}" : "NOTES",
                          style: pw.TextStyle(
                              color: PdfColors.teal,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.0),
                          textAlign: pw.TextAlign.left
                      ),
                      // pw.SizedBox(height: PdfPageFormat.mm * 2),
                      ...List.generate(2, (index) {
                        return pw.Container(
                          width: PdfPageFormat.cm * 8,
                          height: PdfPageFormat.cm * 0.6, // Space between lines
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.grey, width: 1),
                            ),
                          ),
                          child: pw.Align(
                            alignment: pw.Alignment.bottomLeft,
                            child: pw.Text(
                              doctorsComment[index],
                              style: pw.TextStyle(
                                  color: PdfColors.teal,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal,
                                  letterSpacing: 1),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                        );
                      }),
                      pw.SizedBox(height: PdfPageFormat.mm * 5),
                      pw.TableHelper.fromTextArray(
                        border: pw.TableBorder.all(color: PdfColors.grey),
                        // Adds border to the entire table
                        headerStyle: const pw.TextStyle(fontSize: 6),
                        headerAlignment: pw.Alignment.centerLeft,
                        // Custom font for headers
                        cellPadding: const pw.EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        cellStyle: const pw.TextStyle(fontSize: 6),
                        headers: [
                          "Baseline freq",
                          "<10 or >180",
                          "100-10/160-180",
                          "100-160"
                        ],
                        //List<String>.generate(3, (col) => 'Header ${col + 1}'), // Optionally, you can add headers
                        data: [
                          ["Bandwidth", "< 5", "5-10 or 03>", "10 - 30"],
                          ["Zero cross", "< 2", "2 - 6", "> 6"],
                          ["Accelerations", "Absent", "Regular", "Sporadic"],
                          [
                            "Deceleration",
                            "Unfavorable",
                            "Less severe",
                            "Absent"
                          ]
                        ], //["Bandwidth","Zero cross","Accelerations", "Deceleration"],["Bandwidth","Zero cross","Accelerations", "Deceleration"],
                      ),
                      pw.SizedBox(height: PdfPageFormat.mm * 2),
                    ]),
              ),
            ]),
            fit: pw.FlexFit.tight),
        Footer(page: index, total: total),
      ],
    );
  }
}

/// A class representing the header of a PDF page.
class Header extends pw.StatelessWidget {
  /// [data] contains the test data.
  final Test data;

  Header({required this.data});

  late int timeScaleFactor;
  late int scale;

  final prefs = GetIt.I<PreferenceHelper>();

  @override
  pw.Widget build(dynamic context) {
    scale = prefs.getInt('scale') ?? 1;
    timeScaleFactor = scale == 3 ? 2 : 6;
    return pw.Container(
      //margin: const pw.EdgeInsets.only(top: 2 * PdfPageFormat.mm),
      padding: const pw.EdgeInsets.symmetric(
          horizontal: 3 * PdfPageFormat.mm, vertical: 3 * PdfPageFormat.mm),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(width: 1.0, color: PdfColors.grey)),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: PdfPageFormat.cm * 3,
            margin: const pw.EdgeInsets.only(
                right: 3 * PdfPageFormat.mm, left: PdfPageFormat.mm * 2),
            child: pw.FittedBox(
              child: pw.Flexible(
                child: pw.SvgImage(
                  svg: SvgStrings.fetosense_icon,
                  fit: pw.BoxFit.contain,
                ),
              ),
            ),
          ),
          pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                HeaderData(
                    title: "Hospital Name",
                    content: data.organizationName ?? ""),
                HeaderData(
                    title: "Doctor Name", content: data.doctorName ?? ""),
                HeaderData(title: "DATE", content: data.createdOn!.format()),
                HeaderData(
                    title: "TIME", content: data.createdOn!.format('hh:mm a')),
              ]),
          pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                HeaderData(title: "NAME", content: data.motherName ?? ""),
                HeaderData(
                    title: "AGE",
                    content: data.age != null ? "${data.age} Years" : ""),
                HeaderData(title: "GEST AGE", content: "${data.gAge} Weeks"),
                HeaderData(
                    title: "DURATION",
                    content: "${data.lengthOfTest! ~/ 60} Minutes" ?? ""),
              ]),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              HeaderData(title: "MOTHER ID", content: data.motherId!),
              HeaderData(title: "TEST ID", content: data.documentId ?? ""),
              HeaderData(
                  title: "X-Axis", content: "${timeScaleFactor * 10} SEC/DIV"),
              HeaderData(title: "Y-Axis", content: "20 BPM/DIV"),
            ],
          )
        ],
      ),
    );
  }
}

/// A class representing the footer of a PDF page.
class Footer extends pw.StatelessWidget {
  /// [page] is the current page number.
  /// [total] is the total number of pages.
  int page;
  int total;

  Footer({required this.page, this.total = 18});

  @override
  pw.Widget build(dynamic context) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8 * PdfPageFormat.mm),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(width: 1.0, color: PdfColors.grey)),
      ),
      height: 2 * PdfPageFormat.cm,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 24 * PdfPageFormat.cm,
            padding:
                const pw.EdgeInsets.symmetric(vertical: PdfPageFormat.mm * 4),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
                "Disclaimer : NST auto interpretation does not provide medical advice it is intended for informational purposes only. It is not a substitute for professional medical advice, diagnosis or treatment.",
                style: pw.TextStyle(
                    color: PdfColors.grey,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                    letterSpacing: 1.0),
                textAlign: pw.TextAlign.left),
          ),
          pw.Flexible(
            child: pw.Container(
              child: pw.Center(
                child: pw.Text(
                  "$page of $total",
                  style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.normal),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A helper method to create a bullet view with the given text and color.
  pw.Widget bulletView(String text, {String? color}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 1 * PdfPageFormat.mm),
        child: pw.Row(
          children: [
            /*pw.SvgImage(
              svg:
                  SvgStrings.icDot.replaceAll("#dot_color", color ?? "#030104"),
              fit: pw.BoxFit.contain,
              height: 2.5 * PdfPageFormat.mm,
            ),*/
            pw.SizedBox(width: 2 * PdfPageFormat.mm),
            pw.Text(
              text,
              style: pw.TextStyle(
                color: const PdfColor.fromInt(0xff0059A5),
                fontWeight: pw.FontWeight.normal,
                fontSize: 8,
                height: 6 * PdfPageFormat.mm,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ));
  }
}

/// A class representing a header data item.
class HeaderData extends pw.StatelessWidget {
  final String title;
  final String content;

  /// [title] is the title of the header data.
  /// [content] is the content of the header data.
  HeaderData({required this.title, required this.content});

  @override
  pw.Widget build(dynamic context) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: PdfPageFormat.mm),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 3 * PdfPageFormat.cm,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                  color: PdfColors.teal,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                  letterSpacing: 1.0),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.Container(
            width: 5 * PdfPageFormat.cm,
            child: pw.Text(
              content,
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 10,
                fontWeight: pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.left,
            ),
          )
        ],
      ),
    );
  }
}

List<String> splitTextIntoLines(String text, int maxLines, double maxWidthPerLine, double charWidth) {
  List<String> words = text.split(' '); // Split text into words
  List<String> lines = [];
  String currentLine = "";
  double currentWidth = 0;

  for (String word in words) {
    double wordWidth = word.length * charWidth; // Approximate width of the word

    // Check if adding the word exceeds the max width of the line
    if ((currentWidth + wordWidth) > maxWidthPerLine) {
      // Save the current line and start a new one
      lines.add(currentLine.trim());
      currentLine = word;
      currentWidth = wordWidth;

      // Stop if we have reached the max number of lines
      if (lines.length >= maxLines) {
        break;
      }
    } else {
      // Add word to the current line
      currentLine += (currentLine.isEmpty ? "" : " ") + word;
      currentWidth += wordWidth;
    }
  }

  // Add the last line if it’s not empty
  if (currentLine.isNotEmpty && lines.length < maxLines) {
    lines.add(currentLine.trim());
  }
  for(int i= lines.length-1;i<maxLines;i++){
    lines.add("");
  }

  return lines;
}