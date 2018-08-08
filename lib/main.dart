import 'package:flutter/material.dart';
import 'package:flutter_start/model/app_state.dart';

void main() => runApp(new MyInheritedApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _changeState() {
    state.canListenLoading.value = true;
    setState(() {
      state.isLoading = !state.isLoading;
    });
  }

  AppState state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (state == null) {
      print('state == null');
      state = AppStateContainer.of(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'appState.isLoading = ${state.isLoading}',
            ),
            new Text(
              'appState.canListenLoading.value = ${state.canListenLoading.value}',
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _changeState,
        tooltip: 'ChangeState',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
