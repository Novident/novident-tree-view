import 'package:novident_tree_view/novident_tree_view.dart';

// These multiplier are using by Platform
// since the screen size is minor than the desktop
// screens, so, we need to adjust the draw offset
// to make more easy for mobiles adapt to their parents
// without go out of them easily
const double _desktopIndentMultiplier = 27.5;
const double _androidIndentMultiplier = 24.5;

double get getCorrectMultiplierByPlatform =>
    isMobile ? _androidIndentMultiplier : _desktopIndentMultiplier;
