import 'dart:io';

import 'package:project1/data/model/rattingModel.dart';
import 'package:project1/ui/screen/rating/product_rating_screen.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/ui/styles/dotted_border.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RatingConatiner extends StatefulWidget {
  final int index;
  final double? width, height;
  final String? productId;
  const RatingConatiner(
      {Key? key, required this.index, this.width, this.height, this.productId})
      : super(key: key);

  @override
  RatingConatinerState createState() => RatingConatinerState();
}

class RatingConatinerState extends State<RatingConatiner> {
  final TextEditingController commentController = TextEditingController();
  bool isDataAvailable = false;
  int? selectedIndex = 4;
  List<File> reviewPhotos = [];
  List<RatingModel> ratingList = [];
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(microseconds: 1000),(){
      ratingData();});
 
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      commentController.text = commentList.isEmpty?"":commentList[widget.index]['comment'] ??
          '';
    });
  }

  ratingData() {
    ratingList = [
      RatingModel(
          id: 1,
          title: UiUtils.getTranslatedLabel(context, veryPoorLabel),
          image: "very_poor",
          rating: "1.0",
          status: "0"),
      RatingModel(
          id: 2,
          title: UiUtils.getTranslatedLabel(context, poorLabel),
          image: "poor",
          rating: "2.0",
          status: "0"),
      RatingModel(
          id: 3,
          title: UiUtils.getTranslatedLabel(context, averageLabel),
          image: "average",
          rating: "3.0",
          status: "0"),
      RatingModel(
          id: 4,
          title: UiUtils.getTranslatedLabel(context, goodLabel),
          image: "good",
          rating: "4.0",
          status: "0"),
      RatingModel(
          id: 5,
          title: UiUtils.getTranslatedLabel(context, excellentLabel),
          image: "excellent",
          rating: "5.0",
          status: "1"),
    ];
    setState((){});
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

    Widget getImageField() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        padding: const EdgeInsetsDirectional.only(top: 5), margin: EdgeInsetsDirectional.only(top: widget.height!/60.0),
        height: widget.height!/10.0,
        child: Row(
          children: [
            InkWell(onTap: (){
                    _reviewImgFromGallery(setModalState);
                  },child: Align(alignment: Alignment.topLeft, child: SizedBox(width: reviewPhotos.isEmpty?widget.width!/1.16:widget.width!/4.0, height: widget.height!/10.0,
                    child: DottedBorder(
                      dashPattern: const [8, 4],
                      strokeWidth: 1,
                      strokeCap: StrokeCap.round,
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10.0),
                      child: Center(
                        child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,mainAxisSize: MainAxisSize.min,
                                  children: [
                                    
                                          Icon(Icons.camera_alt_outlined, color: Theme.of(context).colorScheme.onSecondary),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          top: 2.9),
                                      child: Text(
                                          UiUtils.getTranslatedLabel(context, addPhotosLabel),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: greayLightColor,
                                            fontSize: 12,
                                          )),
                                    )
                        ]),
                      )
                    ),
                  ))),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: reviewPhotos.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return InkWell(
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: widget.width!/40.0),
                        child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: Image.file(
                            reviewPhotos[i],
                            width: 100,
                            height: 100,fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(decoration: BoxDecoration(shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.onSecondary),
                          padding: const EdgeInsetsDirectional.all(5.0),
                          child: Icon(
                            Icons.delete,
                            size: 15,
                            color: Theme.of(context).colorScheme.onSurface
                          ))
                    ],
                  ),
                  onTap: () {
                    if (mounted) {
                      setModalState(() {
                        reviewPhotos.removeAt(i);
                      });
                    }
                  },
                );
              },
            )),
          ],
        ),
      );
    });
  }

    void _reviewImgFromGallery(StateSetter setModalState) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null) {
      reviewPhotos = result.paths.map((path) => File(path!)).toList();
      if (mounted) setModalState(() {});
      commentList[widget.index]['images'] = reviewPhotos;
    } else {
      // User canceled the picker
    }
  }

  Widget rating(){
    return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
          ratingList.length, (m) {
          return Padding(
          padding: const EdgeInsetsDirectional.only(start: 10.0),
          child: InkWell(
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              if (selectedIndex == m) {
                setState(() {
                  ratingList[m].status = "0";
                    selectedIndex = 4;
                });} else {
                setState(() {
                  ratingList[m].status = "1";
                  selectedIndex = m;
                });
                commentList[widget.index]['rating'] = ratingList[m].rating;
              }
              },
              child: /* Image.asset(DesignConfig.setPngPath(ratingList[m].image!), height: selectedIndex == m?60.0:40) */
                    SvgPicture.asset(DesignConfig.setSvgPath(ratingList[m].image!), height: selectedIndex == m ? 60.0 : 40)),
            );
        }));
  }

  Widget comment(){
    return Container(
          padding: EdgeInsetsDirectional.only(start: widget.width! / 40.0, end: widget.width! / 99.0),
          decoration: DesignConfig.boxDecorationContainerBorder(commentBoxBorderColor, textFieldBackground, 10.0),
          margin: EdgeInsetsDirectional.only(top: widget.height! / 40.0),
          child: TextField(
            controller: commentController,
            cursorColor: Theme.of(context).colorScheme.onSecondary,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: UiUtils.getTranslatedLabel(context, doYouHaveAnyCommentsLabel),
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: (v) =>  commentList[widget.index]['comment'] = v,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 5,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        rating(),
        const SizedBox(height: 30.1),
        ratingList.isEmpty?const SizedBox.shrink():Text(ratingList[selectedIndex!].title.toString(), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w600)),
        comment(),
        getImageField(),
      ],
    );
  }
}