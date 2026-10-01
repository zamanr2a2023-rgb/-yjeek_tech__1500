import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/spin/model/spin_models.dart';
import 'package:yjeek_app/features/spin/model/spin_repository.dart';

class SpinWheelScreen extends ConsumerStatefulWidget {
  const SpinWheelScreen({super.key, this.campaignId});

  final String? campaignId;

  @override
  ConsumerState<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends ConsumerState<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  SpinActiveResponse? _active;
  bool _loading = true;
  bool _spinning = false;
  String? _error;
  late AnimationController _controller;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final active = await ref.read(spinRepositoryProvider).fetchActive();
      if (!mounted) return;
      setState(() {
        _active = active;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load spin wheel';
      });
    }
  }

  Future<void> _spin() async {
    final campaign = _active?.campaign;
    final id = widget.campaignId ?? _active?.campaignId ?? campaign?.id;
    if (id == null || id.isEmpty || _spinning) return;
    if ((_active?.spinsRemaining ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No spins left')),
      );
      return;
    }
    setState(() => _spinning = true);
    try {
      final result = await ref.read(spinRepositoryProvider).draw(campaignId: id);
      final segments = campaign?.segments ?? const <SpinSegment>[];
      final index = segments.indexWhere((s) => s.id == result.segment.id);
      final targetIndex = index >= 0 ? index : 0;
      final slice = segments.isEmpty ? 1.0 : (2 * math.pi / segments.length);
      final targetRotation = _rotation +
          (6 * 2 * math.pi) +
          (segments.length - targetIndex) * slice -
          slice / 2;

      _controller.reset();
      final animation = Tween<double>(begin: _rotation, end: targetRotation)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      animation.addListener(() {
        setState(() => _rotation = animation.value);
      });
      await _controller.forward(from: 0);
      if (!mounted) return;
      _rotation = targetRotation % (2 * math.pi);
      setState(() {
        _spinning = false;
        _active = SpinActiveResponse(
          campaignId: _active?.campaignId,
          spinsRemaining: result.spinsRemaining,
          live: _active?.live ?? true,
          campaign: campaign,
        );
      });
      ref.invalidate(rewardsSummaryProvider);
      final message = result.isTryAgain
          ? 'Try again!'
          : 'You won: ${result.segment.label}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on SpinException catch (e) {
      if (!mounted) return;
      setState(() => _spinning = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _spinning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spin failed')),
      );
    }
  }

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return fallback;
    return Color(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final campaign = _active?.campaign;
    final bg = _parseColor(campaign?.screenBgValue, const Color(0xFF030712));

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          NavBackHeader(
            title: 'Spin & Win',
            backIconColor: Colors.white,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      )
                    : campaign == null || campaign.segments.isEmpty
                        ? const Center(
                            child: Text(
                              'No live spin campaign',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(height: 12.h),
                              Text(
                                campaign.headerText,
                                style: AppTextStyles.titleMedium(color: Colors.white)
                                    .copyWith(fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                              if (campaign.subHeaderText.isNotEmpty) ...[
                                SizedBox(height: 6.h),
                                Text(
                                  campaign.subHeaderText,
                                  style: AppTextStyles.bodySmall(
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              SizedBox(height: 8.h),
                              Text(
                                'Spins left: ${_active?.spinsRemaining ?? 0}',
                                style: AppTextStyles.labelMedium(color: Colors.white),
                              ),
                              Expanded(
                                child: Center(
                                  child: Transform.rotate(
                                    angle: _rotation,
                                    child: CustomPaint(
                                      size: Size(280.w, 280.w),
                                      painter: _WheelPainter(
                                        segments: campaign.segments,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48.h,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _parseColor(
                                        campaign.spinButtonColor,
                                        AppColors.primary,
                                      ),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _spinning ? null : _spin,
                                    child: Text(
                                      campaign.spinButtonText ?? 'SPIN',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.segments});

  final List<SpinSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final slice = 2 * math.pi / segments.length;
    for (var i = 0; i < segments.length; i++) {
      final paint = Paint()
        ..color = _color(segments[i].segmentColor)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2 + i * slice,
        slice,
        true,
        paint,
      );
    }
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()..color = Colors.white,
    );
  }

  Color _color(String hex) {
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.tryParse(value, radix: 16) ?? 0xFF3B82F6);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.segments != segments;
}
