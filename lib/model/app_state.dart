import 'package:flutter/material.dart';
import 'package:flutter_start/main.dart';
import 'dart:async';
import 'dart:io';

//定义一个变量来存储
class AppState {
  bool isLoading;

  ValueNotifier<bool> canListenLoading = ValueNotifier(false);

  AppState({this.isLoading = true});

  factory AppState.loading() => AppState(isLoading: true);

  factory AppState.completed() => AppState(isLoading: false);

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading}';
  }
}

/*
1. 从MediaQuery模仿的套路，我们知道，我们需要一个StatefulWidget作为外层的组件，
将我们的继承于InheritateWidget的组件build出去
*/
class AppStateContainer extends StatefulWidget {
  //这个state是我们需要的状态
  final AppState state;

  //这个child的是必须的，来显示我们正常的控件
  final Widget child;

  AppStateContainer({this.state, @required this.child});

  //4.模仿MediaQuery,提供一个of方法，来得到我们的State.
  static AppState of(BuildContext context) {
    //这个方法内，调用 context.inheritFromWidgetOfExactType
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  _AppStateContainerState createState() => _AppStateContainerState();
}

class _AppStateContainerState extends State<AppStateContainer> {
  //2. 在build方法内返回我们的InheritedWidget
  //这样App的层级就是 AppStateContainer->_InheritedStateContainer-> real app
  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: widget.state,
      child: widget.child,
    );
  }
}

//1. 模仿MediaQuery。简单的让这个持有我们想要保存的data
class _InheritedStateContainer extends InheritedWidget {
  final AppState data;

  //我们知道InheritedWidget总是包裹的一层，所以它必有child
  _InheritedStateContainer(
      {Key key, @required this.data, @required Widget child})
      : super(key: key, child: child);

  //参考MediaQuery,这个方法通常都是这样实现的。如果新的值和旧的值不相等，就需要notify
  @override
  bool updateShouldNotify(_InheritedStateContainer oldWidget) =>
      data != oldWidget.data;
}

class MyInheritedApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppStateContainer(
      state: AppState.loading(),
      child: new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new MyInheritedHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyInheritedHomePage extends StatefulWidget {
  MyInheritedHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomeInheritedPageState createState() => new _MyHomeInheritedPageState();
}

class _MyHomeInheritedPageState extends State<MyInheritedHomePage> {
  _MyHomeInheritedPageState() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies');
    if (appState == null) {
      print('state == null');
      appState = AppStateContainer.of(context);
      appState.canListenLoading.addListener(listener);
    }
  }

  @override
  void dispose() {
    print('dispose');
    if (appState != null) {
      appState.canListenLoading.removeListener(listener);
    }
    super.dispose();
  }

  @override
  void initState() {
    print('initState');
    listener = () {
      Future.delayed(Duration(seconds: 5)).then((value) {
        result = "From delay";
        setState(() {});
      });
    };
    super.initState();
  }

  AppState appState;
  String result = "";
  VoidCallback listener;

  @override
  Widget build(BuildContext context) {
    print('build');

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Center(
          child: appState.isLoading
              ? CircularProgressIndicator()
              : new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      'appState.isLoading = ${appState.isLoading}',
                    ),
                    new Text(
                      '${result}',
                    ),
                  ],
                ),
        ),
        floatingActionButton: new Builder(builder: (context) {
          return new FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                  new MaterialPageRoute<Null>(builder: (BuildContext context) {
                return MyHomePage(title: 'Second State Change Page');
              }));
//              appState.isLoading = !appState.isLoading;
//              setState(() {});
            },
            tooltip: 'Increment',
            child: new Icon(Icons.swap_horiz),
          );
        }));
  }
}
