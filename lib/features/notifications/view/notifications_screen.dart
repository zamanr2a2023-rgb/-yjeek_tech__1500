import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/notifications/model/customer_notification.dart';
import 'package:yjeek_app/routes/route_names.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  static const Color _pageBg = Color(0xFFF5F7F5);
  static const Color _unreadBg = Color(0xFFF2F7FC);
  static const Color _cardBorder = Color(0xFFE6E8E6);
  static const Color _titleColor = Color(0xFF1A1F1A);
  static const Color _bodyColor = Color(0xFF737873);
  static const Color _sectionColor = Color(0xFF8C918C);
  static const Color _unreadDot = Color(0xFF3682ED);

  bool _loading = true;
  bool _markingAll = false;
  String? _error;
  NotificationsInbox _inbox = const NotificationsInbox(
    today: [],
    earlier: [],
    unreadCount: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = _inbox.isEmpty;
      _error = null;
    });
    try {
      final inbox =
          await ref.read(notificationsRepositoryProvider).fetchInbox();
      if (!mounted) return;
      setState(() {
        _inbox = inbox;
        _loading = false;
      });
      ref.invalidate(notificationsUnreadCountProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = NavigationStrings.notificationsLoadError;
      });
    }
  }

  Future<void> _markAll() async {
    if (_markingAll || !_inbox.hasUnread) return;
    setState(() => _markingAll = true);
    final ok = await ref.read(notificationsRepositoryProvider).markAllRead();
    if (!mounted) return;
    setState(() {
      _markingAll = false;
      if (ok) _inbox = _inbox.markAllRead();
    });
    if (ok) {
      ref.invalidate(notificationsUnreadCountProvider);
    } else {
      _snack(NavigationStrings.notificationsMarkAllError);
    }
  }

  Future<void> _onTap(CustomerNotification item) async {
    if (!item.isRead) {
      final ok =
          await ref.read(notificationsRepositoryProvider).markRead(item.id);
      if (!mounted) return;
      if (ok) {
        setState(() => _inbox = _inbox.markRead(item.id));
        ref.invalidate(notificationsUnreadCountProvider);
      }
    }
    if (!mounted) return;
    if (item.hasOrder) {
      context.push('${RouteNames.orderDetails}?id=${item.orderId}');
      return;
    }
    if (item.type.toUpperCase() == 'PROMO') {
      context.push(RouteNames.exclusiveOffers);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          _Header(
            showMarkAll: _inbox.hasUnread,
            isMarkingAll: _markingAll,
            onMarkAll: _markAll,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _inbox.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ],
      );
    }

    if (_error != null && _inbox.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 24.h),
        children: [
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(color: _bodyColor)
                .copyWith(fontSize: 13.sp),
          ),
          SizedBox(height: 16.h),
          Center(
            child: TextButton(
              onPressed: _load,
              child: Text(NavigationStrings.retry),
            ),
          ),
        ],
      );
    }

    if (_inbox.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 24.h),
        children: [
          Text(
            NavigationStrings.notificationsEmpty,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(color: _bodyColor)
                .copyWith(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        if (_inbox.today.isNotEmpty) ...[
          _SectionLabel(NavigationStrings.notificationsToday),
          SizedBox(height: 10.h),
          ..._cards(_inbox.today),
          if (_inbox.earlier.isNotEmpty) SizedBox(height: 18.h),
        ],
        if (_inbox.earlier.isNotEmpty) ...[
          _SectionLabel(NavigationStrings.notificationsEarlier),
          SizedBox(height: 10.h),
          ..._cards(_inbox.earlier),
        ],
      ],
    );
  }

  List<Widget> _cards(List<CustomerNotification> items) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) widgets.add(SizedBox(height: 10.h));
      widgets.add(
        _NotificationCard(
          item: items[i],
          onTap: () => _onTap(items[i]),
        ),
      );
    }
    return widgets;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.showMarkAll,
    required this.isMarkingAll,
    required this.onMarkAll,
  });

  final bool showMarkAll;
  final bool isMarkingAll;
  final VoidCallback onMarkAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 30.w,
                      height: 30.w,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 22.sp,
                        color: _NotificationsScreenState._titleColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 72.w),
                  child: Text(
                    NavigationStrings.notifications,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall(
                      color: _NotificationsScreenState._titleColor,
                    ).copyWith(fontSize: 19.sp, height: 1),
                  ),
                ),
                if (showMarkAll)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isMarkingAll ? null : onMarkAll,
                      style: TextButton.styleFrom(
                        foregroundColor: _NotificationsScreenState._unreadDot,
                        disabledForegroundColor:
                            _NotificationsScreenState._sectionColor,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: isMarkingAll
                          ? SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _NotificationsScreenState._unreadDot,
                              ),
                            )
                          : Text(
                              NavigationStrings.markAllNotifications,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelSmall(
        color: _NotificationsScreenState._sectionColor,
      ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600, height: 1.25),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final CustomerNotification item;
  final VoidCallback onTap;

  _NotifVisual get _visual => _visualFor(item.type);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: item.isRead
                ? AppColors.white
                : _NotificationsScreenState._unreadBg,
            border: Border.all(
              color: _NotificationsScreenState._cardBorder,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Container(
                  width: 38.w,
                  height: 18.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _visual.bg,
                    borderRadius: BorderRadius.circular(19.r),
                  ),
                  child: Text(
                    _visual.emoji,
                    style: TextStyle(fontSize: 13.sp, height: 1),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium(
                        color: _NotificationsScreenState._titleColor,
                      ).copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.23,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      item.body,
                      style: AppTextStyles.bodySmall(
                        color: _NotificationsScreenState._bodyColor,
                      ).copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              SizedBox(
                width: 52.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.displayTime,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _NotificationsScreenState._sectionColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    if (!item.isRead) ...[
                      SizedBox(height: 6.h),
                      Container(
                        width: 9.w,
                        height: 9.w,
                        decoration: const BoxDecoration(
                          color: _NotificationsScreenState._unreadDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifVisual {
  const _NotifVisual({required this.emoji, required this.bg});

  final String emoji;
  final Color bg;
}

_NotifVisual _visualFor(String type) {
  switch (type.toUpperCase()) {
    case 'ACCOUNT':
      return const _NotifVisual(emoji: '⛔', bg: Color(0xFFFCE8E8));
    case 'PAYMENT':
      return const _NotifVisual(emoji: '💳', bg: Color(0xFFFFF2CF));
    case 'PROMO':
      return const _NotifVisual(emoji: '🎁', bg: Color(0xFFFFF1D8));
    case 'ORDER_UPDATE':
      return const _NotifVisual(emoji: '📦', bg: Color(0xFFEAFBF0));
    default:
      return const _NotifVisual(emoji: '🔔', bg: Color(0xFFEAFBF0));
  }
}
