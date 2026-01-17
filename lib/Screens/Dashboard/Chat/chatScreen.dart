import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Models/ChatModels/matchModel.dart';
import 'package:taptrade/Models/ChatModels/messageModel.dart';
import 'package:taptrade/Services/IntegrationServices/chatService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/appColors.dart';

/// Chat screen for messaging within a match
class ChatScreen extends StatefulWidget {
  final MatchModel match;

  const ChatScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];

  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    _currentUserId = await SharedPreferencesService().getString(KeyConstants.userId);
    await _loadMessages();
    _markAsRead();

    // Poll for new messages every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadMessages(showLoading: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    final response = await ChatService.getMessages(
      context: context,
      matchId: widget.match.id!,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response?.messages != null) {
          _messages.clear();
          _messages.addAll(response!.messages!);
        }
      });

      // Scroll to bottom after loading
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _markAsRead() async {
    await ChatService.markMessagesAsRead(
      context: context,
      matchId: widget.match.id!,
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    // Determine receiver ID
    final receiverId = _currentUserId == widget.match.user1Id
        ? widget.match.user2Id
        : widget.match.user1Id;

    final response = await ChatService.sendMessage(
      context: context,
      matchId: widget.match.id!,
      receiverId: receiverId!,
      messageText: text,
    );

    if (mounted) {
      setState(() => _isSending = false);

      if (response?.success == true && response?.sentMessage != null) {
        setState(() {
          _messages.add(response!.sentMessage!);
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(size),
      body: Column(
        children: [
          // Product info header
          _buildProductInfoHeader(size),

          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState(size)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.02,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(
                            _messages[index],
                            size,
                          );
                        },
                      ),
          ),

          // Message input
          _buildMessageInput(size),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Size size) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryTextColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceVariant,
            child: Text(
              (widget.match.otherUser?.username ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.match.otherUser?.username ?? 'User',
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoHeader(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          bottom: BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      child: Row(
        children: [
          // My product
          _buildMiniProductCard(
            widget.match.myProduct?.image ?? '',
            widget.match.myProduct?.title ?? 'Your product',
            size,
          ),

          // Trade arrow
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Icon(
              Icons.swap_horiz,
              color: AppColors.primaryColor,
              size: size.width * 0.08,
            ),
          ),

          // Their product
          _buildMiniProductCard(
            widget.match.theirProduct?.image ?? '',
            widget.match.theirProduct?.title ?? 'Their product',
            size,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniProductCard(String imageUrl, String title, Size size) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(size.width * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: size.width * 0.12,
                height: size.width * 0.12,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.image,
                            color: AppColors.greyTextColor,
                            size: size.width * 0.06,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.shopping_bag,
                          color: AppColors.greyTextColor,
                          size: size.width * 0.06,
                        ),
                      ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: size.width * 0.028,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: size.width * 0.15,
            color: AppColors.greyTextColor,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'Start the conversation!',
            style: TextStyle(
              fontSize: size.width * 0.045,
              color: AppColors.greyTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'Say hello and discuss your trade.',
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: AppColors.greyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, Size size) {
    final isMe = message.isSentByMe(_currentUserId ?? '');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: size.height * 0.01,
          left: isMe ? size.width * 0.15 : 0,
          right: isMe ? 0 : size.width * 0.15,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.012,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.messageText ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.blackTextColor,
                fontSize: size.width * 0.038,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              _formatTime(message.sentAt),
              style: TextStyle(
                color: isMe
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.greyTextColor,
                fontSize: size.width * 0.028,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppColors.greyTextColor,
                      fontSize: size.width * 0.038,
                    ),
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: size.width * 0.12,
                height: size.width * 0.12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E3DF), Color(0xFFF2B721)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${time.day}/${time.month}/${time.year}';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
