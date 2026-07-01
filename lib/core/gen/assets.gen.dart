// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/hadez.png
  AssetGenImage get hadez => const AssetGenImage('assets/icons/hadez.png');

  /// File path: assets/icons/ic_splash.png
  AssetGenImage get icSplash =>
      const AssetGenImage('assets/icons/ic_splash.png');

  /// File path: assets/icons/most_recently_icon.png
  AssetGenImage get mostRecentlyIcon =>
      const AssetGenImage('assets/icons/most_recently_icon.png');

  /// File path: assets/icons/quran.png
  AssetGenImage get quran => const AssetGenImage('assets/icons/quran.png');

  /// File path: assets/icons/radio.png
  AssetGenImage get radio => const AssetGenImage('assets/icons/radio.png');

  /// File path: assets/icons/sebha.png
  AssetGenImage get sebha => const AssetGenImage('assets/icons/sebha.png');

  /// File path: assets/icons/timer.png
  AssetGenImage get timer => const AssetGenImage('assets/icons/timer.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    hadez,
    icSplash,
    mostRecentlyIcon,
    quran,
    radio,
    sebha,
    timer,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/Sebha (1).png
  AssetGenImage get sebha1 =>
      const AssetGenImage('assets/images/Sebha (1).png');

  /// File path: assets/images/SebhaBody 1.png
  AssetGenImage get sebhaBody1 =>
      const AssetGenImage('assets/images/SebhaBody 1.png');

  /// File path: assets/images/Vector.png
  AssetGenImage get vector => const AssetGenImage('assets/images/Vector.png');

  /// File path: assets/images/background.png
  AssetGenImage get background =>
      const AssetGenImage('assets/images/background.png');

  /// File path: assets/images/first_screeen_background.png
  AssetGenImage get firstScreeenBackground =>
      const AssetGenImage('assets/images/first_screeen_background.png');

  /// File path: assets/images/first_screen_logo.png
  AssetGenImage get firstScreenLogo =>
      const AssetGenImage('assets/images/first_screen_logo.png');

  /// File path: assets/images/forth_screen_background.png
  AssetGenImage get forthScreenBackground =>
      const AssetGenImage('assets/images/forth_screen_background.png');

  /// File path: assets/images/handofsebha.png
  AssetGenImage get handofsebha =>
      const AssetGenImage('assets/images/handofsebha.png');

  /// File path: assets/images/hands.png
  AssetGenImage get hands => const AssetGenImage('assets/images/hands.png');

  /// File path: assets/images/islami_logo.png
  AssetGenImage get islamiLogo =>
      const AssetGenImage('assets/images/islami_logo.png');

  /// File path: assets/images/lamb.png
  AssetGenImage get lamb => const AssetGenImage('assets/images/lamb.png');

  /// File path: assets/images/mic.png
  AssetGenImage get mic => const AssetGenImage('assets/images/mic.png');

  /// File path: assets/images/mosque.png
  AssetGenImage get mosque => const AssetGenImage('assets/images/mosque.png');

  /// File path: assets/images/onmosque.png
  AssetGenImage get onmosque =>
      const AssetGenImage('assets/images/onmosque.png');

  /// File path: assets/images/quran-svgrepo-com 1.svg
  SvgGenImage get quranSvgrepoCom1 =>
      const SvgGenImage('assets/images/quran-svgrepo-com 1.svg');

  /// File path: assets/images/quruan.png
  AssetGenImage get quruan => const AssetGenImage('assets/images/quruan.png');

  /// File path: assets/images/radio_background.png
  AssetGenImage get radioBackground =>
      const AssetGenImage('assets/images/radio_background.png');

  /// File path: assets/images/sebha (3).png
  AssetGenImage get sebha3 =>
      const AssetGenImage('assets/images/sebha (3).png');

  /// File path: assets/images/sebha (4).png
  AssetGenImage get sebha4 =>
      const AssetGenImage('assets/images/sebha (4).png');

  /// File path: assets/images/secound_screen_background.png
  AssetGenImage get secoundScreenBackground =>
      const AssetGenImage('assets/images/secound_screen_background.png');

  /// File path: assets/images/starslest.png
  AssetGenImage get starslest =>
      const AssetGenImage('assets/images/starslest.png');

  /// File path: assets/images/starsright.png
  AssetGenImage get starsright =>
      const AssetGenImage('assets/images/starsright.png');

  /// File path: assets/images/third_screen_background.png
  AssetGenImage get thirdScreenBackground =>
      const AssetGenImage('assets/images/third_screen_background.png');

  /// File path: assets/images/welcome.png
  AssetGenImage get welcome => const AssetGenImage('assets/images/welcome.png');

  /// List of all assets
  List<dynamic> get values => [
    sebha1,
    sebhaBody1,
    vector,
    background,
    firstScreeenBackground,
    firstScreenLogo,
    forthScreenBackground,
    handofsebha,
    hands,
    islamiLogo,
    lamb,
    mic,
    mosque,
    onmosque,
    quranSvgrepoCom1,
    quruan,
    radioBackground,
    sebha3,
    sebha4,
    secoundScreenBackground,
    starslest,
    starsright,
    thirdScreenBackground,
    welcome,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
