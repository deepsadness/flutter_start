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

class _RecipeGridPageState extends State<RecipeGridPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Recipe> items = kPestoRecipes;

  @override
  Widget build(BuildContext context) {
    print('items.length=${items.length}');
    //因为需要floatingActionButton,所以需要Scaffold
    return Theme(
        //将context中的platform信息保留
        data: _pTheme.copyWith(platform: Theme.of(context).platform),
        child: Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text('静态页面'),
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
            ),
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.edit),
                onPressed: () {
                  //直接使用scaffoldKey.currentState弹出
                  scaffoldKey.currentState
                      .showSnackBar(SnackBar(content: Text('Not supported.')));
                }),
            body: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    recipe: items[index],
                    onTap: () {
                      showRecipePage(context, items[index]);
                    },
                  );
                })));
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
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: appBarHeight - _kFabHalfSize,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    widget.recipe.imagePath,
                    fit: BoxFit.cover,
                    height: appBarHeight - _kFabHalfSize,
                  ),
                  DecoratedBox(
                      decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: <Color>[Color(0x60000000), Color(0x00000000)],
                        begin: Alignment(0.0, -1.0),
                        end: Alignment(0.0, -0.2)),
                  ))
                ],
              )),
            ),
            SliverToBoxAdapter(
              child: new Stack(
                children: <Widget>[
//                  new ListView(
//                    children: <Widget>[
//                      new Stack(
//                        children: <Widget>[
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
//                        ],
//                      )
//                    ],
//                  )
                ],
              ),
            )
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
