import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../models/historical_event.dart';
import '../../models/perspective.dart';
import '../../providers/perspective_provider.dart';
import '../../services/bookmark_service.dart';
import 'deep_dive_sheet.dart';

class PerspectivesScreen extends StatefulWidget {
  final HistoricalEvent event;

  const PerspectivesScreen({super.key, required this.event});

  @override
  State<PerspectivesScreen> createState() => _PerspectivesScreenState();
}

class _PerspectivesScreenState extends State<PerspectivesScreen> {
  final _pageController = PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerspectiveProvider>().loadPerspectives(
            event: widget.event,
            type: PerspectiveType.country,
          );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventHeader(colors),
          _buildTypeChips(),
          const SizedBox(height: 16),
          Expanded(child: _buildContent(colors)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(AppColors colors) {
    return AppBar(
      backgroundColor: colors.background,
      leading: IconButton(
        icon: PhosphorIcon(PhosphorIconsRegular.arrowLeft, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('Perspectives'),
      actions: [
        IconButton(
          icon: PhosphorIcon(PhosphorIconsRegular.bookmarks, size: 20),
          tooltip: 'Saved',
          onPressed: () => Navigator.of(context).pushNamed('/saved'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildEventHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          Text(widget.event.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.event.title, style: Theme.of(context).textTheme.headlineMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(widget.event.subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTypeChips() {
    return Consumer<PerspectiveProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: PerspectiveType.values.map((type) {
              final isSelected = provider.currentType == type;
              final isLoading = provider.state == PerspectiveLoadState.loading;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhosphorIcon(type.icon, size: 14,
                          color: isSelected ? AppTheme.primary : AppTheme.textSecondary),
                      const SizedBox(width: 5),
                      Text(type.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: isLoading ? null : (sel) {
                    if (sel) { provider.changeType(type); _pageController.jumpToPage(0); }
                  },
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  backgroundColor: context.colors.surface,
                  selectedColor: AppTheme.primaryLight,
                  side: BorderSide(color: isSelected ? AppTheme.primary.withValues(alpha: 0.4) : context.colors.border),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildContent(AppColors colors) {
    return Consumer<PerspectiveProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case PerspectiveLoadState.loading: return _buildShimmer(colors);
          case PerspectiveLoadState.error: return _buildError(provider.error);
          case PerspectiveLoadState.loaded: return _buildSlides(provider.perspectives, colors);
          case PerspectiveLoadState.idle: return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildShimmer(AppColors colors) {
    return Shimmer.fromColors(
      baseColor: colors.surface,
      highlightColor: colors.surfaceVariant,
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Generating perspectives with AI...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(PhosphorIconsRegular.warning, color: AppTheme.error, size: 48),
            const SizedBox(height: 16),
            Text('Could not load perspectives', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(error.length > 120 ? '${error.substring(0, 120)}...' : error, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final p = context.read<PerspectiveProvider>();
                p.changeType(p.currentType);
              },
              icon: PhosphorIcon(PhosphorIconsRegular.arrowClockwise, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlides(List<Perspective> perspectives, AppColors colors) {
    if (perspectives.isEmpty) return const Center(child: Text('No perspectives generated.'));
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: perspectives.length,
            itemBuilder: (context, index) {
              return _PerspectiveCard(
                perspective: perspectives[index],
                event: widget.event,
                index: index,
                colors: colors,
              ).animate(delay: Duration(milliseconds: index * 60)).fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SmoothPageIndicator(
            controller: _pageController,
            count: perspectives.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppTheme.primary,
              dotColor: colors.border,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 2.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Perspective Card ─────────────────────────────────────────────────────────

class _PerspectiveCard extends StatefulWidget {
  final Perspective perspective;
  final HistoricalEvent event;
  final int index;
  final AppColors colors;

  const _PerspectiveCard({
    required this.perspective,
    required this.event,
    required this.index,
    required this.colors,
  });

  @override
  State<_PerspectiveCard> createState() => _PerspectiveCardState();
}

class _PerspectiveCardState extends State<_PerspectiveCard> {
  final _screenshotController = ScreenshotController();
  bool _isBookmarked = false;
  String? _bookmarkId;
  bool _isBookmarkLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final service = context.read<BookmarkService>();
    final id = await service.getBookmarkId(widget.event.title, widget.perspective.label);
    if (mounted) setState(() { _bookmarkId = id; _isBookmarked = id != null; });
  }

  Future<void> _toggleBookmark() async {
    setState(() => _isBookmarkLoading = true);
    final service = context.read<BookmarkService>();
    if (_isBookmarked && _bookmarkId != null) {
      await service.remove(_bookmarkId!);
      _bookmarkId = null;
      _isBookmarked = false;
    } else {
      _bookmarkId = await service.save(
        eventTitle: widget.event.title,
        eventSubtitle: widget.event.subtitle,
        eventEmoji: widget.event.emoji,
        perspective: widget.perspective,
      );
      _isBookmarked = _bookmarkId != null;
    }
    if (mounted) {
      setState(() => _isBookmarkLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isBookmarked ? 'Perspective saved!' : 'Bookmark removed'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  Future<void> _shareCard() async {
    final image = await _screenshotController.capture(pixelRatio: 3.0);
    if (image == null || !mounted) return;
    final tempDir = await Directory.systemTemp.createTemp();
    final file = await File('${tempDir.path}/perspective.png').writeAsBytes(image);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${widget.perspective.label} perspective on "${widget.event.title}" via HistoriLens',
    );
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeepDiveSheet(
        eventTitle: widget.event.title,
        perspective: widget.perspective,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradients = AppTheme.perspectiveGradients;
    final gradient = [
      gradients[widget.index * 2 % gradients.length],
      gradients[(widget.index * 2 + 1) % gradients.length],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Screenshot(
        controller: _screenshotController,
        child: Container(
          decoration: BoxDecoration(
            color: widget.colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.colors.border),
            boxShadow: [BoxShadow(color: widget.colors.cardShadow, blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(gradient),
              Expanded(child: _buildBody()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Color> gradient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhosphorIcon(widget.perspective.perspectiveType.icon, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(widget.perspective.perspectiveType.label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
              // Bookmark button
              _isBookmarkLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : GestureDetector(
                      onTap: _toggleBookmark,
                      child: PhosphorIcon(
                        _isBookmarked ? PhosphorIconsFill.bookmarkSimple : PhosphorIconsRegular.bookmarkSimple,
                        size: 22, color: Colors.white,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.perspective.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(widget.perspective.label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w400, height: 1.4)),
          const SizedBox(height: 4),
          Text(widget.perspective.title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(widget.perspective.content, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          _ActionButton(icon: PhosphorIconsRegular.copy, label: 'Copy', onTap: () {
            Clipboard.setData(ClipboardData(text: '${widget.perspective.label}: ${widget.perspective.content}'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1)));
          }),
          _ActionButton(icon: PhosphorIconsRegular.shareNetwork, label: 'Share', onTap: _shareCard),
          _ActionButton(icon: PhosphorIconsRegular.chatDots, label: 'Ask AI', onTap: _openChat),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(icon, size: 16, color: colors.textSecondary),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
