import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/app_models.dart';
import '../../services/bookmark_service.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<BookmarkedPerspective> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = context.read<BookmarkService>();
    final data = await service.getAll();
    if (mounted) setState(() { _bookmarks = data; _isLoading = false; });
  }

  Future<void> _remove(BookmarkedPerspective item) async {
    await context.read<BookmarkService>().remove(item.id);
    setState(() => _bookmarks.removeWhere((b) => b.id == item.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bookmark removed'),
          action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
        ),
      );
    }
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
        title: const Text('Saved Perspectives'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? _buildEmpty(colors)
              : _buildList(colors),
    );
  }

  Widget _buildEmpty(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(PhosphorIconsRegular.bookmarks, size: 56, color: colors.textTertiary),
          const SizedBox(height: 16),
          Text('No saved perspectives yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Tap the bookmark icon on any perspective card to save it here.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildList(AppColors colors) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _bookmarks[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, color: Colors.white),
                SizedBox(height: 4),
                Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
          onDismissed: (_) => _remove(item),
          child: _BookmarkCard(item: item, colors: colors, index: index),
        );
      },
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final BookmarkedPerspective item;
  final AppColors colors;
  final int index;

  const _BookmarkCard({required this.item, required this.colors, required this.index});

  @override
  Widget build(BuildContext context) {
    final gradient = AppTheme.perspectiveGradients;
    final cardColor = gradient[index % gradient.length];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardColor, cardColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Text(item.eventEmoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.eventTitle, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text(item.perspectiveType, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                    ],
                  ),
                ),
                Text(item.perspectiveEmoji, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.perspectiveLabel, style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(item.perspectiveTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  item.perspectiveContent.length > 200
                      ? '${item.perspectiveContent.substring(0, 200)}...'
                      : item.perspectiveContent,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 50)).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
