import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hungry/routes/app_pages.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:image_picker/image_picker.dart';

class DummySearchBar extends StatefulWidget {
  final void Function() routeTo;
  const DummySearchBar({Key? key, required this.routeTo}) : super(key: key);

  @override
  State<DummySearchBar> createState() => _DummySearchBarState();
}

class _DummySearchBarState extends State<DummySearchBar> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _openCamera() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      _imageFile = pickedImage;
      if (_imageFile != null)
        Get.toNamed(Routes.search_page, arguments: [
          "Pizza dough (center)",
          "Tomatoes",
          "Green chili",
          "Garlic",
          "Bell peppers (yellow and green)",
          "Basil leaves",
          "Olive oil",
          "Salt",
          "Peppercorns",
          "Mushrooms",
          "Cheese (mozzarella balls)",
          "Sausage slices",
          "Red chili",
          "Onion slices (hidden under some items)",
          "Flour"
        ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.routeTo,
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side - Search Box
            Expanded(
              child: Container(
                height: 50,
                margin: EdgeInsets.only(right: 15),
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColor.primarySoft),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/search.svg',
                        color: Colors.white, height: 18, width: 18),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        'What do you want to eat?',
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Right side - filter button
            GestureDetector(
                onTap: () => _openCamera(),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColor.secondary,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.black,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
