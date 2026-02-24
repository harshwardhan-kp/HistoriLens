import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/historical_event.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _authService = AuthService();
  String _searchQuery = '';

  List<HistoricalEvent> get _allEvents => AppConstants.presetEvents
      .map(HistoricalEvent.fromMap)
      .toList();

  List<HistoricalEvent> get _filteredEvents {
    if (_searchQuery.isEmpty) return _allEvents;
    return _allEvents
        .where((e) =>
            e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _onEventTap(HistoricalEvent event) {
    context.push('/perspectives', extra: event);
  }

  Future<void> _openCustomEvent() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _CustomEventDialog(),
    );
    if (result != null && result.isNotEmpty && mounted) {
      final event = HistoricalEvent(
        title: result,
        subtitle: 'Custom Event',
        emoji: '📖',
        category: 'Custom',
        description: result,
      );
      context.push('/perspectives', extra: event);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCustomEventBanner(),
          Expanded(child: _buildEventGrid()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: PhosphorIcon(PhosphorIconsRegular.planet, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'HistoriLens',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle_outlined, color: AppTheme.textSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          offset: const Offset(0, 48),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'pricing',
              child: Row(children: [
                PhosphorIcon(PhosphorIconsRegular.crown, size: 18, color: AppTheme.primary),
                const SizedBox(width: 10),
                Text('Upgrade Plan', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ]),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'signout',
              child: Row(children: [
                PhosphorIcon(PhosphorIconsRegular.signOut, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 10),
                Text('Sign Out', style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
          ],
          onSelected: (value) {
            if (value == 'signout') _signOut();
            if (value == 'pricing') context.push('/pricing');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Search historical events...',
          prefixIcon: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass, size: 20, color: AppTheme.textTertiary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: PhosphorIcon(PhosphorIconsRegular.x, size: 18, color: AppTheme.textTertiary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCustomEventBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          // Upgrade banner
          InkWell(
            onTap: () => context.push('/pricing'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  PhosphorIcon(PhosphorIconsRegular.graduationCap, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unlock Scholar plan',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'DeepSeek R1 · 8 perspectives · Export PDF',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  PhosphorIcon(PhosphorIconsRegular.caretRight, size: 12, color: Colors.white),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 10),
          // Custom event banner
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
              child: Row(
                children: [
                  PhosphorIcon(PhosphorIconsRegular.plusCircle, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore any event',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primary),
                        ),
                        Text(
                          'Type a custom historical event or topic',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                  PhosphorIcon(PhosphorIconsRegular.caretRight, size: 14, color: AppTheme.primary),
                ],
              ),
            ),
          ).animate(delay: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildEventGrid() {
    final events = _filteredEvents;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('No events found', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _searchQuery.isEmpty
                  ? 'Featured Events'
                  : '${events.length} result${events.length == 1 ? '' : 's'}',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: events[index],
                  onTap: () => _onEventTap(events[index]),
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final HistoricalEvent event;
  final VoidCallback onTap;
  final int index;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.index,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _hovered = false;

  static const List<List<Color>> _gradients = [
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFFFDA085), Color(0xFFF6D365)],
    [Color(0xFF0F2027), Color(0xFF2C5364)],
    [Color(0xFFFF6A00), Color(0xFFEE0979)],
    [Color(0xFF1A1A2E), Color(0xFF16213E)],
    [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    [Color(0xFFCC2B5E), Color(0xFF753A88)],
    [Color(0xFF56AB2F), Color(0xFFA8E063)],
    [Color(0xFFB06AB3), Color(0xFF4568DC)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[widget.index % _gradients.length];

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.diagonal3Values(
            _hovered ? 1.02 : 1.0,
            _hovered ? 1.02 : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: _hovered ? 0.3 : 0.15),
                blurRadius: _hovered ? 20 : 10,
                offset: Offset(0, _hovered ? 6 : 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.event.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.event.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: widget.index * 60))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
      ),
    );
  }
}

class _CustomEventDialog extends StatelessWidget {
  final _controller = TextEditingController();

  _CustomEventDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Text('Explore any event', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Enter any historical event, person, or topic',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'e.g., Silk Road Trade, Genghis Khan...',
          prefixIcon: Icon(Icons.history_edu_outlined, size: 20),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) Navigator.pop(context, text);
          },
          child: const Text('Explore'),
        ),
      ],
    );
  }
}
