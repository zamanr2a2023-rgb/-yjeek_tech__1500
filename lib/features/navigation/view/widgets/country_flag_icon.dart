import 'package:flutter/material.dart';
import 'package:yjeek_app/core/utils/responsive.dart';

class CountryFlagIcon extends StatelessWidget {
  const CountryFlagIcon({super.key, required this.countryName});

  final String countryName;

  static const _borderColor = Color(0xFFE6E6E6);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: _borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: _FlagArtwork(countryName: countryName),
    );
  }
}

class _FlagArtwork extends StatelessWidget {
  const _FlagArtwork({required this.countryName});

  final String countryName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        return SizedBox(
          width: size,
          height: size,
          child: switch (countryName) {
            'Kuwait' => _kuwaitFlag(size),
            'KSA' => _ksaFlag(size),
            'Bahrain' => _bahrainFlag(size),
            'UAE' => _uaeFlag(size),
            'Oman' => _omanFlag(size),
            'Qatar' => _qatarFlag(size),
            'Jordan' => _jordanFlag(size),
            'Egypt' => _egyptFlag(size),
            'Iraq' => _iraqFlag(size),
            _ => const ColoredBox(color: Colors.white),
          },
        );
      },
    );
  }

  Widget _kuwaitFlag(double size) {
    final topH = size * 15.17 / 44;
    final midH = size * 15.17 / 44;
    return Stack(
      children: [
        Positioned(top: 0, left: 0, right: 0, height: topH, child: const ColoredBox(color: Color(0xFF00753D))),
        Positioned(top: size * 14.67 / 44, left: 0, right: 0, height: midH, child: const ColoredBox(color: Colors.white)),
        Positioned(top: size * 29.33 / 44, left: 0, right: 0, bottom: 0, child: const ColoredBox(color: Color(0xFFCF1726))),
        Positioned(left: 0, top: 0, width: size * 18 / 44, bottom: 0, child: const ColoredBox(color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _ksaFlag(double size) {
    return Stack(
      children: [
        const ColoredBox(color: Color(0xFF006B38)),
        Positioned(
          left: size * 10 / 44,
          top: size * 15 / 44,
          width: size * 24 / 44,
          height: size * 3.4 / 44,
          child: const ColoredBox(color: Colors.white),
        ),
        Positioned(
          left: size * 8 / 44,
          top: size * 25 / 44,
          width: size * 28 / 44,
          height: size * 2.6 / 44,
          child: const ColoredBox(color: Colors.white),
        ),
      ],
    );
  }

  Widget _bahrainFlag(double size) {
    return Stack(
      children: [
        const ColoredBox(color: Colors.white),
        Positioned(
          left: 0,
          top: 0,
          width: size * 29 / 44,
          bottom: 0,
          child: const ColoredBox(color: Color(0xFFCF1726)),
        ),
      ],
    );
  }

  Widget _uaeFlag(double size) {
    final bandH = size * 15.17 / 44;
    return Stack(
      children: [
        Positioned(left: size * 11 / 44, top: 0, right: 0, height: bandH, child: const ColoredBox(color: Color(0xFF00753D))),
        Positioned(left: size * 11 / 44, top: size * 14.67 / 44, right: 0, height: bandH, child: const ColoredBox(color: Colors.white)),
        Positioned(left: size * 11 / 44, top: size * 29.33 / 44, right: 0, bottom: 0, child: const ColoredBox(color: Color(0xFF1A1A1A))),
        Positioned(left: 0, top: 0, width: size * 11 / 44, bottom: 0, child: const ColoredBox(color: Color(0xFFCF1726))),
      ],
    );
  }

  Widget _omanFlag(double size) {
    final bandH = size * 15.17 / 44;
    return Stack(
      children: [
        Positioned(left: size * 12 / 44, top: 0, right: 0, height: bandH, child: const ColoredBox(color: Colors.white)),
        Positioned(left: size * 12 / 44, top: size * 14.67 / 44, right: 0, height: bandH, child: const ColoredBox(color: Color(0xFFCF1726))),
        Positioned(left: size * 12 / 44, top: size * 29.33 / 44, right: 0, bottom: 0, child: const ColoredBox(color: Color(0xFF00753D))),
        Positioned(left: 0, top: 0, width: size * 12 / 44, bottom: 0, child: const ColoredBox(color: Color(0xFFCF1726))),
      ],
    );
  }

  Widget _qatarFlag(double size) {
    return Stack(
      children: [
        const ColoredBox(color: Colors.white),
        Positioned(
          left: 0,
          top: 0,
          width: size * 28 / 44,
          bottom: 0,
          child: const ColoredBox(color: Color(0xFF800D33)),
        ),
      ],
    );
  }

  Widget _jordanFlag(double size) {
    final bandH = size * 15.17 / 44;
    return Stack(
      children: [
        Positioned(top: 0, left: 0, right: 0, height: bandH, child: const ColoredBox(color: Color(0xFF1A1A1A))),
        Positioned(top: size * 14.67 / 44, left: 0, right: 0, height: bandH, child: const ColoredBox(color: Colors.white)),
        Positioned(top: size * 29.33 / 44, left: 0, right: 0, bottom: 0, child: const ColoredBox(color: Color(0xFF00753D))),
        Positioned(left: 0, top: 0, width: size * 20 / 44, bottom: 0, child: const ColoredBox(color: Color(0xFFCF1726))),
        Positioned(
          left: size * 6 / 44,
          top: size * 20.5 / 44,
          child: Container(
            width: size * 3.5 / 44,
            height: size * 3.5 / 44,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }

  Widget _egyptFlag(double size) {
    final bandH = size * 15.17 / 44;
    return Stack(
      children: [
        Positioned(top: 0, left: 0, right: 0, height: bandH, child: const ColoredBox(color: Color(0xFFCF1726))),
        Positioned(top: size * 14.67 / 44, left: 0, right: 0, height: bandH, child: const ColoredBox(color: Colors.white)),
        Positioned(top: size * 29.33 / 44, left: 0, right: 0, bottom: 0, child: const ColoredBox(color: Color(0xFF1A1A1A))),
        Positioned(
          left: size * 19.5 / 44,
          top: size * 17.5 / 44,
          child: Container(
            width: size * 5 / 44,
            height: size * 8 / 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD4B038),
              borderRadius: BorderRadius.circular(size * 2.5 / 44),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iraqFlag(double size) {
    final bandH = size * 15.17 / 44;
    return Stack(
      children: [
        Positioned(top: 0, left: 0, right: 0, height: bandH, child: const ColoredBox(color: Color(0xFFCF1726))),
        Positioned(top: size * 14.67 / 44, left: 0, right: 0, height: bandH, child: const ColoredBox(color: Colors.white)),
        Positioned(top: size * 29.33 / 44, left: 0, right: 0, bottom: 0, child: const ColoredBox(color: Color(0xFF1A1A1A))),
        for (final left in [15.0, 20.5, 26.0])
          Positioned(
            left: size * left / 44,
            top: size * 20.5 / 44,
            child: Container(
              width: size * 3 / 44,
              height: size * 3.4 / 44,
              color: const Color(0xFF00753D),
            ),
          ),
      ],
    );
  }
}
