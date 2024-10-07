import 'package:carousel_slider/carousel_slider.dart';
import 'package:project1/app/routes.dart';
import 'package:project1/ui/styles/design.dart';
import 'package:project1/ui/widgets/simmer/sliderSimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubit/home/slider/sliderOfferCubit.dart';

class SliderScreen extends StatefulWidget {
  const SliderScreen({Key? key}) : super(key:key);

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  int _currentPage = 0;
  double? width, height;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return BlocConsumer<SliderCubit, SliderState>(
        bloc: context.read<SliderCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SliderProgress || state is SliderInitial) {
            return SliderSimmer(width: width!, height: height!);
          }
          if (state is SliderFailure) {
            return const SizedBox() /* Center(
                child: Text(
              state.errorCode.toString(),
              textAlign: TextAlign.center,
            )) */
                ;
          }
          final sliderList = (state as SliderSuccess).sliderList;
          return sliderList.isEmpty
              ? const SizedBox()
              : Column(
                  children: [
                    CarouselSlider(
                        items: sliderList
                            .map((item) => GestureDetector(
                                  onTap: () {
                                    if (item.type == "default") {
                                    } else if (item.type == "categories") {
                                      Navigator.of(context)
                                          .pushNamed(Routes.cuisineDetail, arguments: {'categoryId': item.data![0].id!, 'name': item.data![0].text!});
                                    } else if (item.type == "products") {
                                      /*  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => RestaurantDetailScreen(
                                      restaurant: item.data![0].partnerDetails![0],
                                    ),
                                  ),
                                );*/
                                      Navigator.of(context)
                                          .pushNamed(Routes.restaurantDetail, arguments: {'restaurant': item.data![0].partnerDetails![0]});
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsetsDirectional.only(start: width!/20.0, end: width!/20.0, top: 10.0),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                      child: DesignConfig.imageWidgets(item.image!, height! / 5.0, width!, "2"),
                                    ),
                                  ),
                                ))
                            .toList(),
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          reverse: false,viewportFraction: 1,
                          autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                          aspectRatio: 2.2,
                          initialPage: 0,
                          onPageChanged: (index, reason) {
                            
                          setState(() {
                            _currentPage = index;
                          });
                   
                          },
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sliderList
                          .map((item) => Container(
                                width: _currentPage == sliderList.indexOf(item) ? 15.0 : 6.0,
                                height: 6.0,
                                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                    color: _currentPage == sliderList.indexOf(item) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary),
                              ))
                          .toList(),
                    ),
                  ],
                );
        });
  }
}