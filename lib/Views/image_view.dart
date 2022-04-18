import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:picsum/Constants/app_colors.dart';
import 'package:picsum/Models/picsum_image.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageView extends StatefulWidget {
  final PicsumImage image;
  const ImageView({Key? key, required this.image}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  final Future<SharedPreferences> _sharePrefrences =
      SharedPreferences.getInstance();
  List<String> favoriteImages = [];
  String _message = '';
  String? path;

  Future<void> _downloadImage(String url,
      {AndroidDestinationType? destination}) async {
    String? fileName;

    try {
      String? imageId;

      if (destination == null) {
        imageId = await ImageDownloader.downloadImage(url);
      } else {
        imageId =
            await ImageDownloader.downloadImage(url, destination: destination);
      }

      if (imageId == null) {
        return;
      }
      fileName = await ImageDownloader.findName(imageId);
      path = await ImageDownloader.findPath(imageId);
    } on PlatformException catch (error) {
      setState(() {
        _message = error.message ?? '';
      });
      var snackBar = SnackBar(
        content: Text(_message),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (!mounted) return;

    setState(() {
      var location = Platform.isAndroid ? "Directory" : "Photos";
      _message = 'Saved as "$fileName" in $location.\n';

      var snackBar = SnackBar(
        content: Text(_message),
        action: SnackBarAction(
          label: 'Share',
          textColor: orangeColor,
          onPressed: shareImage,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return;
    });
  }

  shareImage() async {
    await Share.shareFiles([path!]);
  }

  @override
  void initState() {
    getFavoriteImages();
    super.initState();
  }

  getFavoriteImages() async {
    final prefs = await SharedPreferences.getInstance();

    favoriteImages = prefs.getStringList('favorites') ?? [];
    setState(() {});
  }

  updateFavoritesList() async {
    final SharedPreferences prefs = await _sharePrefrences;
    if (favoriteImages.contains(widget.image.id.toString())) {
      favoriteImages.remove(widget.image.id.toString());
    } else {
      favoriteImages.add(widget.image.id.toString());
    }

    favoriteImages = await prefs
        .setStringList('favorites', favoriteImages)
        .then((bool success) {
      return favoriteImages;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: widget.image.id,
            child: PinchZoom(
              resetDuration: const Duration(milliseconds: 200),
              maxScale: 5,
              child: CachedNetworkImage(
                imageUrl: widget.image.downloadUrl,
                memCacheWidth: widget.image.width > 1000
                    ? widget.image.width ~/ 5
                    : widget.image.width,
                memCacheHeight: widget.image.height > 1000
                    ? widget.image.height ~/ 5
                    : widget.image.height,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Positioned(
            top: 80,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _downloadImage(widget.image.downloadUrl);
                        },
                        child: _message == ''
                            ? const Icon(
                                Icons.download,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.done,
                                color: Colors.white,
                              ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          updateFavoritesList();
                        },
                        child: Icon(
                          favoriteImages.contains(widget.image.id.toString())
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
                          color: favoriteImages
                                  .contains(widget.image.id.toString())
                              ? orangeColor
                              : Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
