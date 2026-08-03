import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/phone_call.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';
import 'package:yjeek_app/features/order_flow/model/order_api_mappers.dart';
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
  String _headerName = 'Champ';
  String _orderBadge = 'Order';
  String? _champPhone;
  String? _error;
  List<DriverChatMessage> _messages = const [];
  List<String> _quickReplies = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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
        _messages = const [];
        _error = 'Order not found';
        _loading = false;
      });
      return;
    }
    final repo = ref.read(orderChatRepositoryProvider);
    final order = await ref.read(ordersRepositoryProvider).getOrder(orderId);
    final chat = await repo.openOrderChat(orderId);
    final replies = await repo.quickReplies();
    if (!mounted) return;

    final champ = order?['champ'];
    final driver = order?['driver'];
    final person = champ is Map
        ? Map<String, dynamic>.from(champ)
        : driver is Map
            ? Map<String, dynamic>.from(driver)
            : null;
    final champName = driverDisplayName(person);
    final phone = person?['phone']?.toString() ??
        order?['champPhone']?.toString();
    final orderNumber = order?['orderNumber']?.toString();
    final vendor = order?['vendor'];
    final vendorName = vendor is Map ? vendor['name']?.toString() : null;

    setState(() {
      _headerName = champName.isNotEmpty ? champName : 'Champ';
      _champPhone = phone;
      _orderBadge =
          'Order ${orderNumber == null || orderNumber.isEmpty ? '' : '#$orderNumber'}${vendorName == null || vendorName.isEmpty ? '' : ' · $vendorName'}';
      _messages = chat.messages
          .map(
            (m) => DriverChatMessage(text: m.body, isUser: m.isMine),
          )
          .toList();
      _quickReplies =
          replies.isNotEmpty ? replies : OrderFlowData.chatQuickReplies;
      _error = chat.ok ? null : chat.error;
      _loading = false;
    });

    if (!chat.ok) {
      _pollTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            chat.error ?? 'Champ not assigned yet — chat unavailable',
          ),
        ),
      );
      return;
    }

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
  }

  Future<void> _refresh() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty || !mounted) return;
    final chat =
        await ref.read(orderChatRepositoryProvider).openOrderChat(orderId);
    if (!mounted) return;
    if (!chat.ok) {
      _pollTimer?.cancel();
      return;
    }
    setState(() {
      _messages = chat.messages
          .map((m) => DriverChatMessage(text: m.body, isUser: m.isMine))
          .toList();
    });
  }

  Future<void> _onCall() async {
    if (_champPhone == null || _champPhone!.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Champ phone unavailable yet'),
        ),
      );
      return;
    }
    final ok = await launchPhoneCall(_champPhone);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open phone dialer')),
      );
    }
  }

  Future<void> _send([String? preset]) async {
    if (_sending) return;
    final orderId = widget.orderId;
    final body = (preset ?? _controller.text).trim();
    if (body.isEmpty) return;
    if (orderId == null || orderId.isEmpty) return;
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
          _DriverChatHeader(name: _headerName, onCall: _onCall),
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
                          if (_messages.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: Text(
                                _error ??
                                    (_headerName == 'Champ'
                                        ? 'Champ will be assigned soon. Chat opens when your driver is on the way.'
                                        : 'No messages yet. Say hi to your champ.'),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
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
            enabled: !_sending && widget.orderId != null && _error == null,
            onSend: _send,
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 1),
    );
  }
}

class _DriverChatHeader extends StatelessWidget {
  const _DriverChatHeader({required this.name, this.onCall});

  final String name;
  final VoidCallback? onCall;

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
            GestureDetector(
              onTap: onCall,
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}
