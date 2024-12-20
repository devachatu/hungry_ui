import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/recipe_helper.dart';
import 'package:hungry/routes/app_pages.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/recipe_tile.dart';

import '../../prompts/defined_prompts.dart';
import '../../services/open_ai_service.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchInputController = TextEditingController();
  final List<Recipe> searchResult = RecipeHelper.sarchResultRecipe;
  final OpenAIService openAIService = OpenAIService();
  Map<String, String> replacements = {"ingredients": ""};
  List<Recipe> sarchResultRecipe = [];
  List<String> suggestions = popularRecipeKeyword;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    suggestions.shuffle();
    if (Get.arguments != null) {
      for (var element in Get.arguments) {
        searchInputController.text =
            searchInputController.text + element + " , ";
      }
      _getSearchItems((Get.arguments as List<String>));
    }
  }

  _getSearchItems(List<String> items) async {
    // Replace placeholders
    setState(() {
      _loading = true;
    });
    replacements["ingredients"] = items.join(",");
    String filledString = DefinedPrompts.SEARCH_FROM_INGREDIENTS;
    replacements.forEach((key, value) {
      filledString = filledString.replaceAll('{$key}', value);
    });
    print(filledString);
    final response = await openAIService.sendMessage(filledString);
    List recipeSearchResultRawData = response as List;
    setState(() {
      suggestions = [];
      sarchResultRecipe = recipeSearchResultRawData.map((data) {
        for (String element in (data["suggestions"] as List)) {
          if (!suggestions.contains(element)) suggestions.add(element);
        }
        return Recipe(
            title: data['title'],
            photo: "",
            calories: data['calories'].toString(),
            time: data['time'].toString(),
            description: data['description']);
      }).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(searchInputController.text.isEmpty);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        title: Text('Search Recipe',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'inter',
                fontWeight: FontWeight.w400,
                fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Get.toNamed(Routes.home_page);
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Search
          Container(
            width: MediaQuery.of(context).size.width,
            height: 145,
            color: AppColor.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Search TextField
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.only(right: 15, left: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.primarySoft),
                          child: TextField(
                            controller: searchInputController,
                            onChanged: (value) {
                              print(searchInputController.text);

                              setState(() {});
                            },
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            maxLines: 1,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'What do you want to eat?',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.2)),
                              prefixIconConstraints:
                                  BoxConstraints(maxHeight: 20),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 17),
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              prefixIcon: Visibility(
                                visible: (searchInputController.text.isEmpty)
                                    ? true
                                    : false,
                                child: Container(
                                  margin: EdgeInsets.only(left: 10, right: 12),
                                  child: SvgPicture.asset(
                                    'assets/icons/search.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Filter Button
                      GestureDetector(
                        onTap: () async {
                          await _getSearchItems(
                              searchInputController.text.split(","));
                          // showModalBottomSheet(
                          //     context: context,
                          //     backgroundColor: Colors.white,
                          //     shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.only(
                          //             topLeft: Radius.circular(20),
                          //             topRight: Radius.circular(20))),
                          //     builder: (context) {
                          //       return SearchFilterModal();
                          //     });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColor.secondary,
                          ),
                          child: Icon(Icons.search),
                        ),
                      )
                    ],
                  ),
                ),
                // Search Keyword Recommendation
                Container(
                  height: 60,
                  margin: EdgeInsets.only(top: 8),
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: suggestions.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(width: 8);
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.topCenter,
                        child: TextButton(
                          onPressed: () {
                            if (searchInputController.text.isEmpty) {
                              searchInputController.text = suggestions[index];
                            } else {
                              searchInputController.text =
                                  searchInputController.text +
                                      ", " +
                                      suggestions[index];
                            }
                          },
                          child: Text(
                            suggestions[index],
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w400),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.15),
                                width: 1),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          // Section 2 - Search Result
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Text(
                    'This is the result of your search..',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                _loading
                    ? CircularProgressIndicator()
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: this.sarchResultRecipe.length,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 16);
                        },
                        itemBuilder: (context, index) {
                          return RecipeTile(
                            data: this.sarchResultRecipe[index],
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
