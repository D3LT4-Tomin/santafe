import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/tomy_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';

class TomyChatScreen extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onBack;
  final bool isOverlay;
  const TomyChatScreen({
    super.key,
    required this.scrollController,
    required this.onBack,
    this.isOverlay = false,
  });

  @override
  State<TomyChatScreen> createState() => _TomyChatScreenState();
}

class _TomyChatScreenState extends State<TomyChatScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  TomyProvider? _tomyProvider;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _initialized = false;

  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  @override
  void initState() {
    super.initState();
    _blob1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
    _blob2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
    _blob1Anim = CurvedAnimation(
      parent: _blob1Controller,
      curve: Curves.easeInOut,
    );
    _blob2Anim = CurvedAnimation(
      parent: _blob2Controller,
      curve: Curves.easeInOut,
    );

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appearAnim = CurvedAnimation(
      parent: _appearController,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _appearController.forward();

    // For overlay mode, initialize immediately to prevent loading delay
    if (widget.isOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final userId = context.read<AuthProvider>().user?.id ?? '';
        _tomyProvider = TomyProvider(userId: userId);
        await _tomyProvider!.loadHistory();
        if (mounted) setState(() => _initialized = true);
      });
    } else {
      // For regular screen mode, initialize after frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _initProvider());
    }
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
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _appearController.dispose();
    super.dispose();
  }

  void _goBack() {
    FocusScope.of(context).unfocus();
    widget.onBack();
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
    super.build(context);
    if (!_initialized || _tomyProvider == null) {
      // Show transparent background for overlay mode, colored for regular mode
      if (widget.isOverlay) {
        return const ColoredBox(
          color: Colors.transparent,
          child: Center(child: CupertinoActivityIndicator()),
        );
      } else {
        return const ColoredBox(
          color: AppColors.systemBackground,
          child: Center(child: CupertinoActivityIndicator()),
        );
      }
    }

    // For overlay mode, return a transparent container
    if (widget.isOverlay) {
      return Container(
        color: Colors.transparent,
        child: ListenableBuilder(
          listenable: _tomyProvider!,
          builder: (context, _) => _buildBody(context),
        ),
      );
    } else {
      return ListenableBuilder(
        listenable: _tomyProvider!,
        builder: (context, _) => _buildBody(context),
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Only show background blobs if NOT in overlay mode
        if (!widget.isOverlay)
          RepaintBoundary(
            child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
          ),
        // Chat content with fade and slide animation
        Positioned.fill(
          child: FadeTransition(
            opacity: _appearAnim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(_appearAnim),
              child: Column(
                children: [
                  // Custom header
                  Padding(
                    padding: EdgeInsets.only(
                      top: topPadding + 10,
                      bottom: 10,
                      left: 16,
                      right: 16,
                    ),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _goBack,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: const Icon(
                              CupertinoIcons.back,
                              color: AppColors.systemGreen,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tomy',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.label,
                            letterSpacing: -0.41,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildMessageList()),
                  _buildInputBar(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    final messages = _tomyProvider!.messages;
    final isLoading = _tomyProvider!.isLoading;

    if (messages.isEmpty && !isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.legacyBlue, AppColors.legacyBlueLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.systemGreen.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.chat_bubble_2_fill,
                  size: 36,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Habla con Tomy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu asistente financiero personal',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryLabel,
                  height: 1.33,
                  letterSpacing: -0.24,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLoading && index == messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(messages[index]);
      },
    );
  }

  Widget _buildInputBar() {
    final isLoading = _tomyProvider!.isLoading;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.black07),
                ),
                child: CupertinoTextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  placeholder: 'Pregunta a Tomy...',
                  placeholderStyle: const TextStyle(
                    color: AppColors.tertiaryLabel,
                    fontSize: 15,
                    letterSpacing: -0.24,
                    height: 1.33,
                  ),
                  style: const TextStyle(
                    color: AppColors.label,
                    fontSize: 15,
                    letterSpacing: -0.24,
                    height: 1.33,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isLoading ? null : _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLoading
                      ? AppColors.tertiaryBackground
                      : AppColors.systemGreen,
                  shape: BoxShape.circle,
                  boxShadow: isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.systemGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Icon(
                  CupertinoIcons.arrow_up,
                  color: isLoading
                      ? AppColors.tertiaryLabel
                      : CupertinoColors.white,
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
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.legacyBlue, AppColors.legacyBlueLight],
                ),
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                color: CupertinoColors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.systemGreen
                    : AppColors.cardBackground.withValues(
                        alpha: 0.6,
                      ), // Reduced opacity for assistant bubbles
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                  bottomLeft: !isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                border: isUser ? null : Border.all(color: AppColors.black07),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isUser ? CupertinoColors.white : AppColors.label,
                  height: 1.3,
                  letterSpacing: -0.24,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.legacyBlue, AppColors.legacyBlueLight],
                ),
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                color: CupertinoColors.white,
                size: 16,
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
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.legacyBlue, AppColors.legacyBlueLight],
              ),
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              color: CupertinoColors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(
                alpha: 0.6,
              ), // Match assistant bubble opacity
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.black07),
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
