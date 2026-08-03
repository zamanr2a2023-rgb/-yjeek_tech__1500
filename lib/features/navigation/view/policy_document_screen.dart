import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yjeek_app/core/constants/app_colors.dart';
import 'package:yjeek_app/core/constants/navigation_strings.dart';
import 'package:yjeek_app/core/providers/app_providers.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/navigation/model/content_repository.dart';
import 'package:yjeek_app/features/navigation/model/wallet_data.dart';
import 'package:yjeek_app/features/navigation/view/widgets/account_widgets.dart';
import 'package:yjeek_app/features/navigation/view/widgets/navigation_widgets.dart';

enum PolicyType { terms, privacy, refund, walletTerms, consumerProtection }

extension PolicyTypeX on PolicyType {
  static PolicyType fromQuery(String? value) => switch (value) {
        'privacy' => PolicyType.privacy,
        'refund' => PolicyType.refund,
        'wallet' || 'wallet-terms' => PolicyType.walletTerms,
        'consumer' || 'consumer-protection' => PolicyType.consumerProtection,
        _ => PolicyType.terms,
      };

  String get title => switch (this) {
        PolicyType.terms => NavigationStrings.termsConditions,
        PolicyType.privacy => NavigationStrings.privacyPolicy,
        PolicyType.refund => NavigationStrings.refundReturn,
        PolicyType.walletTerms => 'Wallet Terms',
        PolicyType.consumerProtection => 'Consumer Protection',
      };

  String get apiSlug => switch (this) {
        PolicyType.terms => 'terms',
        PolicyType.privacy => 'privacy',
        PolicyType.refund => 'refund',
        PolicyType.walletTerms => 'wallet-terms',
        PolicyType.consumerProtection => 'consumer-protection',
      };

  String get fallbackIntro => switch (this) {
        PolicyType.terms => WalletData.termsIntro,
        PolicyType.privacy => WalletData.privacyIntro,
        PolicyType.refund => WalletData.refundIntro,
        PolicyType.walletTerms => 'Yjeek Wallet terms of use',
        PolicyType.consumerProtection =>
          'Your rights under Bahrain consumer protection law',
      };

  List<PolicySection> get fallbackSections => switch (this) {
        PolicyType.terms => WalletData.termsSections,
        PolicyType.privacy => WalletData.privacySections,
        PolicyType.refund => WalletData.refundSections,
        PolicyType.walletTerms => const [
            PolicySection(
              title: 'Wallet credits',
              body:
                  'Cashback and refund credits sit in your Yjeek Wallet and can be used at checkout or withdrawn when KYC and bank details are verified.',
            ),
          ],
        PolicyType.consumerProtection => const [
            PolicySection(
              title: 'Your rights',
              body:
                  'Yjeek supports Bahrain Consumer Protection Law. Contact Care for refunds, cancellations, and dispute resolution.',
            ),
          ],
      };
}

class PolicyDocumentScreen extends ConsumerStatefulWidget {
  const PolicyDocumentScreen({super.key, required this.type});

  final PolicyType type;

  @override
  ConsumerState<PolicyDocumentScreen> createState() =>
      _PolicyDocumentScreenState();
}

class _PolicyDocumentScreenState extends ConsumerState<PolicyDocumentScreen> {
  bool _loading = true;
  PolicyDocumentContent? _content;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final content = await ref
        .read(contentRepositoryProvider)
        .fetchPolicy(widget.type.apiSlug);
    if (!mounted) return;
    setState(() {
      _content = content;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final intro = (_content?.intro.isNotEmpty ?? false)
        ? _content!.intro
        : type.fallbackIntro;
    final sections = (_content?.sections.isNotEmpty ?? false)
        ? _content!.sections
        : type.fallbackSections;
    final title = (_content?.title.isNotEmpty ?? false)
        ? _content!.title
        : type.title;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          NavBackHeader(title: title, backIconColor: AppColors.textPrimary),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.noScaling,
                    ),
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
                        children: [
                          Text(intro, style: PolicyTypography.intro()),
                          SizedBox(height: 14.h),
                          ...sections.asMap().entries.map((entry) {
                            final isLast = entry.key == sections.length - 1;
                            return Padding(
                              padding:
                                  EdgeInsets.only(bottom: isLast ? 0 : 14.h),
                              child: PolicySectionCard(section: entry.value),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const ShellBottomNavBar(currentIndex: 4),
    );
  }
}
