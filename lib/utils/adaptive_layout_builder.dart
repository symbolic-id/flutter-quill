import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ScreenAdaptor {
  static void onScreen(BuildContext context,
      {required Function onMobile, required Function onDesktop}) {
    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final width = MediaQuery.of(context).size.width;

    if (isMobile || width <= _AdaptiveBreakpoint.mobile) {
      onMobile();
    } else {
      onDesktop();
    }
  }
}

class AdaptiveLayoutBuilder extends StatefulWidget {
  AdaptiveLayoutBuilder({required this.onMobile, required this.onDesktop});

  final Widget onMobile;
  final Widget onDesktop;

  @override
  _AdaptiveLayoutBuilderState createState() => _AdaptiveLayoutBuilderState();
}

class _AdaptiveLayoutBuilderState extends State<AdaptiveLayoutBuilder> {
  @override
  Widget build(BuildContext context) {
    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    return LayoutBuilder(builder: (context, constraints) {
      final orientation = MediaQuery.of(context).orientation;
      late ScreenOn screenOn;

      if (isMobile) {
        screenOn = ScreenOn.MOBILE;
      } else
      /*if (orientation == Orientation.portrait)*/ {
        screenOn = constraints.maxWidth > _AdaptiveBreakpoint.mobile
            ? ScreenOn.DESKTOP
            : ScreenOn.MOBILE;
      }

      switch (screenOn) {
        case ScreenOn.MOBILE:
          return widget.onMobile;
        case ScreenOn.DESKTOP:
          return widget.onDesktop;
      }
    });
  }
}

class _AdaptiveBreakpoint {
  _AdaptiveBreakpoint._();

  // Width on portrait
  static const mobile = 576;

// X-Small	None	<576px
// Small	sm	≥576px
// Medium	md	≥768px
// Large	lg	≥992px
// Extra large	xl	≥1200px
// Extra extra large	xxl	≥1400px
}

enum ScreenOn { MOBILE, DESKTOP }
