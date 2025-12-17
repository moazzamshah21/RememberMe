import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:rememberme/app/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final Widget appBarContent;
  final Color backgroundColor;
  
  const CustomAppBar({
    super.key,
    required this.appBarContent,
    this.backgroundColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _CustomAppBarDelegate(
        appBarContent: appBarContent,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _CustomAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget appBarContent;
  final Color backgroundColor;

  _CustomAppBarDelegate({
    required this.appBarContent,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isCollapsed = shrinkOffset > maxExtent - minExtent;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double topPadding = mediaQuery.padding.top;
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlackMedium,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(
            top: topPadding + (isCollapsed ? 10 : 10),
            left: 40,
            right: 40,
            bottom: isCollapsed ? 30 : (isIOS ? 5 : 30),
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isCollapsed
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remember Me',
                          style: TextStyle(
                            color: AppColors.primaryTealAlt,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'PolySans',
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      height: isIOS 
                          ? maxExtent - topPadding - 10 - 5
                          : maxExtent - topPadding - 10 - 30,
                      child: ClipRect(
                        child: appBarContent,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent {
    // Increase height on iOS to accommodate safe area and prevent overflow
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 171.0; // 150 + 21 pixels to fix overflow
    }
    return 150.0;
  }

  @override
  double get minExtent {
    // Increase height on iOS to accommodate safe area and prevent overflow
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 171.0; // 150 + 21 pixels to fix overflow
    }
    return 150.0;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}