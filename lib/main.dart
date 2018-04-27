import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

List<Task> tasks = [
  new Task(
      name: "Catch up with Brian",
      category: "Mobile Project",
      time: "5pm",
      color: Colors.orange,
      finished: false),
  new Task(
      name: "Make new icons",
      category: "Web App",
      time: "3pm",
      color: Colors.cyan,
      finished: true),
  new Task(
      name: "Design explorations",
      category: "Company Website",
      time: "2pm",
      color: Colors.pink,
      finished: false),
  new Task(
      name: "Lunch with Mary",
      category: "Grill House",
      time: "12pm",
      color: Colors.cyan,
      finished: true),
  new Task(
      name: "Teem Meeting",
      category: "Hangouts",
      time: "10am",
      color: Colors.cyan,
      hangouts: [],
      finished: false),
];

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final double imageHeight = 280.0;
  ScrollController scrollController;
  AnimationController animationController;
  ValueNotifier<bool> shouldOnlyCompletedBeShownNotifier =
      new ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: const Duration(seconds: 1));
    scrollController = new ScrollController();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          _buildTimeline(),
          new ClipPath(
            child: new Image.asset(
              'images/birds.jpg',
              fit: BoxFit.fitHeight,
              height: imageHeight,
              colorBlendMode: BlendMode.srcOver,
              color: new Color(0x665A5F75),
            ),
            clipper: new LineClipper(),
          ),
          _buildTopBar(context),
          _buildProfileRow(),
          _buildFab(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildMyTasksHeader(),
        _buildTasks(),
      ],
    );
  }

  Widget _buildTasks() {
    return new Expanded(
      child: new ListView(
        shrinkWrap: true,
        controller: scrollController,
        children: tasks
            .map((task) => new TaskRow(
                  showCompletedNotifier: shouldOnlyCompletedBeShownNotifier,
                  task: task,
                  speedFactor: tasks.indexOf(task) / tasks.length,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMyTasksHeader() {
    return new Padding(
      padding: new EdgeInsets.only(left: 64.0, top: imageHeight),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            'My Tasks',
            style: new TextStyle(fontSize: 34.0),
          ),
          new Text(
            'FEBRUARY 8, 2015',
            style: new TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 32.0),
      child: new Row(
        children: <Widget>[
          new Icon(
            Icons.menu,
            size: 32.0,
            color: Colors.white,
          ),
          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: new Text(
                "Timeline",
                style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w300),
              ),
            ),
          ),
          new Icon(
            Icons.linear_scale,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

//  _onFabTap() {
//    scrollController.jumpTo(0.0);
//    shouldOnlyCompletedBeShownNotifier.value =
//        !shouldOnlyCompletedBeShownNotifier.value;
//  }

  Widget _buildFab() {
    return new Positioned(
      top: imageHeight - 100.0,
      right: -40.0,
      child: new FilterFab(filterValueNotifier: shouldOnlyCompletedBeShownNotifier),
    );
  }

  Widget _buildTimeline() {
    return new Positioned(
        top: 0.0,
        bottom: 0.0,
        left: 32.0,
        child: new Container(
          width: 1.0,
          color: Colors.grey[300],
        ));
  }

  Widget _buildProfileRow() {
    return new Padding(
      padding: new EdgeInsets.only(left: 16.0, top: imageHeight / 2.5),
      child: new Row(
        children: <Widget>[
          new CircleAvatar(
            minRadius: 28.0,
            maxRadius: 28.0,
            backgroundImage: new AssetImage('images/avatar.jpg'),
          ),
          new Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Text(
                  'Ryan Barnes',
                  style: new TextStyle(
                      fontSize: 26.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
                new Text(
                  'Product designer',
                  style: new TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FilterFab extends StatefulWidget {
  final ValueNotifier<bool> filterValueNotifier;

  const FilterFab({Key key, this.filterValueNotifier}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new FilterFabState();
  }
}

class FilterFabState extends State<FilterFab>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;
  Animation<Color> colorAnimation;

  final double expandedSize = 180.0;
  final double hiddenSize = 20.0;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 200));
    animation = new CurvedAnimation(
        parent: animationController, curve: Curves.easeInOut);
    colorAnimation = new ColorTween(begin: Colors.pink, end: Colors.pink[800])
        .animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      width: expandedSize,
      height: expandedSize,
      child: new AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _buildExpandedBackground(),
                buildOption(Icons.check_circle, 0.0),
                buildOption(Icons.flash_on, -math.pi / 3),
                buildOption(Icons.access_time, -2 * math.pi / 3),
                buildOption(Icons.error_outline, math.pi),
                _buildFabCore(),
              ],
            );
          }),
    );
  }

  open() {
    if (animationController.isDismissed) {
      animationController.forward();
    }
  }

  close() {
    if (animationController.isCompleted) {
      animationController.reverse();
    }
  }

  _onFabTap() {
    if (animation.isDismissed) {
      open();
    } else {
      close();
    }
  }

  _onItemTap() {
    widget.filterValueNotifier.value = !widget.filterValueNotifier.value;
    close();
  }

  Widget _buildExpandedBackground() {
    return new Container(
      height: hiddenSize + (expandedSize - hiddenSize) * animation.value,
      width: hiddenSize + (expandedSize - hiddenSize) * animation.value,
      decoration: new BoxDecoration(shape: BoxShape.circle, color: Colors.pink),
    );
  }

  Widget _buildFabCore() {
    double defaultIconSize = 26.0;
    double scaleFactor = 2 * (animationController.value - 0.5).abs();
    return new FloatingActionButton(
      onPressed: _onFabTap,
      backgroundColor: colorAnimation.value,
      child: new Center(
        child: new Transform(
          alignment: Alignment.center,
          transform: new Matrix4.identity()..scale(1.0, scaleFactor),
          child: new Icon(
            animationController.value > 0.5 ? Icons.close : Icons.filter_list,
            color: Colors.white,
            size: defaultIconSize,
          ),
        ),
      ),
    );
  }

  Widget buildOption(IconData icon, double angle) {
    double iconSize = 0.0;
    if (animation.value > 0.5) {
      iconSize = 26 * animation.value;
    }
    double defaultPadding = 16.0;
    double padding = defaultPadding +
        (expandedSize - defaultPadding) * (1 - animation.value);
    return new Transform.rotate(
      angle: angle,
      child: new Align(
        alignment: Alignment.topCenter,
        child: new Padding(
          padding: new EdgeInsets.only(top: padding),
          child: new IconButton(
            onPressed: _onItemTap,
            icon: new Transform.rotate(
              angle: -angle,
              child: new Icon(
                icon,
                color: Colors.white,
              ),
            ),
            iconSize: iconSize,
            alignment: Alignment.topCenter,
            padding: new EdgeInsets.all(0.0),
          ),
        ),
      ),
    );
  }
}

class TaskRow extends StatefulWidget {
  final double speedFactor;
  final ValueNotifier<bool> showCompletedNotifier;
  final Task task;

  const TaskRow(
      {Key key, this.showCompletedNotifier, this.task, this.speedFactor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new TaskRowState();
  }
}

class TaskRowState extends State<TaskRow> with TickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;
  bool shouldBeShown;
  VoidCallback onFilterChanged;

  @override
  void initState() {
    super.initState();
    shouldBeShown = widget.task.finished || !widget.showCompletedNotifier.value;
    animationController = new AnimationController(
        value: 1.0,
        vsync: this,
        duration: new Duration(
            milliseconds: (200 * (1 + 2 * widget.speedFactor)).toInt()));
    animation = new CurvedAnimation(
        parent: animationController, curve: Curves.easeInOut);
    onFilterChanged = () {
      bool shouldOnlyCompletedBeShown = widget.showCompletedNotifier.value;
      bool shouldThisBeShown =
          widget.task.finished || !shouldOnlyCompletedBeShown;
      if (shouldThisBeShown != shouldBeShown) {
        if (shouldThisBeShown) {
          animationController
              .forward()
              .then((_) => setState(() => shouldBeShown = shouldThisBeShown));
        } else {
          animationController
              .reverse()
              .then((_) => setState(() => shouldBeShown = shouldThisBeShown));
        }
      }
    };
    widget.showCompletedNotifier.addListener(onFilterChanged);
  }

  @override
  void dispose() {
    animationController.dispose();
    widget.showCompletedNotifier.removeListener(onFilterChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dotSize = 12.0;
    return new AnimatedBuilder(
      animation: animation,
      builder: (context, child) => new Opacity(
            opacity: animation.value,
            child: new SizeTransition(
              sizeFactor: animation,
              child: new Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: new Row(
                  children: <Widget>[
                    new Padding(
                      padding: new EdgeInsets.symmetric(
                          horizontal: 32.0 - dotSize / 2),
                      child: new Container(
                        height: dotSize,
                        width: dotSize,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle, color: widget.task.color),
                      ),
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          widget.task.name,
                          style: new TextStyle(fontSize: 18.0),
                        ),
                        new Text(
                          widget.task.category,
                          style:
                              new TextStyle(fontSize: 12.0, color: Colors.grey),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

class Task {
  final String name;
  final String category;
  final String time;
  final List<String> hangouts;
  final Color color;
  final bool finished;

  Task(
      {this.name,
      this.category,
      this.time,
      this.hangouts,
      this.color,
      this.finished});
}

class LineClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0.0, size.height - 60.0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}