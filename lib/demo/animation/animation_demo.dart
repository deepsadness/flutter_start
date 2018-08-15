import 'package:flutter/material.dart';
import 'package:flutter_start/demo/animation/sections.dart';
import 'dart:math' as math;

Color _kAppBackgroundColor = const Color(0xFF353662);
Duration _kScrollDuration = const Duration(milliseconds: 400);
Curve _kScrollCurve = Curves.fastOutSlowIn;
const double _kAppBarMinHeight = 90.0;
const double _kAppBarMidHeight = 256.0;

class AnimationDemoHome extends StatefulWidget {
  const AnimationDemoHome({Key key}) : super(key: key);

  static const String routeName = '/animation';

  @override
  _AnimationDemoHomeState createState() => new _AnimationDemoHomeState();
}

class _AnimationDemoHomeState extends State<AnimationDemoHome> {
  final PageController _headingPageController = new PageController();
  final PageController _detailsPageController = new PageController();
  ValueNotifier<double> selectedIndex = new ValueNotifier<double>(0.0);
  final ScrollController _scrollController = new ScrollController();
  ScrollPhysics _headingScrollPhysics = const NeverScrollableScrollPhysics();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: _kAppBackgroundColor,
      body: new Builder(
        // Insert an element so that _buildBody can find the PrimaryScrollController.
        builder: _buildBody,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final double statusHeight = MediaQuery.of(context).padding.top;
    double height = MediaQuery.of(context).size.height;
    double remainHeight = kToolbarHeight + statusHeight;
    final double appBarMidScrollOffset = height - _kAppBarMidHeight;

    return new Stack(
      children: <Widget>[
        new CustomScrollView(
          physics: new _SnappingScrollPhysics(
              midScrollOffset: appBarMidScrollOffset),
          controller: _scrollController,
          slivers: <Widget>[
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                return _handleScrollNotification(
                    notification, appBarMidScrollOffset);
              },
              child: SliverAppBar(
                backgroundColor: _kAppBackgroundColor,
                expandedHeight: height - statusHeight,
                bottom: PreferredSize(
                  preferredSize:
                      const Size.fromHeight(_kAppBarMinHeight - kToolbarHeight),
                  child: Container(width: 0.0, height: 0.0),
                ),
                pinned: true,
                flexibleSpace: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  double t =
                      1.0 - (height - constraints.maxHeight) / (height * 0.3);
                  final Curve _textOpacity =
                      Interval(0.0, 1.0, curve: Curves.fastOutSlowIn);
                  double extraPaddingTop =
                      statusHeight * _textOpacity.transform(t.clamp(0.0, 1.0));

                  final Size size = constraints.biggest;
                  final double tColumnToRow = 1.0 -
                      ((size.height - _kAppBarMidHeight) /
                              (height - statusHeight - _kAppBarMidHeight))
                          .clamp(0.0, 1.0);

                  final List<Widget> sectionCards = <Widget>[];

                  for (int index = 0; index < allSections.length; index++) {
                    Section section = allSections[index];
                    sectionCards.add(_headerItemsFor(section));
                  }
                  List<Widget> children = [];
                  for (int index = 0; index < sectionCards.length; index++) {
                    children.add(new LayoutId(
                      id: 'card$index',
                      child: sectionCards[index],
                    ));
                  }

                  List<Widget> layoutChildren = [];

                  print('selectedIndex.value=${selectedIndex.value}');
                  for (int index = 0; index < sectionCards.length; index++) {
                    layoutChildren.add(new CustomMultiChildLayout(
                      delegate: _AllSectionsLayout(
                          tColumnToRow: tColumnToRow,
                          translation: new Alignment(
                              (selectedIndex.value - index) * 2.0 - 1.0, -1.0),
                          selectedIndex: selectedIndex.value
                          ),
                      children: children,
                    ));
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      return _handlePageNotification(notification,
                          _headingPageController, _detailsPageController);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: extraPaddingTop),
                      child: PageView(
                        physics: _headingScrollPhysics,
                        controller: _headingPageController,
                        children: layoutChildren,
                      ),
                    ),
                  );
                }),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 610.0,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    return _handlePageNotification(notification,
                        _detailsPageController, _headingPageController);
                  },
                  child: PageView(
                    controller: _detailsPageController,
                    children: allSections.map((Section section) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _detailItemsFor(section).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Iterable<Widget> _detailItemsFor(Section section) {
    final Iterable<Widget> detailItems =
        section.details.map((SectionDetail detail) {
      return new SectionDetailView(detail: detail);
    });
    return ListTile.divideTiles(context: context, tiles: detailItems);
  }

  Widget _headerItemsFor(Section section) {
    return SectionCard(section: section);
  }

  bool _handlePageNotification(ScrollNotification notification,
      PageController leader, PageController follower) {
    if (notification.depth == 0 && notification is ScrollUpdateNotification) {
      selectedIndex.value = leader.page;
      if (follower.page != leader.page)
        follower.position.jumpToWithoutSettling(
            leader.position.pixels); // ignore: deprecated_member_use
    }
    return false;
  }

  bool _handleScrollNotification(
      ScrollNotification notification, double midScrollOffset) {
    if (notification.depth == 0 && notification is ScrollUpdateNotification) {
      final ScrollPhysics physics =
          _scrollController.position.pixels >= midScrollOffset
              ? const PageScrollPhysics()
              : const NeverScrollableScrollPhysics();
      if (physics != _headingScrollPhysics) {
        setState(() {
          _headingScrollPhysics = physics;
        });
      }
    }
    return false;
  }

  void _handleChange() {
//    setState(() {
////      // The listenable's state is our build state, and it changed already.
////    });
  }

//  @override
//  void initState() {
//    super.initState();
//    selectedIndex.addListener(_handleChange);
//  }
//
//  @override
//  void didUpdateWidget(AnimationDemoHome oldWidget) {
//    super.didUpdateWidget(oldWidget);
//    selectedIndex.removeListener(_handleChange);
//    selectedIndex.addListener(_handleChange);
//  }
//
//  @override
//  void dispose() {
//    selectedIndex.removeListener(_handleChange);
//    super.dispose();
//  }
}

class SectionDetailView extends StatelessWidget {
  SectionDetailView({Key key, @required this.detail})
      : assert(detail != null && detail.imageAsset != null),
        assert((detail.imageAsset ?? detail.title) != null),
        super(key: key);

  final SectionDetail detail;

  @override
  Widget build(BuildContext context) {
    final Widget image = new DecoratedBox(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(6.0),
        image: new DecorationImage(
          image: new AssetImage(
            detail.imageAsset,
            package: detail.imageAssetPackage,
          ),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );

    Widget item;
    if (detail.title == null && detail.subtitle == null) {
      item = new Container(
        height: 240.0,
        padding: const EdgeInsets.all(16.0),
        child: new SafeArea(
          top: false,
          bottom: false,
          child: image,
        ),
      );
    } else {
      item = new ListTile(
        title: new Text(detail.title),
        subtitle: new Text(detail.subtitle),
        leading: new SizedBox(width: 32.0, height: 32.0, child: image),
      );
    }

    return new DecoratedBox(
      decoration: new BoxDecoration(color: Colors.grey.shade200),
      child: item,
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({Key key, @required this.section})
      : assert(section != null),
        super(key: key);

  final Section section;

  @override
  Widget build(BuildContext context) {
    return new Semantics(
      label: section.title,
      button: true,
      child: new DecoratedBox(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              section.leftColor,
              section.rightColor,
            ],
          ),
        ),
        child: new Image.asset(
          section.backgroundAsset,
          package: section.backgroundAssetPackage,
          color: const Color.fromRGBO(255, 255, 255, 0.075),
          colorBlendMode: BlendMode.modulate,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AllSectionsLayout extends MultiChildLayoutDelegate {
  int cardCount = 4;
  double selectedIndex = 0.0;
  double tColumnToRow = 0.0;

  ///Alignment(-1.0, -1.0) 表示矩形的左上角。
  ///Alignment(1.0, 1.0) 代表矩形的右下角。
  Alignment translation = new Alignment(0 * 2.0 - 1.0, -1.0);

  _AllSectionsLayout({this.tColumnToRow,this.selectedIndex,this.translation});

  @override
  void performLayout(Size size) {
    //初始值
    //竖向布局时
    //卡片的left
    final double columnCardX = size.width / 5.0;
    //卡片的宽度Width
    final double columnCardWidth = size.width - columnCardX;
    //卡片的高度
    final double columnCardHeight = size.height / cardCount;
    //横向布局时
    final double rowCardWidth = size.width;

    final Offset offset = translation.alongSize(size);

    double columnCardY = 0.0;
    double rowCardX = -(selectedIndex * rowCardWidth);

    print('rowCardX=$rowCardX , left=${offset.dx} ,offset=$offset');
    print('translation=$translation ');

    for (int index = 0; index < cardCount; index++) {
      // Layout the card for index.
      final Rect columnCardRect = new Rect.fromLTWH(
          columnCardX, columnCardY, columnCardWidth, columnCardHeight);
      final Rect rowCardRect =
          new Rect.fromLTWH(rowCardX, 0.0, rowCardWidth, size.height);
      //  定义好初始的位置和结束的位置，就可以使用这个lerp函数，轻松的找到中间状态值
      final Rect cardRect =
          _interpolateRect(columnCardRect, rowCardRect).shift(offset);
      final String cardId = 'card$index';
      if (hasChild(cardId)) {
        layoutChild(cardId, new BoxConstraints.tight(cardRect.size));
        positionChild(cardId, cardRect.topLeft);
      }

      columnCardY += columnCardHeight;
      rowCardX += rowCardWidth;
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) {
    print('oldDelegate=$oldDelegate');
    return false;
  }

  Rect _interpolateRect(Rect begin, Rect end) {
    return Rect.lerp(begin, end, tColumnToRow);
  }

  Offset _interpolatePoint(Offset begin, Offset end) {
    return Offset.lerp(begin, end, tColumnToRow);
  }
}

class _SnappingScrollPhysics extends ClampingScrollPhysics {
  const _SnappingScrollPhysics({
    ScrollPhysics parent,
    @required this.midScrollOffset,
  })  : assert(midScrollOffset != null),
        super(parent: parent);

  final double midScrollOffset;

  @override
  _SnappingScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new _SnappingScrollPhysics(
        parent: buildParent(ancestor), midScrollOffset: midScrollOffset);
  }

  Simulation _toMidScrollOffsetSimulation(double offset, double dragVelocity) {
    final double velocity = math.max(dragVelocity, minFlingVelocity);
    return new ScrollSpringSimulation(spring, offset, midScrollOffset, velocity,
        tolerance: tolerance);
  }

  Simulation _toZeroScrollOffsetSimulation(double offset, double dragVelocity) {
    final double velocity = math.max(dragVelocity, minFlingVelocity);
    return new ScrollSpringSimulation(spring, offset, 0.0, velocity,
        tolerance: tolerance);
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double dragVelocity) {
    final Simulation simulation =
        super.createBallisticSimulation(position, dragVelocity);
    final double offset = position.pixels;

    if (simulation != null) {
      // The drag ended with sufficient velocity to trigger creating a simulation.
      // If the simulation is headed up towards midScrollOffset but will not reach it,
      // then snap it there. Similarly if the simulation is headed down past
      // midScrollOffset but will not reach zero, then snap it to zero.
      final double simulationEnd = simulation.x(double.infinity);
      if (simulationEnd >= midScrollOffset) return simulation;
      if (dragVelocity > 0.0)
        return _toMidScrollOffsetSimulation(offset, dragVelocity);
      if (dragVelocity < 0.0)
        return _toZeroScrollOffsetSimulation(offset, dragVelocity);
    } else {
      // The user ended the drag with little or no velocity. If they
      // didn't leave the offset above midScrollOffset, then
      // snap to midScrollOffset if they're more than halfway there,
      // otherwise snap to zero.
      final double snapThreshold = midScrollOffset / 2.0;
      if (offset >= snapThreshold && offset < midScrollOffset)
        return _toMidScrollOffsetSimulation(offset, dragVelocity);
      if (offset > 0.0 && offset < snapThreshold)
        return _toZeroScrollOffsetSimulation(offset, dragVelocity);
    }
    return simulation;
  }
}
