import 'dart:io';

bool get isAndroid => Platform.isAndroid;
bool get isIos => Platform.isIOS;
bool get isMobile => isAndroid || isIos;
bool get isDesktop =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;
