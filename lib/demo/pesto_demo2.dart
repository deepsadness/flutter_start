import 'package:flutter/material.dart';
import 'package:flutter_start/demo/pesto/model.dart';

//0.写好主题
final _pTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.teal,
    accentColor: Colors.redAccent);

class PestoStyle extends TextStyle {
  const PestoStyle({
    double fontSize: 12.0,
    FontWeight fontWeight,
    Color color: Colors.black87,
    double letterSpacing,
    double height,
  }) : super(
          inherit: false,
          color: color,
          fontFamily: 'Raleway',
          fontSize: fontSize,
          fontWeight: fontWeight,
          textBaseline: TextBaseline.alphabetic,
          letterSpacing: letterSpacing,
          height: height,
        );
}

//还需要一个保存是否喜欢得字段
final Set<Recipe> _favoriteRecipes = new Set<Recipe>();

//包在最外层的容器
class PestoHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      //传递_favoriteRecipes给它
      RecipeGridPage(recipes: _favoriteRecipes.toList());
}

class RecipeGridPage extends StatefulWidget {
  final List<Recipe> recipes;

  RecipeGridPage({Key key, @required this.recipes}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecipeGridPageState();
}

const double kLogoHeight = 162.0;
const double kLogoWidth = 220.0;
const double kImageHeight = 108.0;
const double kTextHeight = 48.0;

class _RecipeGridPageState extends State<RecipeGridPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Recipe> items = kPestoRecipes;

  @override
  Widget build(BuildContext context) {
    print('items.length=${items.length}');
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    //因为需要floatingActionButton,所以需要Scaffold
    return Theme(
        //将context中的platform信息保留
        data: _pTheme.copyWith(platform: Theme.of(context).platform),
        child: Scaffold(
            key: scaffoldKey,
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.edit),
                onPressed: () {
                  //直接使用scaffoldKey.currentState弹出
                  scaffoldKey.currentState
                      .showSnackBar(SnackBar(content: Text('Not supported.')));
                }),
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                    pinned: true,
                    expandedHeight: _kAppBarHeight,
                    backgroundColor: Colors.teal,
                    actions: <Widget>[
                      GestureDetector(
                        onTap: () {
                          scaffoldKey.currentState.showSnackBar(
                              SnackBar(content: Text('Not supported.')));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.search),
                        ),
                      )
                    ],
                    flexibleSpace: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      //这是AppBar的总高度
                      double biggestHeight = constraints.biggest.height;
                      //当前的AppBar的真实高度，去掉了状态栏
                      final double appBarHeight =
                          biggestHeight - statusBarHeight;
                      //appBarHeight - kToolbarHeight 代表的是当前的扩展量，_kAppBarHeight - kToolbarHeight表示最大的扩展量

                      //t就是，变化的Scale
                      final double t = (appBarHeight - kToolbarHeight) /
                          (_kAppBarHeight - kToolbarHeight);
                      // begin + (end - begin) * t; lerp函数可以快速取到根据当前的比例中间值
                      final double extraPadding =
                          new Tween<double>(begin: 10.0, end: 24.0).lerp(t);
                      final double logoHeight =
                          appBarHeight - 1.5 * extraPadding;

                      //字体的样式没有发生变化。
                      final TextStyle titleStyle = const PestoStyle(
                          fontSize: kTextHeight,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3.0);

                      //字体所占用的rect空间
                      final RectTween _textRectTween = new RectTween(
                          begin: new Rect.fromLTWH(
                              0.0, kLogoHeight, kLogoWidth, kTextHeight),
                          end: new Rect.fromLTWH(
                              0.0, kImageHeight, kLogoWidth, kTextHeight));
                      //透明度变化的曲线。这里是easeInOut
                      final Curve _textOpacity =
                          const Interval(0.4, 1.0, curve: Curves.easeInOut);

                      //图片所占用的rect空间
                      final RectTween _imageRectTween = new RectTween(
                        begin: new Rect.fromLTWH(
                            0.0, 0.0, kLogoWidth, kLogoHeight),
                        end: new Rect.fromLTWH(
                            0.0, 0.0, kLogoWidth, kImageHeight),
                      );

                      return Padding(
                        padding: new EdgeInsets.only(
                          //这个padding就直接设置变化
                          top: statusBarHeight + 0.5 * extraPadding,
                          bottom: extraPadding,
                        ),
                        child: Center(
                          child: Transform(
                            //因为整体需要一个Scale的变化，所以就用transform.可以理解成css一样的transfrom动画。
                            //这里是使用单位矩阵*scale来计算.scale等于当前logo的高度占总共的高度
                            transform: new Matrix4.identity()
                              ..scale(logoHeight / kLogoHeight),
                            //布置在上中
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: kLogoWidth,
                              child: Stack(
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  Positioned.fromRect(
                                    //这里传递的占用位置也是不断变化的，这里说明其实我们外层其实也可以用SizedBox来实现？
                                    rect: _imageRectTween.lerp(t),
                                    child: new Image.asset(
                                      'flutter_gallery_assets/pesto/logo_small.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned.fromRect(
                                    rect: _textRectTween.lerp(t),
                                    child: Center(
                                      //创建一个透明度来包裹
                                      child: Opacity(
                                        //找到这个曲线上t百分比占的位置
                                        opacity: _textOpacity.transform(t),
                                        child: new Text('PESTO',
                                            style: titleStyle,
                                            textAlign: TextAlign.center),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return RecipeCard(
                      recipe: items[index],
                      onTap: () {
                        showRecipePage(context, items[index]);
                      },
                    );
                  },
                  childCount: items.length,
                )),
              ],
            )));
  }

  void showRecipePage(BuildContext context, Recipe item) {
    Navigator.push(
        context,
        new MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/pesto/recipe'),
          builder: (BuildContext context) {
            return new Theme(
              data: _pTheme.copyWith(platform: Theme.of(context).platform),
              child: new RecipePage(recipe: item),
            );
          },
        ));
  }
}

class RecipeCard extends StatelessWidget {
  final TextStyle titleStyle =
      const PestoStyle(fontSize: 24.0, fontWeight: FontWeight.w600);
  final TextStyle authorStyle =
      const PestoStyle(fontWeight: FontWeight.w500, color: Colors.black54);

  RecipeCard({Key key, @required this.recipe, this.onTap}) : super(key: key);

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: "${recipe.imagePath}",
              child: Image.asset(
                recipe.imagePath,
                fit: BoxFit.contain,
              ),
            ),
            Row(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: new Image.asset(
                    recipe.ingredientsImagePath,
                    width: 48.0,
                    height: 48.0,
                  ),
                ),
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(recipe.name,
                          style: titleStyle,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis),
                      new Text(recipe.author, style: authorStyle),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

const double _kAppBarHeight = 128.0;
const double _kFabHalfSize =
    28.0; // TODO(mpcomplete): needs to adapt to screen size
const double _kRecipePageMaxWidth = 500.0;

class RecipePage extends StatefulWidget {
  const RecipePage({Key key, this.recipe}) : super(key: key);

  final Recipe recipe;

  @override
  _RecipePageState createState() => new _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  double _getAppBarHeight(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.3;

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = _favoriteRecipes.contains(widget.recipe);
    final double appBarHeight = _getAppBarHeight(context);

    return new Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            Positioned(
              child: Hero(
                tag: "${widget.recipe.imagePath}",
                child: Image.asset(
                  widget.recipe.imagePath,
                  fit: BoxFit.cover,
                  height: appBarHeight + _kFabHalfSize,
                ),
              ),
              top: 0.0,
              left: 0.0,
              right: 0.0,
            ),
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: appBarHeight - _kFabHalfSize,
                  backgroundColor: Colors.transparent,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                      background: DecoratedBox(
                          decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: <Color>[Color(0x60000000), Color(0x00000000)],
                        begin: Alignment(0.0, -1.0),
                        end: Alignment(0.0, -0.2)),
                  ))),
                ),
                SliverToBoxAdapter(
                  child: new Stack(
                    children: <Widget>[
                      Container(
                        width: _kRecipePageMaxWidth,
                        padding: const EdgeInsets.only(top: _kFabHalfSize),
                        child: new RecipeSheet(recipe: widget.recipe),
                      ),
                      Positioned(
                        right: 16.0,
                        child: new FloatingActionButton(
                          child: new Icon(isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border),
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ));
  }

  void _toggleFavorite() {
    setState(() {
      if (_favoriteRecipes.contains(widget.recipe))
        _favoriteRecipes.remove(widget.recipe);
      else
        _favoriteRecipes.add(widget.recipe);
    });
  }
}

/// Displays the recipe's name and instructions.
class RecipeSheet extends StatelessWidget {
  final TextStyle titleStyle = const PestoStyle(fontSize: 34.0);
  final TextStyle descriptionStyle = const PestoStyle(
      fontSize: 15.0, color: Colors.black54, height: 24.0 / 15.0);
  final TextStyle itemStyle =
      const PestoStyle(fontSize: 15.0, height: 24.0 / 15.0);
  final TextStyle itemAmountStyle = new PestoStyle(
      fontSize: 15.0, color: _pTheme.primaryColor, height: 24.0 / 15.0);
  final TextStyle headingStyle = const PestoStyle(
      fontSize: 16.0, fontWeight: FontWeight.bold, height: 24.0 / 15.0);

  RecipeSheet({Key key, this.recipe}) : super(key: key);

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: new Table(
          columnWidths: const <int, TableColumnWidth>{
            0: const FixedColumnWidth(64.0)
          },
          children: <TableRow>[
            new TableRow(children: <Widget>[
              new TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: new Image.asset(recipe.ingredientsImagePath,
                      width: 32.0,
                      height: 32.0,
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown)),
              new TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: new Text(recipe.name, style: titleStyle)),
            ]),
            new TableRow(children: <Widget>[
              const SizedBox(),
              new Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: new Text(recipe.description, style: descriptionStyle)),
            ]),
            new TableRow(children: <Widget>[
              const SizedBox(),
              new Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 4.0),
                  child: new Text('Ingredients', style: headingStyle)),
            ]),
          ]
            ..addAll(recipe.ingredients.map((RecipeIngredient ingredient) {
              return _buildItemRow(ingredient.amount, ingredient.description);
            }))
            ..add(new TableRow(children: <Widget>[
              const SizedBox(),
              new Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 4.0),
                  child: new Text('Steps', style: headingStyle)),
            ]))
            ..addAll(recipe.steps.map((RecipeStep step) {
              return _buildItemRow(step.duration ?? '', step.description);
            })),
        ),
      ),
    );
  }

  TableRow _buildItemRow(String left, String right) {
    return new TableRow(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: new Text(left, style: itemAmountStyle),
        ),
        new Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: new Text(right, style: itemStyle),
        ),
      ],
    );
  }
}
