import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/historical_event.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../../services/groq_service.dart';
import '../../services/history_service.dart';
import '../../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _groqService = GroqService();
  String _searchQuery = '';
  List<String> _aiSuggestions = [];
  bool _isSearchLoading = false;
  Timer? _debounce;
  bool _showSuggestions = false;

  List<HistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _groqService.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final entries = await context.read<HistoryService>().getRecent();
    if (mounted) setState(() => _history = entries);
  }

  void _onSearchChanged(String q) {
    setState(() { _searchQuery = q; _showSuggestions = q.length > 1; });
    _debounce?.cancel();
    if (q.length < 2) { setState(() { _aiSuggestions = []; _isSearchLoading = false; }); return; }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearchLoading = true);
      try {
        final suggestions = await _groqService.suggestEvents(q);
        if (mounted) setState(() { _aiSuggestions = suggestions; _isSearchLoading = false; });
      } catch (_) {
        if (mounted) setState(() => _isSearchLoading = false);
      }
    });
  }

  void _onEventTap(HistoricalEvent event) {
    setState(() { _showSuggestions = false; _searchController.clear(); _searchQuery = ''; });
    FocusScope.of(context).unfocus();
    context.push('/event', extra: event);
  }

  void _onSuggestionTap(String title) {
    final event = HistoricalEvent(title: title, subtitle: 'AI-discovered event', emoji: '🔍', category: 'AI Search', description: title);
    _onEventTap(event);
  }

  Future<void> _openCustomEvent() async {
    final result = await showDialog<String>(context: context, builder: (_) => const _CustomEventDialog());
    if (result != null && result.isNotEmpty && mounted) {
      final event = HistoricalEvent(title: result, subtitle: 'Custom Event', emoji: '📖', category: 'Custom', description: result);
      context.push('/event', extra: event);
    }
  }

  Future<void> _signOut() async {
    final auth = context.read<AuthService>();
    await auth.signOut();
    if (mounted) context.go('/login');
  }

  List<HistoricalEvent> get _allEvents => AppConstants.presetEvents.map(HistoricalEvent.fromMap).toList();

  List<HistoricalEvent> get _filteredEvents {
    if (_searchQuery.isEmpty) return _allEvents;
    return _allEvents.where((e) =>
        e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus(); setState(() => _showSuggestions = false); },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(colors),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildSearchBar(colors)),
                if (_history.isNotEmpty && _searchQuery.isEmpty)
                  SliverToBoxAdapter(child: _buildHistorySection(colors)),
                SliverToBoxAdapter(child: _buildCustomEventBanner(colors)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _EventCard(event: _filteredEvents[i], onTap: _onEventTap, index: i),
                      childCount: _filteredEvents.length,
                    ),
                  ),
                ),
              ],
            ),
            if (_showSuggestions) _buildSuggestionsOverlay(colors),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(AppColors colors) {
    final themeProvider = context.watch<ThemeProvider>();
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
            child: Center(child: PhosphorIcon(PhosphorIconsRegular.planet, color: Colors.white, size: 18)),
          ),
          const SizedBox(width: 10),
          Text('HistoriLens', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
      actions: [
        IconButton(
          icon: PhosphorIcon(themeProvider.isDark ? PhosphorIconsRegular.sun : PhosphorIconsRegular.moon, size: 20),
          onPressed: themeProvider.toggle,
          tooltip: 'Toggle theme',
        ),
        PopupMenuButton<String>(
          icon: PhosphorIcon(PhosphorIconsRegular.userCircle, size: 24, color: colors.textSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          offset: const Offset(0, 48),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'pricing', child: Row(children: [
              PhosphorIcon(PhosphorIconsRegular.crown, size: 18, color: AppTheme.primary),
              const SizedBox(width: 10),
              Text('Upgrade Plan', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ])),
            PopupMenuItem(value: 'saved', child: Row(children: [
              PhosphorIcon(PhosphorIconsRegular.bookmarks, size: 18, color: colors.textSecondary),
              const SizedBox(width: 10),
              Text('Saved Perspectives', style: Theme.of(context).textTheme.bodyMedium),
            ])),
            const PopupMenuDivider(),
            PopupMenuItem(value: 'signout', child: Row(children: [
              PhosphorIcon(PhosphorIconsRegular.signOut, size: 18, color: colors.textSecondary),
              const SizedBox(width: 10),
              Text('Sign Out', style: Theme.of(context).textTheme.bodyMedium),
            ])),
          ],
          onSelected: (v) {
            if (v == 'signout') _signOut();
            if (v == 'pricing') context.push('/pricing');
            if (v == 'saved') context.push('/saved');
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        onTap: () { if (_searchQuery.length > 1) setState(() => _showSuggestions = true); },
        decoration: InputDecoration(
          hintText: 'Search or discover any historical event...',
          prefixIcon: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass, size: 20, color: colors.textTertiary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: PhosphorIcon(PhosphorIconsRegular.x, size: 18, color: colors.textTertiary),
                  onPressed: () { _searchController.clear(); _onSearchChanged(''); },
                )
              : _isSearchLoading
                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                  : null,
        ),
      ),
    );
  }

  Widget _buildSuggestionsOverlay(AppColors colors) {
    return Positioned(
      top: 72,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: _aiSuggestions.isEmpty && _isSearchLoading
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
              : _aiSuggestions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Type more to get AI suggestions…', style: TextStyle(color: colors.textTertiary)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _aiSuggestions.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: colors.border),
                      itemBuilder: (context, i) {
                        return ListTile(
                          leading: PhosphorIcon(PhosphorIconsRegular.sparkle, size: 18, color: AppTheme.primary),
                          title: Text(_aiSuggestions[i], style: TextStyle(fontSize: 14, color: colors.textPrimary)),
                          dense: true,
                          onTap: () => _onSuggestionTap(_aiSuggestions[i]),
                        );
                      },
                    ),
        ),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0),
    );
  }

  Widget _buildHistorySection(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(PhosphorIconsRegular.clockCounterClockwise, size: 16, color: colors.textSecondary),
              const SizedBox(width: 6),
              Text('Recently Explored', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await context.read<HistoryService>().clearAll();
                  setState(() => _history = []);
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('Clear', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _history.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final item = _history[i];
                return GestureDetector(
                  onTap: () {
                    final event = HistoricalEvent(title: item.eventTitle, subtitle: item.eventSubtitle, emoji: item.eventEmoji, category: '', description: item.eventTitle);
                    _onEventTap(event);
                  },
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.eventEmoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(item.eventTitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: i * 50)).fadeIn(duration: 300.ms);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomEventBanner(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        children: [
          // Upgrade banner
          InkWell(
            onTap: () => context.push('/pricing'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                PhosphorIcon(PhosphorIconsRegular.graduationCap, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Unlock Scholar plan', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('DeepSeek R1 · 8 perspectives · Export PDF', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                ])),
                PhosphorIcon(PhosphorIconsRegular.caretRight, size: 12, color: Colors.white),
              ]),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 10),
          // Custom event
          InkWell(
            onTap: _openCustomEvent,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                PhosphorIcon(PhosphorIconsRegular.plusCircle, color: AppTheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Explore any event', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primary)),
                  Text('Type a custom historical event or topic', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary.withValues(alpha: 0.8))),
                ])),
                PhosphorIcon(PhosphorIconsRegular.caretRight, size: 14, color: AppTheme.primary),
              ]),
            ),
          ).animate(delay: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Explore History', style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
    );
  }
}

// ─── Event Card ───────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final HistoricalEvent event;
  final ValueChanged<HistoricalEvent> onTap;
  final int index;

  const _EventCard({required this.event, required this.onTap, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradients = AppTheme.perspectiveGradients;
    final c1 = gradients[index * 2 % gradients.length];
    final c2 = gradients[(index * 2 + 1) % gradients.length];

    return GestureDetector(
      onTap: () => onTap(event),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
          boxShadow: [BoxShadow(color: colors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c1, c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Center(child: Text(event.emoji, style: const TextStyle(fontSize: 38))),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: Text(event.category, style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Text(event.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(event.subtitle, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn(duration: 300.ms).slideY(begin: 0.06, end: 0);
  }
}

// ─── Custom Event Dialog ──────────────────────────────────────────────────────

class _CustomEventDialog extends StatefulWidget {
  const _CustomEventDialog();

  @override
  State<_CustomEventDialog> createState() => _CustomEventDialogState();
}

class _CustomEventDialogState extends State<_CustomEventDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AlertDialog(
      backgroundColor: colors.surface,
      title: Row(children: [
        PhosphorIcon(PhosphorIconsRegular.magnifyingGlass, size: 20, color: AppTheme.primary),
        const SizedBox(width: 10),
        const Text('Custom Event'),
      ]),
      content: TextField(
        controller: _controller,
        autofocus: true,
        onSubmitted: (v) => Navigator.of(context).pop(v),
        decoration: const InputDecoration(hintText: 'e.g. The Fall of Constantinople'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(_controller.text), child: const Text('Explore')),
      ],
    );
  }
}
