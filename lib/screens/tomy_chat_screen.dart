import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/tomy_provider.dart';
import '../theme/app_theme.dart';

class TomyChatScreen extends StatefulWidget {
  final ScrollController scrollController;
  const TomyChatScreen({super.key, required this.scrollController});

  @override
  State<TomyChatScreen> createState() => _TomyChatScreenState();
}

class _TomyChatScreenState extends State<TomyChatScreen> {
  TomyProvider? _tomyProvider;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initProvider());
  }

  Future<void> _initProvider() async {
    if (!mounted) return;
    final userId = context.read<AuthProvider>().user?.id ?? '';
    _tomyProvider = TomyProvider(userId: userId);
    await _tomyProvider!.loadHistory();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _tomyProvider == null) return;
    _textController.clear();
    _tomyProvider!.sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _tomyProvider == null) {
      return const ColoredBox(
        color: AppColors.systemBackground,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return ListenableBuilder(
      listenable: _tomyProvider!,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;
    final tabBarHeight = bottomPadding + 65.0;

    return ColoredBox(
      color: AppColors.systemBackground,
      child: Column(
        children: [
          Expanded(child: _buildMessageList(bottomPadding)),
          _buildInputBar(bottomInset, bottomPadding),
        ],
      ),
    );
  }

  Widget _buildMessageList(double bottomPadding) {
    final messages = _tomyProvider!.messages;
    final isLoading = _tomyProvider!.isLoading;

    if (messages.isEmpty && !isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.chat_bubble_2_fill,
                size: 64,
                color: AppColors.systemBlue.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 24),
              Text(
                'Habla con Tomy',
                style: AppTextStyles.title2.copyWith(color: AppColors.label),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tu asistente financiero personal',
                style: AppTextStyles.subheadline.copyWith(
                  color: AppColors.secondaryLabel,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.only(left: 16, right: 16, top: 90, bottom: 12),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLoading && index == messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(messages[index]);
      },
    );
  }

  Widget _buildInputBar(double bottomInset, double bottomPadding) {
    final isLoading = _tomyProvider!.isLoading;
    final tabBarHeight = 65.0;
    final extraPadding = bottomPadding > 0
        ? bottomPadding + tabBarHeight
        : tabBarHeight;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        border: Border(top: BorderSide(color: AppColors.white07, width: 0.5)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + extraPadding,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: CupertinoTextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  placeholder: 'Pregunta a Tomy...',
                  placeholderStyle: AppTextStyles.body.copyWith(
                    color: AppColors.tertiaryLabel,
                  ),
                  style: AppTextStyles.body.copyWith(color: AppColors.label),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(),
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isLoading ? null : _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLoading
                      ? AppColors.tertiaryBackground
                      : AppColors.systemBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.arrow_up,
                  color: AppColors.label,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.systemBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                color: CupertinoColors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.systemBlue
                    : AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: AppTextStyles.body.copyWith(color: AppColors.label),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.secondaryBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                color: AppColors.secondaryLabel,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.systemBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              color: CupertinoColors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.secondaryLabel.withValues(
              alpha: 0.3 + (0.7 * (value < 0.5 ? value * 2 : 2 - (value * 2))),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
