import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme.dart';

enum PlanTier { free, pro, scholar }

class PricingPlan {
  final PlanTier tier;
  final String name;
  final String price;
  final String period;
  final String tagline;
  final String emoji;
  final List<String> features;
  final List<String> lockedFeatures;
  final String model;
  final int perspectivesPerEvent;
  final bool isPopular;
  final List<Color> gradient;

  const PricingPlan({
    required this.tier,
    required this.name,
    required this.price,
    required this.period,
    required this.tagline,
    required this.emoji,
    required this.features,
    required this.lockedFeatures,
    required this.model,
    required this.perspectivesPerEvent,
    required this.isPopular,
    required this.gradient,
  });
}

const List<PricingPlan> kPlans = [
  PricingPlan(
    tier: PlanTier.free,
    name: 'Explorer',
    price: 'Free',
    period: 'forever',
    tagline: 'Start your journey',
    emoji: '🌱',
    model: 'llama-3.3-70b-versatile',
    perspectivesPerEvent: 3,
    isPopular: false,
    gradient: [Color(0xFF6B7280), Color(0xFF9CA3AF)],
    features: [
      '3 perspectives per event',
      'Country & Religion filters',
      '12 preset historical events',
      'Copy to clipboard',
    ],
    lockedFeatures: [
      'School of Thought & Cultural filters',
      'Custom event exploration',
      'Save & bookmark perspectives',
      'Premium AI models',
      'Deeper analysis (500+ words)',
    ],
  ),
  PricingPlan(
    tier: PlanTier.pro,
    name: 'Historian',
    price: '\$4.99',
    period: 'per month',
    tagline: 'For the curious mind',
    emoji: '📚',
    model: 'llama-3.3-70b-versatile',
    perspectivesPerEvent: 5,
    isPopular: true,
    gradient: [Color(0xFF10A37F), Color(0xFF059669)],
    features: [
      '5 perspectives per event',
      'All 4 perspective types',
      'Custom event exploration',
      'Save & bookmark perspectives',
      'Copy to clipboard',
      'Priority response speed',
    ],
    lockedFeatures: [
      'Deeper analysis (500+ words)',
      'Comparative mode (side-by-side)',
      'Export as PDF',
    ],
  ),
  PricingPlan(
    tier: PlanTier.scholar,
    name: 'Scholar',
    price: '\$9.99',
    period: 'per month',
    tagline: 'For serious researchers',
    emoji: '🎓',
    model: 'deepseek-r1-distill-llama-70b',
    perspectivesPerEvent: 8,
    isPopular: false,
    gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
    features: [
      '8 perspectives per event',
      'All 4 perspective types',
      'Custom event exploration',
      'Save & bookmark perspectives',
      'Deeper analysis (500+ words)',
      'Comparative side-by-side mode',
      'Export as PDF',
      'DeepSeek R1 reasoning model',
      'Earliest access to new features',
    ],
    lockedFeatures: [],
  ),
];

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  PlanTier _selectedTier = PlanTier.pro;
  bool _isAnnual = false;

  double get _annualDiscount => 0.2;

  String _displayPrice(PricingPlan plan) {
    if (plan.tier == PlanTier.free) return 'Free';
    final base = plan.tier == PlanTier.pro ? 4.99 : 9.99;
    if (_isAnnual) {
      final discounted = base * (1 - _annualDiscount);
      return '\$${discounted.toStringAsFixed(2)}';
    }
    return plan.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIconsRegular.arrowLeft, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Choose a Plan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildBillingToggle(),
            const SizedBox(height: 16),
            _buildPlanCards(),
            const SizedBox(height: 24),
            _buildFeatureComparison(),
            _buildFAQ(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unlock every lens', style: Theme.of(context).textTheme.displayMedium)
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
          Text(
            'Explore deeper perspectives with more AI power.',
            style: Theme.of(context).textTheme.bodyMedium,
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toggleTab('Monthly', !_isAnnual, () => setState(() => _isAnnual = false)),
            _toggleTab('Annual  –20%', _isAnnual, () => setState(() => _isAnnual = true)),
          ],
        ),
      ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
    );
  }

  Widget _toggleTab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppTheme.background : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCards() {
    return SizedBox(
      height: 420,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: kPlans.length,
        itemBuilder: (context, index) {
          final plan = kPlans[index];
          final isSelected = _selectedTier == plan.tier;
          return _PlanCard(
            plan: plan,
            isSelected: isSelected,
            displayPrice: _displayPrice(plan),
            isAnnual: _isAnnual,
            onTap: () => setState(() => _selectedTier = plan.tier),
            onSubscribe: () => _handleSubscribe(plan),
          ).animate(delay: Duration(milliseconds: 100 + index * 80))
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildFeatureComparison() {
    final rows = [
      ('Perspectives per event', ['3', '5', '8']),
      ('Perspective types', ['2', '4', '4']),
      ('Custom event input', ['❌', '✅', '✅']),
      ('Save & bookmark', ['❌', '✅', '✅']),
      ('Deep analysis (500+ words)', ['❌', '❌', '✅']),
      ('Side-by-side compare', ['❌', '❌', '✅']),
      ('Export as PDF', ['❌', '❌', '✅']),
      ('AI Model', ['LLaMA 3.3\n70B', 'LLaMA 3.3\n70B', 'DeepSeek R1\n70B']),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compare plans', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _comparisonHeader(),
                const Divider(height: 1),
                ...rows.asMap().entries.map((entry) {
                  return _comparisonRow(entry.value.$1, entry.value.$2, entry.key.isEven);
                }),
              ],
            ),
          ),
        ],
      ).animate(delay: 400.ms).fadeIn(duration: 350.ms),
    );
  }

  Widget _comparisonHeader() {
    const headers = ['', 'Explorer', 'Historian', 'Scholar'];
    const colors = [
      Colors.transparent,
      Color(0xFF6B7280),
      AppTheme.primary,
      Color(0xFF764BA2),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: headers.asMap().entries.map((e) {
          return Expanded(
            flex: e.key == 0 ? 2 : 1,
            child: Center(
              child: e.key == 0
                  ? const SizedBox.shrink()
                  : Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors[e.key],
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _comparisonRow(String label, List<String> values, bool shaded) {
    return Container(
      color: shaded ? AppTheme.surface : AppTheme.background,
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ),
          ),
          ...values.map(
            (v) => Expanded(
              child: Text(
                v,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: v == '❌' ? AppTheme.textTertiary : AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    final faqs = [
      ('Can I cancel anytime?', 'Yes, you can cancel your subscription at any time. You\'ll retain access until the end of your billing period.'),
      ('Is my data safe?', 'All your saved perspectives are stored securely via Supabase. We never use your data for AI training.'),
      ('What AI models are used?', 'Free & Historian plans use LLaMA 3.3 70B via Groq. Scholar plan uses DeepSeek R1 70B for deeper reasoning.'),
      ('Can I switch plans?', 'Yes, you can upgrade or downgrade at any time. Changes take effect on the next billing cycle.'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frequently asked', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          ...faqs.map(
            (faq) => _FAQItem(question: faq.$1, answer: faq.$2),
          ),
        ],
      ).animate(delay: 500.ms).fadeIn(duration: 350.ms),
    );
  }

  void _handleSubscribe(PricingPlan plan) {
    if (plan.tier == PlanTier.free) {
      Navigator.of(context).pop();
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ComingSoonSheet(plan: plan),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PricingPlan plan;
  final bool isSelected;
  final String displayPrice;
  final bool isAnnual;
  final VoidCallback onTap;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.displayPrice,
    required this.isAnnual,
    required this.onTap,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 220,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? plan.gradient[0] : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: plan.gradient[0].withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 6))]
              : [const BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(context),
            Expanded(child: _buildCardFeatures(context)),
            _buildCardButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: plan.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(plan.emoji, style: const TextStyle(fontSize: 24)),
              const Spacer(),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          Text(plan.tagline, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayPrice,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
              ),
              if (plan.tier != PlanTier.free) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    isAnnual ? '/mo billed annually' : plan.period,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: plan.features.map((f) => _featureRow(f, true)).toList(),
      ),
    );
  }

  Widget _featureRow(String text, bool included) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            PhosphorIcon(
            included ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.xCircle,
            size: 16,
            color: included ? AppTheme.primary : AppTheme.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: included ? AppTheme.textPrimary : AppTheme.textTertiary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onSubscribe,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? plan.gradient[0] : AppTheme.surface,
            foregroundColor: isSelected ? Colors.white : AppTheme.textPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            plan.tier == PlanTier.free ? 'Current Plan' : 'Get ${plan.name}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PhosphorIcon(
                  _expanded ? PhosphorIconsRegular.caretUp : PhosphorIconsRegular.caretDown,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              widget.answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}

class _ComingSoonSheet extends StatelessWidget {
  final PricingPlan plan;

  const _ComingSoonSheet({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: plan.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text(plan.emoji, style: const TextStyle(fontSize: 34))),
          ),
          const SizedBox(height: 20),
          Text('${plan.name} — Coming Soon', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'Payments are not yet enabled. In-app purchases will be available in the next release. Stay tuned!',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }
}
