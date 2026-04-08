import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../services/app_api_service.dart';

class ChatOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const ChatOverlay({super.key, required this.onClose});

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final TextEditingController _textController = TextEditingController();

  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          '¡Hola! Soy tu asistente financiero. ¿En qué te puedo ayudar hoy?',
      'time': 'Ahora',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final data = context.read<DataProvider>();
    final transactions = data.transactions;

    final currentUserData = context.read<DataProvider>();

    setState(() {
      _messages.add({'isUser': true, 'text': text, 'time': 'Ahora'});
      _textController.clear();
      _isLoading = true;
    });

    try {
      final response = await AppApiService.chatWithContext(
        currentUserData,
        text,
        transactions: transactions,
      );

      if (mounted && response != null) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': response['response'],
            'time': 'Ahora',
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text':
                'Hubo un error al procesar tu solicitud. Inténtalo de nuevo.',
            'time': 'Ahora',
          });
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 300) {
              _animController.reverse().then((_) => widget.onClose());
            }
          },
          child: Column(
            children: [
              // Chat Header with Back Button — sits right at the top
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _animController.reverse().then((_) => widget.onClose());
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.white05,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white10),
                        ),
                        child: const Icon(
                          CupertinoIcons.back,
                          color: AppColors.label,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Asistente Financiero',
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
              // Messages — starts at top, fills down
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    reverse: false,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _ChatBubble(
                        text: msg['text'],
                        isUser: msg['isUser'],
                        time: msg['time'],
                      );
                    },
                  ),
                ),
              ),

              // Input area
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.systemBackground.withValues(alpha: 0.95),
                  border: const Border(
                    top: BorderSide(color: AppColors.white07, width: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _textController,
                        placeholder: 'Pregúntale a tu asistente...',
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        style: const TextStyle(
                          color: AppColors.label,
                          fontSize: 16,
                        ),
                        placeholderStyle: const TextStyle(
                          color: AppColors.secondaryLabel,
                          fontSize: 16,
                        ),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        decoration: BoxDecoration(
                          color: AppColors.white05,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.white10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _sendMessage,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.systemBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.systemBlue.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.arrow_up,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String time;

  const _ChatBubble({
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.systemBlue
                  : AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(20),
                bottomLeft: !isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(20),
              ),
              border: isUser ? null : Border.all(color: AppColors.white07),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isUser ? Colors.white : AppColors.label,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
