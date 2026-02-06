import 'dart:io';

bool get isMobile => Platform.isAndroid || Platform.isIOS;
bool get isDesktop => Platform.isLinux || Platform.isWindows || Platform.isMacOS;
