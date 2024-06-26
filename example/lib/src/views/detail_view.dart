import 'package:flutter/material.dart';
import 'package:health_example/src/widgets/theme.dart';

class DetailView extends StatefulWidget {
  DetailView({super.key, this.title});
  final String? title;

  List<Color> get availableColors => const <Color>[
        AppColors.contentColorPurple,
        AppColors.contentColorYellow,
        AppColors.contentColorBlue,
        AppColors.contentColorOrange,
        AppColors.contentColorPink,
        AppColors.contentColorRed,
        AppColors.contentColorGreen,
      ];

  final Color barBackgroundColor =
      AppColors.contentColorWhite.darken().withOpacity(0.3);
  final Color barColor = AppColors.contentColorWhite;
  final Color touchedBarColor = AppColors.contentColorGreen;

  @override
  State<StatefulWidget> createState() => DetailViewState();
}

class DetailViewState extends State<DetailView>
    with SingleTickerProviderStateMixin {
  final Duration animDuration = const Duration(milliseconds: 250);
  late TabController _tabController;

  int touchedIndex = -1;
  int touchedPieIndex = -1;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                iconTheme:
                    const IconThemeData(color: AppColors.contentColorWhite),
                elevation: 10,
                shadowColor: AppColors.contentColorWhite,
                backgroundColor: AppColors.pageBackground,
                centerTitle: true,
                title: Text(
                  "${widget.title} Details", //TODO - Change with a var that would make it say like "Sleep Details"
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Daily"),
                    Tab(text: "Weekly"),
                    Tab(text: "Monthly"),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              //TODO - Create New Summary Classes
              // DailySummary(),
              // WeeklySummary(
              //   animDuration: animDuration,
              //   touchedIndex: touchedIndex,
              //   onBarTouched: (index) {
              //     setState(() {
              //       touchedIndex = index;
              //       touchedPieIndex = index;
              //     });
              //   },
              //   availableColors: widget.availableColors,
              //   barBackgroundColor: widget.barBackgroundColor,
              //   barColor: widget.barColor,
              //   touchedBarColor: widget.touchedBarColor,
              // ),
              // ListView(
              //   children: const [
              //     Placeholder(), // Replace with your MonthlySummary widget
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
