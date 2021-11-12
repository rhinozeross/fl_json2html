import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'Petition.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convert JSON 2 HTML',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(title: 'JSON 2 HTML Converter for Petitions4Future'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();

  var inputUrl = TextEditingController();
  var outputUrl = TextEditingController();

  List<String> supportedURLs = [
    "openpetition.de",
    "epetitionen.bundestag.de",
    "weact.campact.de",
    "actionnetwork.org",
    "regenwald.org",
    "act.350.org",
    "act.wemove.eu",
    "act.greenpeace.de"
  ];
  String errorMessageEmptyURL =
      "Bitte gültige URL eingeben - Please enter supported URL";
  String errorMessageUnsupportedURL =
      "diese Webseite wird leider nicht unterstützt - This Website is not supported";
  String errorMessageInvalidResponse =
      "Bei dieser URL konnte KEINE gültige Petition gefunden werden - No valid Petition found on this URL";

  String varScraperUrl = "https://petitionscraper.u1l.de";
  String varPetitionUrl = "";
  String varUrl = "";
  bool isLoaded = false;

  Future<Petition> fetchPetition(String scraperUrl, String varUrl) async {
    var uriParsed = Uri.parse(varUrl);
    Map<String, String> queryParams = {'url': "$uriParsed"};
    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = scraperUrl + '?' + queryString;
    var uriIDontKnow = Uri.parse(requestUrl);
    var response = await http.get(uriIDontKnow, headers: {
      "Accept": "application/json",
    });

    print("TEST::: response: ${response.body}");

    if (response.statusCode == 200) {
      print("success");
      //TODO: hier muss noch ne verbesserte Prüfung rein..
      if (response.body.isEmpty) {
        outputUrl.text = errorMessageInvalidResponse;
        print("Failed to get JSON Objekt");
        throw Exception('Failed to get full JSON Objekt');
      } else {
        outputUrl.text = generateHTML(response, uriParsed);
      }
    }
    return Petition.fromJsonToObject(jsonDecode(response.body));
  }

  String generateHTML(http.Response response, Uri uriParsed) {
    Petition petition = new Petition(
        startdate: '',
        enddate: '',
        goal: '',
        initiator: '',
        addressee: '',
        description: '',
        signer: '',
        title: '');

    petition = Petition.fromJsonToObject(jsonDecode(response.body));

    //EndDate umformatieren
    String format = petition.enddate.toString();
    String formattedEndDate = "";
    if (format.contains('--')) {
      formattedEndDate = "";
      print("TEST::: Formatted EndDate: No EndDate available");
    } else {
      var arr = format.split('.');
      String formatEndDate = arr[2] + "-" + arr[1] + "-" + arr[0];

      final DateTime endDate = DateTime.parse(formatEndDate);
      final EndDateFormat =
          new DateFormat('dd MMMM yyyy'); //Formatierung: "15 May 2021"
      final DateFormat formatter = EndDateFormat;
      formattedEndDate = formatter.format(endDate);

      print("TEST::: Formatted EndDate: $formattedEndDate");
    }

    //HTML correct als String parsen
    String htmlOut = "Titel der Petition: " +
        petition.title +
        "\n\n<!-- wp:table -->\n" +
        '<figure class="wp-block-table"><table><tbody><tr><td>Erstellungsdatum:</td><td>' +
        petition.startdate.toString() +
        '</td></tr>' +
        '<tr><td>Frist:</td><td>' +
        petition.enddate.toString() +
        '</td></tr><tr><td>Quorum:</td><td>' +
        petition.goal.toString() +
        '</td></tr>' +
        '<tr><td>Organisator*innen:</td><td>' +
        petition.initiator +
        '</td></tr><tr><td>Adressat*innen:</td><td>' +
        petition.addressee +
        '</td></tr>' +
        '<tr><td>Kurzlink:</td><td>fffutu.re/...</td></tr><tr><td>Kurzbeschreibung:</td><td>' +
        petition.description +
        '</td></tr></tbody></table></figure>\n<!-- /wp:table -->\n\n' +
        '<!-- wp:buttons -->\n<div class="wp-block-buttons">\n<!-- wp:button -->\n' +
        '<div class="wp-block-button"><a class="wp-block-button__link" href=$uriParsed + '
            '" ..." target="_blank" rel="noreferrer noopener">Jetzt mitzeichnen!</a></div>\n' +
        '<!-- /wp:button -->\n\n<!-- wp:button -->\n' +
        '<div class="wp-block-button"><a class="wp-block-button__link" href= +'
            ' " ..." target="_blank" rel="noreferrer noopener">Download als PDF</a></div>\n' +
        '<!-- /wp:button -->\n\n<!-- wp:button -->\n' +
        '<div class="wp-block-button"><a class="wp-block-button__link" href="https://petitionsforfuture.de/wp-content/uploads/..." target="_blank" rel="noreferrer noopener">SharePic</a></div>\n' +
        '<!-- /wp:button --></div>\n<!-- /wp:buttons -->\n\n' +
        '<!-- wp:shortcode -->\n[countdown date=" ' +
        formattedEndDate +
        ' " format="dH"]\n<!-- /wp:shortcode -->';

    //HTML ans Eingabefeld Übergeben
    return htmlOut;
  }

  void _generateCode() async {
    var petUrl = inputUrl.text.toString();
    var isSupportedURL = false;

    for (var i = 0; i < supportedURLs.length; i++) {
      if (petUrl.contains(supportedURLs[i])) {
        isSupportedURL = true;
      }
    }
    if (petUrl.isNotEmpty) {
      if (isSupportedURL) {
        await fetchPetition(varScraperUrl, petUrl);
      } else {
        inputUrl.text = errorMessageUnsupportedURL;
        outputUrl.clear();
      }
    } else {
      inputUrl.text = errorMessageEmptyURL;
    }
  }

  Future<void> _copyHtmlToClipboard() async {
    await Clipboard.setData(ClipboardData(text: outputUrl.text));
    inputUrl.text = "OutputField Successfully copied to Clipboard";
  }

  void _clearForms() {
    inputUrl.clear();
    outputUrl.clear();
  }

  //Hier kommt das Design der Seite

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // This contains the Design
    return Scaffold(
      appBar: AppBar(
        // Wir brauchen ein Eingabe Feld, einen Button
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Scrollbar(
                controller: _scrollController, // <---- Here, the controller
                isAlwaysShown: true, // <---- Required
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Input URL",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: TextField(
                          controller: inputUrl,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Output HTML",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: TextField(
                          controller: outputUrl,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: ElevatedButton(
                            onPressed: _generateCode,
                            child: Text('Generate HTML Now',
                                style: TextStyle(color: Colors.white))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: ElevatedButton(
                            onPressed: _copyHtmlToClipboard,
                            child: Text('Copy Output HTML to Clipboard',
                                style: TextStyle(color: Colors.white))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: ElevatedButton(
                            onPressed: _clearForms,
                            child: Text('Clear Forms',
                                style: TextStyle(color: Colors.white))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
