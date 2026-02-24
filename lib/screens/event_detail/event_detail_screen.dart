import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/historical_event.dart';
import '../../models/event_summary.dart';
import '../../services/groq_service.dart';
import '../../services/history_service.dart';

class EventDetailScreen extends StatefulWidget {
  final HistoricalEvent event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventSummary? _summary;
  bool _isLoading = true;
  String? _error;
  final _groqService = GroqService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Log to history
    context.read<HistoryService>().logEvent(widget.event);

    try {
      final summary = await _groqService.generateEventSummary(
        eventTitle: widget.event.title,
        eventDescription: widget.event.subtitle,
      );
      if (mounted) setState(() { _summary = summary; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _groqService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIconsRegular.arrowLeft, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIconsRegular.books, size: 22, color: AppTheme.primary),
            tooltip: 'Explore Perspectives',
            onPressed: () => context.push('/perspectives', extra: widget.event),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(colors),
            const SizedBox(height: 28),
            if (_isLoading) _buildShimmer(colors),
            if (_error != null) _buildError(),
            if (_summary != null) _buildContent(colors),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomCTA(),
    );
  }

  Widget _buildHero(AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.event.emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(widget.event.title, style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 6),
              Text(widget.event.subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildContent(AppColors colors) {
    final s = _summary!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(PhosphorIconsRegular.clock, size: 14, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(s.period, style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Overview
        _SectionCard(
          icon: PhosphorIconsRegular.newspaper,
          title: 'Overview',
          colors: colors,
          child: Text(s.overview, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(height: 14),

        // Key Players
        _SectionCard(
          icon: PhosphorIconsRegular.users,
          title: 'Key Players',
          colors: colors,
          child: Column(
            children: s.keyPlayers.map((p) => _BulletRow(text: p, colors: colors)).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Significance
        _SectionCard(
          icon: PhosphorIconsRegular.scales,
          title: 'Historical Significance',
          colors: colors,
          child: Column(
            children: s.significance.map((sig) => _BulletRow(text: sig, colors: colors)).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Fast Facts
        _SectionCard(
          icon: PhosphorIconsRegular.lightning,
          title: 'Fast Facts',
          colors: colors,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: s.fastFacts.map((fact) => _FactChip(fact: fact, colors: colors)).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildShimmer(AppColors colors) {
    return Shimmer.fromColors(
      baseColor: colors.surface,
      highlightColor: colors.surfaceVariant,
      child: Column(
        children: List.generate(4, (i) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 100 + (i * 20).toDouble(),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        )),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        children: [
          PhosphorIcon(PhosphorIconsRegular.warning, color: AppTheme.error, size: 40),
          const SizedBox(height: 12),
          Text('Could not load summary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () { setState(() { _isLoading = true; _error = null; }); _load(); },
            icon: PhosphorIcon(PhosphorIconsRegular.arrowClockwise, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/perspectives', extra: widget.event),
            icon: PhosphorIcon(PhosphorIconsRegular.globe, size: 20, color: Colors.white),
            label: const Text('Explore Perspectives'),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final PhosphorIconData icon;
  final String title;
  final Widget child;
  final AppColors colors;

  const _SectionCard({required this.icon, required this.title, required this.child, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  final AppColors colors;
  const _BulletRow({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6, height: 6,
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  final String fact;
  final AppColors colors;
  const _FactChip({required this.fact, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Text(fact, style: TextStyle(fontSize: 12, color: colors.textPrimary, fontWeight: FontWeight.w500)),
    );
  }
}
