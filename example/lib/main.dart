import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;

import 'package:prefs/prefs.dart' show Prefs;

import 'package:i10n_translator/i10n.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}):super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
      future: init(),
      initialData: false,
      builder: (_, snapshot) {
        return snapshot.hasData && snapshot.data
            ? MaterialApp(
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
                  final String locale = Prefs.getString('locale');
                  return locale.isEmpty ? locales.first : Locale(locale);
                },
                home: const MyHomePage(title: 'Flutter Demo Home Page'))
            : const Center(child: CircularProgressIndicator());
      },
    );

  Future<bool> init() async {
    // Initialize the library packages
    await Prefs.init();
    return I10n.initAsync();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter;

  @override
  void initState() {
    super.initState();
    _counter = Prefs.getInt('counter');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    Prefs.setInt('counter', _counter);
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
              style: Theme.of(context).textTheme.headline4,
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
        Prefs.setString('locale', value);
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

  @override
  void dispose() {
    Prefs.dispose();
    super.dispose();
  }
}
