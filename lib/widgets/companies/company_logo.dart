
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/companies/orgs.dart';

class CompanyLogoWidget extends StatelessWidget {
  final Orgs company;
  static const logoWidth = 60.0;
  static const defaultIcon = Icon(
    Icons.image_outlined,
    size: 45.0,
  );

  CompanyLogoWidget(this.company);

  @override
  Widget build(BuildContext context) {

    if (company.logo == '' || company.logo == null || company.logo!.endsWith('svg')) {
      return SizedBox(
        height: double.infinity,
        width: logoWidth,
        child: CircleAvatar(
          backgroundColor: company.color,
          child: Text('${company.name}'[0]),
        ),
      );
    }

    String? logoPath = company.getLogoPath();

    return logoPath == null ? const Image(
      image: AssetImage(
          'assets/avatars/default_avatar.png'),
      height: double.infinity,
      width: logoWidth,
    ) : CachedNetworkImage(
      height: double.infinity,
      width: logoWidth,
      imageUrl: logoPath,
      placeholder: (context, url) => defaultIcon,
      errorWidget: (context, url, error) => defaultIcon,
    );
  }
}
