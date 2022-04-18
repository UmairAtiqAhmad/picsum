import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:picsum/Constants/app_colors.dart';
import 'package:picsum/Models/picsum_image.dart';
import 'package:picsum/Services/picsum_api.dart';
import 'package:picsum/Views/image_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<String> favoriteImages = [];
  List<PicsumImage> images = [];
  ScrollController gridviewScrollController = ScrollController();
  int imagesPageCount = 1;
  int crossAxisItemCount = 3;

  @override
  void initState() {
    getFavoriteImages();
    gridviewScrollController.addListener(() {
      if (gridviewScrollController.position.pixels ==
          gridviewScrollController.position.maxScrollExtent) {
        getMoreImages();
      }
    });
    super.initState();
  }

  getFavoriteImages() async {
    final prefs = await SharedPreferences.getInstance();

    favoriteImages = prefs.getStringList('favorites') ?? [];
    setState(() {});
  }

  getMoreImages() async {
    imagesPageCount++;

    var response = await LoremPicsum().getImageList(page: imagesPageCount);
    List json = jsonDecode(response);
    for (var image in json) {
      var photo = PicsumImage.fromJson(image);
      images.add(photo);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    getFavoriteImages();

    return Scaffold(
      backgroundColor: backGroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: zoomButtons(),
      body: Column(children: [
        FutureBuilder(
            future: LoremPicsum().getImageList(page: imagesPageCount),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                if (images.isEmpty) {
                  List json = jsonDecode(snapshot.data);
                  for (var image in json) {
                    var photo = PicsumImage.fromJson(image);
                    images.add(photo);
                  }
                }

                return Expanded(
                  child: GridView.builder(
                    controller: gridviewScrollController,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: size.width / crossAxisItemCount,
                      childAspectRatio: 1,
                    ),
                    addAutomaticKeepAlives: true,
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) =>
                        singleImage(size, images[index]),
                  ),
                );
              } else {
                return loadingImage(size);
              }
            })
      ]),
    );
  }

  Widget zoomButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(6),
      ),
      height: 80,
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (crossAxisItemCount < 4) {
                setState(() {
                  crossAxisItemCount++;
                });
              }
            },
            child: const Icon(
              Icons.zoom_out,
              color: Colors.black87,
              size: 28,
            ),
          ),
          const Divider(
            color: Colors.black,
          ),
          GestureDetector(
            onTap: () {
              if (crossAxisItemCount > 1) {
                setState(() {
                  crossAxisItemCount--;
                });
              }
            },
            child: const Icon(
              Icons.zoom_in,
              color: Colors.black87,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingImage(Size size) {
    return Container(
        width: size.width,
        height: size.height,
        color: backGroundAccentColor,
        child: const Center(
          child: CircularProgressIndicator(color: backGroundColor),
        ));
  }

  Widget singleImage(Size size, PicsumImage image) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ImageView(image: image)));
      },
      child: Hero(
        tag: image.id,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: size.width / crossAxisItemCount - 1,
                  height: size.width / crossAxisItemCount - 1,
                  color: backGroundAccentColor,
                  child: CachedNetworkImage(
                    memCacheWidth: image.width > 1000
                        ? image.width ~/ 10
                        : image.width > 300
                            ? image.width ~/ 2
                            : image.width,
                    memCacheHeight: image.height > 1000
                        ? image.height ~/ 10
                        : image.height > 300
                            ? image.height ~/ 2
                            : image.height,
                    imageUrl: image.downloadUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 5,
              top: 5,
              child: favoriteImages.contains(image.id.toString())
                  ? const Icon(
                      Icons.favorite,
                      color: orangeColor,
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}
