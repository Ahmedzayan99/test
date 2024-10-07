import 'package:project1/app/routes.dart';
import 'package:project1/cubit/favourite/updateFavouriteRestaurant.dart';
import 'package:project1/data/model/searchModel.dart';
import 'package:project1/ui/styles/color.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/utils/apiBodyParameterLabels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SearchContainer extends StatelessWidget {
  final SearchModel restaurant;
  final double? width, height;
  final String? searchText;
  const SearchContainer({Key? key, required this.restaurant, this.width, this.height, this.searchText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> highlightOccurrences(String source, String query) {
      if (query.isEmpty) {
        return [TextSpan(text: source,
            style: TextStyle(color: greayLightColor, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Quicksand'),
          )];
      }

      var matches = <Match>[];
      for (final token in query.trim().toLowerCase().split(' ')) {
        matches.addAll(token.allMatches(source.toLowerCase()));
      }

      if (matches.isEmpty) {
        return [TextSpan(text: source,
            style: TextStyle(color: greayLightColor, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Quicksand'),
          )];
      }
      matches.sort((a, b) => a.start.compareTo(b.start));

      int lastMatchEnd = 0;
      final List<TextSpan> children = [];
      for (final match in matches) {
        if (match.end <= lastMatchEnd) {
          // already matched -> ignore
        } else if (match.start <= lastMatchEnd) {
          children.add(TextSpan(
            text: source.substring(lastMatchEnd, match.end),
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Quicksand'),
          ));
        } else if (match.start > lastMatchEnd) {
          children.add(TextSpan(
            text: source.substring(lastMatchEnd, match.start),style: TextStyle(color: greayLightColor, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Quicksand'),
          ));

          children.add(TextSpan(
            text: source.substring(match.start, match.end),
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Quicksand'),
          ));
        }

        if (lastMatchEnd < match.end) {
          lastMatchEnd = match.end;
        }
      }

      if (lastMatchEnd < source.length) {
        children.add(TextSpan(
          text: source.substring(lastMatchEnd, source.length),style: TextStyle(color: greayLightColor, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Quicksand'),
        ));
      }

      return children;
    }
    return BlocProvider<UpdateRestaurantFavoriteStatusCubit>(
      create: (context) => UpdateRestaurantFavoriteStatusCubit(),
      child: Builder(builder: (context) {
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(Routes.restaurantDetail, arguments: {'restaurant': restaurant.partnerDetails![0]});
          },
          child: Container(
              padding: EdgeInsetsDirectional.only(top: height! / 99.0, end: width! / 40.0),
              width: width!,
              margin: EdgeInsetsDirectional.only(top: height! / 52.0, start: width! / 24.0, end: width! / 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: ColorFiltered(
                        colorFilter: restaurant.partnerDetails![0].isRestroOpen == "1"
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              )
                            : const ColorFilter.mode(
                                Colors.grey,
                                BlendMode.saturation,
                              ),
                        child: DesignConfig.imageWidgets(restaurant.type==searchPartnerKey?restaurant.partnerDetails![0].partnerProfile!:restaurant.productImage, height!/17.0, width!/8.0, "2"),
                      )),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: width! / 30.0,
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        /* Text(restaurant.partnerName!,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis) */
                        RichText(maxLines: 2,
                          text: TextSpan(
                            children: highlightOccurrences(restaurant.type==searchPartnerKey?restaurant.partnerDetails![0].partnerName!:restaurant.productName!, searchText!),
                            style: TextStyle(color: greayLightColor, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Quicksand'),
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(restaurant.type==searchPartnerKey?'Restaurant':'Dish',
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: greayLightColor, fontSize: 14, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
                                maxLines: 1)
                      ]),
                    ),
                  ),
                ],
              )),
        );
      }),
    );
  }
}
