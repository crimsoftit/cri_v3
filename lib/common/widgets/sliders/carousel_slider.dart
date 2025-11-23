import 'package:carousel_slider/carousel_slider.dart';
import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/utils/constants/img_strings.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class CCarouselSlider extends StatelessWidget {
  const CCarouselSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        CRoundedContainer(
          borderRadius: CSizes.md,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CSizes.md),
            child: Image(image: AssetImage(CImages.sliderImg1)),
          ),
        ),
        CRoundedContainer(
          borderRadius: CSizes.md,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CSizes.md),
            child: Image(image: AssetImage(CImages.sliderImg2)),
          ),
        ),
        CRoundedContainer(
          borderRadius: CSizes.md,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CSizes.md),
            child: Image(image: AssetImage(CImages.sliderImg3)),
          ),
        ),
      ],
      options: CarouselOptions(viewportFraction: 1),
    );
  }
}
