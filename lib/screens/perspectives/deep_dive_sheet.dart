import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/app_models.dart';
import '../../models/perspective.dart';
import '../../services/groq_service.dart';

class DeepDiveSheet extends StatefulWidget {
  final String eventTitle;
  final Perspective perspective;

  const DeepDiveSheet({super.key, required this.eventTitle, required this.perspective});

  @override
  State<DeepDiveSheet> createState() => _DeepDiveSheetState();
}

class _DeepDiveSheetState extends State<DeepDiveSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _groqService = GroqService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  static const _starters = [
    'Why did they view it this way?',
    'What was the long-term impact?',
    'How did ordinary people experience this?',
    'Were there any dissenting voices?',
  ];

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    _controller.clear();
    final userMsg = ChatMessage(role: 'user', content: text.trim(), timestamp: DateTime.now());
    setState(() { _messages.add(userMsg); _isLoading = true; });
    _scrollToBottom();

    try {
      final reply = await _groqService.chatWithPerspective(
        eventTitle: widget.eventTitle,
        perspectiveLabel: widget.perspective.label,
        perspectiveContent: widget.perspective.content,
        messages: _messages,
      );
      final aiMsg = ChatMessage(role: 'assistant', content: reply, timestamp: DateTime.now());
      if (mounted) setState(() { _messages.add(aiMsg); _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _groqService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              _buildHandle(colors),
              _buildHeader(colors),
              Expanded(child: _buildMessages(colors, scroll)),
              if (_messages.isEmpty) _buildStarters(),
              _buildInput(colors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(AppColors colors) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40, height: 4,
        decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          PhosphorIcon(PhosphorIconsRegular.chatDots, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ask AI', style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary, fontSize: 16)),
              Text('${widget.perspective.label} perspective', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(AppColors colors, ScrollController scroll) {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(PhosphorIconsRegular.chatDots, size: 40, color: colors.textTertiary),
            const SizedBox(height: 12),
            Text('Ask anything about this perspective', style: TextStyle(color: colors.textTertiary, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _messages.length) return _ThinkingBubble(colors: colors);
        return _ChatBubble(message: _messages[i], colors: colors);
      },
    );
  }

  Widget _buildStarters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: _starters.map((q) => GestureDetector(
          onTap: () => _send(q),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(q, style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInput(AppColors colors) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: _send,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Ask about this perspective...',
                  prefixIcon: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass, size: 18, color: colors.textTertiary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _send(_controller.text),
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                child: Center(child: PhosphorIcon(PhosphorIconsRegular.arrowRight, color: Colors.white, size: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final AppColors colors;
  const _ChatBubble({required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isUser ? Colors.white : colors.textPrimary, fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  final AppColors colors;
  const _ThinkingBubble({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) =>
            Container(
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              width: 7, height: 7,
              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
            ).animate(onPlay: (c) => c.repeat()).fadeIn(delay: Duration(milliseconds: i * 200), duration: 400.ms).then().fadeOut(duration: 400.ms),
          ),
        ),
      ),
    );
  }
}
