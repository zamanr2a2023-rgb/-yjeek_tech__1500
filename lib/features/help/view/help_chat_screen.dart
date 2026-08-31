import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/app_text_styles.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/help/model/help_phase2_data.dart';
import 'package:yjeek_app/features/help/view/widgets/help_widgets.dart';

class HelpChatScreen extends ConsumerStatefulWidget {
  const HelpChatScreen({
    super.key,
    required this.variant,
    this.ticketId,
    this.bottomNavIndex = 4,
  });

  final HelpChatVariant variant;
  final String? ticketId;
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
  String? _error;

  @override
  void initState() {
    super.initState();
    _ticketId = widget.ticketId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    var ticketId = _ticketId?.trim();
    if (ticketId == null || ticketId.isEmpty) {
      // Ensure every Support chat session is backed by a real ticket.
      String? orderId;
      final recent = await ref.read(ordersRepositoryProvider).listOrders();
      if (recent.isNotEmpty) orderId = recent.first.id;

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
      ticketId = ticket.id;
      _ticketId = ticketId;
    }

    await _loadMessages(ticketId);
  }

  Future<void> _loadMessages(String ticketId) async {
    final rows =
        await ref.read(supportRepositoryProvider).listMessages(ticketId);
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
    final ticketId = _ticketId;
    if (text.isEmpty || _sending || ticketId == null || ticketId.isEmpty) {
      return;
    }

    setState(() => _sending = true);
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
    await _loadMessages(ticketId);
  }

  @override
  Widget build(BuildContext context) {
    final hasTicket = _ticketId != null && _ticketId!.isNotEmpty;
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
                        child: Padding(
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
                          _ChatStatusRow(
                            label: hasTicket
                                ? 'Care · ticket open · replies usually within minutes'
                                : HelpPhase2Data.chatStatusFor(widget.variant),
                          ),
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
            enabled: !_sending && !_loading && hasTicket && _error == null,
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
