import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;

import 'package:i10n_translator/i10n.dart';

import 'i10n_words.dart' show i10nWords;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    I10n.init(map: i10nWords);
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          I10nDelegate(),
        ],
        supportedLocales: I10n.supportedLocales,
        localeListResolutionCallback:
            (List<Locale> locales, Iterable<Locale> supportedLocales) {
          return locales.first;
        },
        home: MyHomePage(title: 'Flutter Demo Home Page'));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void initState() {
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: I10n.t(widget.title),
        actions: [
          menuButton(),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            I10n.t(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: I10n.s('Increment'),
        child: const Icon(Icons.add),
      ),
    );
  }

  PopupMenuButton<String> menuButton() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        I10n.load(Locale(value));
        setState(() {});
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        const PopupMenuItem<String>(value: 'en', child: Text('en')),
        const PopupMenuItem<String>(value: 'fr', child: Text('fr')),
        const PopupMenuItem<String>(value: 'es', child: Text('es')),
        const PopupMenuItem<String>(value: 'de', child: Text('de')),
        const PopupMenuItem<String>(value: 'zh', child: Text('zh')),
        const PopupMenuItem<String>(value: 'ru', child: Text('ru')),
        const PopupMenuItem<String>(value: 'he', child: Text('he')),
        const PopupMenuItem<String>(value: 'fa', child: Text('fa')),
      ],
    );
  }
}
