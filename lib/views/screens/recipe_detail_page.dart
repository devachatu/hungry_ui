import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/views/screens/full_screen_image.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/ingridient_tile.dart';
import 'package:hungry/views/widgets/review_tile.dart';
import 'package:hungry/views/widgets/step_tile.dart';

import '../../prompts/defined_prompts.dart';
import '../../services/open_ai_service.dart';

class RecipeDetailPage extends StatefulWidget {
  Recipe data;
  RecipeDetailPage({required this.data});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final OpenAIService openAIService = Get.find();
  Map<String, String> replacements = {"dish_name": "", "quantity": "2"};
  List<Recipe> sarchResultRecipe = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    replacements["dish_name"] = widget.data.title;
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(() {
      changeAppBarColor(_scrollController);
    });
    _getSearchIngredients();
    _getSearchRecipe();
    _getSearchReviews();
  }

  Color appBarColor = Colors.transparent;

  changeAppBarColor(ScrollController scrollController) {
    if (scrollController.position.hasPixels) {
      if (scrollController.position.pixels > 2.0) {
        setState(() {
          appBarColor = AppColor.primary;
        });
      }
      if (scrollController.position.pixels <= 2.0) {
        setState(() {
          appBarColor = Colors.transparent;
        });
      }
    } else {
      setState(() {
        appBarColor = Colors.transparent;
      });
    }
  }

  // fab to write review
  showFAB(TabController tabController) {
    int reviewTabIndex = 2;
    if (tabController.index == reviewTabIndex) {
      return true;
    }
    return false;
  }

  _getSearchIngredients() async {
    // Replace placeholders
    setState(() {
      _loading = true;
    });
    String filledString = DefinedPrompts.DISH_INGREDIENTS_DETAILS;
    replacements.forEach((key, value) {
      filledString = filledString.replaceAll('{$key}', value);
    });
    print(filledString);
    final response = await openAIService.sendMessage(filledString);
    List recipeSearchResultRawData = response as List;
    setState(() {
      widget.data.ingridients = recipeSearchResultRawData
          .map((data) =>
              Ingridient(name: data['name'], size: data['size'].toString()))
          .toList();
      _loading = false;
    });
  }

  _getSearchRecipe() async {
    // Replace placeholders
    setState(() {
      _loading = true;
    });
    String filledString = DefinedPrompts.DISH_TUTORIAL_DETAILS;
    replacements.forEach((key, value) {
      filledString = filledString.replaceAll('{$key}', value);
    });
    print(filledString);
    final response = await openAIService.sendMessage(filledString);
    List recipeSearchResultRawData = response as List;
    setState(() {
      widget.data.tutorial = recipeSearchResultRawData
          .map((data) => TutorialStep(
              step: data['step'].toString(),
              description: data['description'].toString()))
          .toList();
      _loading = false;
    });
  }

  _getSearchReviews() async {
    // Replace placeholders
    setState(() {
      _loading = true;
    });
    String filledString = DefinedPrompts.DISH_REVIEW_DETAILS;
    replacements.forEach((key, value) {
      filledString = filledString.replaceAll('{$key}', value);
    });
    print(filledString);
    final response = await openAIService.sendMessage(filledString);
    List recipeSearchResultRawData = response as List;
    setState(() {
      widget.data.reviews = recipeSearchResultRawData
          .map((data) => Review(
              username: data['username'].toString(),
              review: data['review'].toString()))
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AnimatedContainer(
          color: appBarColor,
          duration: Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Search Recipe',
                style: TextStyle(
                    fontFamily: 'inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset('assets/icons/bookmark.svg',
                      color: Colors.white)),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
      ),
      // Post Review FAB
      floatingActionButton: Visibility(
        visible: showFAB(_tabController),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      color: Colors.white,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        minLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Write your review here...',
                        ),
                        maxLines: null,
                      ),
                    ),
                    actions: [
                      Row(
                        children: [
                          Container(
                            width: 120,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('cancel'),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text('Post Review'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                });
          },
          child: Icon(Icons.edit),
          backgroundColor: AppColor.primary,
        ),
      ),
      body: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Recipe Image
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FullScreenImage(
                      image:
                          Image.asset(widget.data.photo, fit: BoxFit.cover))));
            },
            child: Container(
              height: 280,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(widget.data.photo), fit: BoxFit.cover)),
              child: Container(
                decoration: BoxDecoration(gradient: AppColor.linearBlackTop),
                height: 280,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          // Section 2 - Recipe Info
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
            color: AppColor.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Calories and Time
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/fire-filled.svg',
                      color: Colors.white,
                      width: 16,
                      height: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        widget.data.calories,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.alarm, size: 16, color: Colors.white),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        widget.data.time,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                // Recipe Title
                Container(
                  margin: EdgeInsets.only(bottom: 12, top: 16),
                  child: Text(
                    widget.data.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter'),
                  ),
                ),
                // Recipe Description
                Text(
                  widget.data.description,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 150 / 100),
                ),
              ],
            ),
          ),
          // Tabbar ( Ingridients, Tutorial, Reviews )
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            color: AppColor.secondary,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _tabController.index = index;
                });
              },
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.6),
              labelStyle:
                  TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w500),
              indicatorColor: Colors.black,
              tabs: [
                Tab(
                  text: 'Ingridients',
                ),
                Tab(
                  text: 'Tutorial',
                ),
                Tab(
                  text: 'Reviews',
                ),
              ],
            ),
          ),
          // IndexedStack based on TabBar index
          _loading
              ? Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _tabController.index,
                  children: [
                    // Ingridients
                    if (widget.data.ingridients != null)
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.data.ingridients!.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return IngridientTile(
                            data: widget.data.ingridients![index],
                          );
                        },
                      ),
                    // Tutorials
                    if (widget.data.tutorial != null)
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.data.tutorial!.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return StepTile(
                            data: widget.data.tutorial![index],
                          );
                        },
                      ),
                    // Reviews
                    if (widget.data.reviews != null)
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.data.reviews!.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ReviewTile(data: widget.data.reviews![index]);
                        },
                      )
                  ],
                ),
        ],
      ),
    );
  }
}
