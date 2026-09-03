import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/model/support_repository.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';

class HelpChatScreen extends ConsumerStatefulWidget {
  const HelpChatScreen({
    super.key,
    required this.variant,
    this.ticketId,
    this.orderId,
    this.bottomNavIndex = 4,
  });

  final HelpChatVariant variant;
  final String? ticketId;
  final String? orderId;
  final int bottomNavIndex;

  @override
  ConsumerState<HelpChatScreen> createState() => _HelpChatScreenState();
}

class _HelpChatScreenState extends ConsumerState<HelpChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  List<HelpChatMessage> _messages = const [];
  bool _loading = true;
  bool _sending = false;
  String? _ticketId;
  String? _orderId;
  SupportTicketItem? _ticket;
  String? _conversationStatus;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ticketId = widget.ticketId;
    _orderId = widget.orderId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _canChat {
    final conversationStatus = _conversationStatus?.toUpperCase();
    if (conversationStatus == 'CLOSED' || conversationStatus == 'RESOLVED') {
      return false;
    }
    if (_ticket != null) return _ticket!.canChat;
    return _orderId != null && _orderId!.isNotEmpty;
  }

  String get _statusLabel {
    if (_ticket == null) {
      return HelpPhase2Data.chatStatusFor(widget.variant);
    }
    if (!_canChat) {
      return 'Request closed · submit a new issue from Order help';
    }
    final code = _ticket!.displayCode;
    final status = _conversationStatus ?? _ticket!.status;
    return 'Care · $code · $status';
  }

  String _friendlyChatError(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return 'Could not load support chat';
    if (text.contains('prisma.') || text.contains('Invalid `')) {
      return 'Could not load support chat. Please try again.';
    }
    if (text.length > 180) return '${text.substring(0, 177)}...';
    return text;
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final support = ref.read(supportRepositoryProvider);
    final ticketId = _ticketId?.trim();
    final orderId = _orderId?.trim();

    if ((ticketId == null || ticketId.isEmpty) &&
        orderId != null &&
        orderId.isNotEmpty) {
      final active = await support.findActiveTicketForOrder(orderId);
      if (!mounted) return;
      if (active != null) {
        _ticketId = active.id;
        _ticket = active;
      }
    }

    final resolvedTicketId = _ticketId?.trim();
    if (resolvedTicketId != null && resolvedTicketId.isNotEmpty) {
      _ticket = await support.getTicket(resolvedTicketId) ?? _ticket;
      _orderId = _ticket?.orderId ?? orderId;
    }

    if (_orderId == null || _orderId!.isEmpty) {
      await _loadTicketMessages();
      return;
    }

    await _loadConversationMessages();
  }

  Future<void> _loadTicketMessages() async {
    final ticketId = _ticketId?.trim();
    if (ticketId == null || ticketId.isEmpty) {
      final recent = await ref.read(ordersRepositoryProvider).listOrders();
      final orderId = recent.isNotEmpty ? recent.first.id : null;
      final ticket = await ref.read(supportRepositoryProvider).createTicket(
            subject: 'General support · Care chat',
            remark: 'Customer opened Care chat.',
            orderId: orderId,
            issueType: 'other',
          );
      if (!mounted) return;
      if (ticket == null || ticket.id.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Could not start support chat';
          _messages = const [];
        });
        return;
      }
      _ticketId = ticket.id;
      _ticket = ticket;
      _orderId = ticket.orderId ?? orderId;
    } else {
      _ticket = await ref.read(supportRepositoryProvider).getTicket(ticketId) ??
          _ticket;
    }

    final rows =
        await ref.read(supportRepositoryProvider).listMessages(_ticketId!);
    if (!mounted) return;
    final mapped = rows
        .map(
          (m) => HelpChatMessage(
            text: m.body,
            isUser: m.isCustomer,
            isSystem: m.sender.toUpperCase() == 'SYSTEM',
            isAgentJoin: false,
            avatarLabel: m.isCustomer
                ? 'Y'
                : (m.senderName?.isNotEmpty == true
                    ? m.senderName![0].toUpperCase()
                    : 'M'),
          ),
        )
        .toList();

    setState(() {
      _messages = mapped.isNotEmpty
          ? mapped
          : [
              const HelpChatMessage(
                text:
                    'Thanks — your request is with Care. Reply here and we’ll follow up.',
                isSystem: true,
              ),
            ];
      _loading = false;
      _error = null;
    });
    _scrollToEnd();
  }

  Future<void> _loadConversationMessages() async {
    final orderId = _orderId?.trim();
    if (orderId == null || orderId.isEmpty) return;

    final chat = await ref.read(orderChatRepositoryProvider).openOrderChat(orderId);
    if (!mounted) return;

    if (!chat.ok) {
      setState(() {
        _loading = false;
        _error = _friendlyChatError(chat.error);
        _messages = const [];
      });
      return;
    }

    _conversationStatus = chat.conversationStatus;

    if (_ticketId != null && _ticketId!.isNotEmpty) {
      _ticket = await ref.read(supportRepositoryProvider).getTicket(_ticketId!) ??
          _ticket;
    }

    final mapped = chat.messages
        .map(
          (m) => HelpChatMessage(
            text: m.body,
            isUser: m.isMine,
            isSystem: false,
            isAgentJoin: false,
            avatarLabel: m.isMine
                ? 'Y'
                : (m.senderName?.isNotEmpty == true
                    ? m.senderName![0].toUpperCase()
                    : 'M'),
          ),
        )
        .toList();

    setState(() {
      _messages = mapped.isNotEmpty
          ? mapped
          : [
              const HelpChatMessage(
                text:
                    'Thanks — your request is with Care. Reply here and we’ll follow up.',
                isSystem: true,
              ),
            ];
      _loading = false;
      _error = null;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending || !_canChat) return;

    final orderId = _orderId?.trim();
    setState(() => _sending = true);

    if (orderId != null && orderId.isNotEmpty) {
      final sent =
          await ref.read(orderChatRepositoryProvider).sendMessage(orderId, text);
      if (!mounted) return;
      setState(() => _sending = false);

      if (sent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not send message'),
            backgroundColor: Color(0xFFB42318),
          ),
        );
        return;
      }

      _input.clear();
      await _loadConversationMessages();
      return;
    }

    final ticketId = _ticketId?.trim();
    if (ticketId == null || ticketId.isEmpty) {
      if (mounted) setState(() => _sending = false);
      return;
    }

    final sent = await ref.read(supportRepositoryProvider).addMessage(
          ticketId,
          body: text,
        );
    if (!mounted) return;
    setState(() => _sending = false);

    if (sent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send message'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
      return;
    }

    _input.clear();
    await _loadTicketMessages();
  }

  @override
  Widget build(BuildContext context) {
    return HelpScreenScaffold(
      title: HelpPhase2Data.chatTitleFor(widget.variant),
      bottomNavIndex: widget.bottomNavIndex,
      showBottomNav: false,
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _error != null
                ? Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelMedium(
                              color: const Color(0xFFB42318),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed: _bootstrap,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
                    children: [
                      _ChatStatusRow(label: _statusLabel),
                      SizedBox(height: 12.h),
                      for (final message in _messages) ...[
                        HelpChatBubble(message: message),
                      ],
                    ],
                  ),
          ),
          HelpChatInputBar(
            controller: _input,
            onSend: _send,
            enabled: !_sending && !_loading && _error == null && _canChat,
          ),
        ],
      ),
    );
  }
}

class _ChatStatusRow extends StatelessWidget {
  const _ChatStatusRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption(color: const Color(0xFF3D4842))
                .copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.5.sp,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
