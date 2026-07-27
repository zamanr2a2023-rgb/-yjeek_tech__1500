import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_flow_data.dart';
import 'package:yjeek_app/features/order_flow/view/widgets/order_flow_widgets.dart';

class DriverChatScreen extends ConsumerStatefulWidget {
  const DriverChatScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<DriverChatScreen> createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends ConsumerState<DriverChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollTimer;
  bool _loading = true;
  bool _sending = false;
  String _headerName = OrderFlowData.driverName;
  String _orderBadge = 'Order';
  List<DriverChatMessage> _messages = const [];
  List<String> _quickReplies = OrderFlowData.chatQuickReplies;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      setState(() {
        _messages = OrderFlowData.driverMessages;
        _loading = false;
      });
      return;
    }
    final repo = ref.read(orderChatRepositoryProvider);
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    final chat = await repo.openOrderChat(orderId);
    final replies = await repo.quickReplies();
    if (!mounted) return;
    final champ = order?['champ'] ?? order?['driver'];
    final champName = champ is Map
        ? champ['name']?.toString()
        : null;
    final orderNumber = order?['orderNumber']?.toString();
    final vendor = order?['vendor'];
    final vendorName =
        vendor is Map ? vendor['name']?.toString() : OrderFlowData.vendor;
    setState(() {
      _headerName = (champName == null || champName.isEmpty)
          ? OrderFlowData.driverName
          : champName;
      _orderBadge =
          '🛍 Order ${orderNumber == null || orderNumber.isEmpty ? '' : '#$orderNumber'} · $vendorName';
      _messages = chat.messages
          .map(
            (m) => DriverChatMessage(text: m.body, isUser: m.isMine),
          )
          .toList();
      if (replies.isNotEmpty) _quickReplies = replies;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty || !mounted) return;
    final chat =
        await ref.read(orderChatRepositoryProvider).openOrderChat(orderId);
    if (!mounted) return;
    setState(() {
      _messages = chat.messages
          .map((m) => DriverChatMessage(text: m.body, isUser: m.isMine))
          .toList();
    });
  }

  Future<void> _send([String? preset]) async {
    if (_sending) return;
    final orderId = widget.orderId;
    final body = (preset ?? _controller.text).trim();
    if (body.isEmpty) return;
    if (orderId == null || orderId.isEmpty) {
      setState(() {
        _messages = [
          ..._messages,
          DriverChatMessage(text: body, isUser: true),
        ];
        _controller.clear();
      });
      return;
    }
    setState(() => _sending = true);
    final sent =
        await ref.read(orderChatRepositoryProvider).sendMessage(orderId, body);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (sent != null) {
        _messages = [
          ..._messages,
          DriverChatMessage(text: sent.body, isUser: sent.isMine),
        ];
        _controller.clear();
      }
    });
    if (sent == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _DriverChatHeader(name: _headerName),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                    children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9E0D9),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'Today',
                            style: AppTextStyles.labelSmall(
                              color: AppColors.textSecondary,
                            ).copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2EB),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            _orderBadge,
                            style: AppTextStyles.labelSmall(
                              color: const Color(0xFF127036),
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      for (final message in _messages)
                        DriverChatBubble(message: message),
                      SizedBox(height: 8.h),
                      DriverChatQuickReplies(
                        replies: _quickReplies,
                        onSelected: _send,
                      ),
                    ],
                  ),
          ),
          DriverChatInputBar(
            controller: _controller,
            enabled: !_sending,
            onSend: _send,
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 1),
    );
  }
}

class _DriverChatHeader extends StatelessWidget {
  const _DriverChatHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            NavCircleBackButton(
              onTap: () => Navigator.of(context).maybePop(),
              iconColor: AppColors.textPrimary,
            ),
            SizedBox(width: 10.w),
            Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2EB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.person_outline,
                color: AppColors.cartTabActive,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    OrderFlowStrings.onlineChamp,
                    style: AppTextStyles.labelSmall(
                      color: AppColors.cartTabActive,
                    ).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2EB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.phone_outlined,
                color: const Color(0xFF127036),
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
