import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Models/ChatModels/matchModel.dart';
import 'package:taptrade/Models/ChatModels/messageModel.dart';
import 'package:taptrade/Services/IntegrationServices/chatService.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
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

  String? _tradeRequestStatus;
  bool _iMarkedComplete = false;
  bool _hasOfferedDeletion = false;

  @override
  void initState() {
    super.initState();
    _tradeRequestStatus = widget.match.tradeRequestStatus;
    if (_tradeRequestStatus == 'completed') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferDeletion());
    }
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
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
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: AppColors.backgroundColor(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryText(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceVariantColor(context),
            child: Text(
              (widget.match.otherUser?.username ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.match.otherUser?.username ?? 'User',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: _buildTradeActionButton(l10n),
        ),
      ],
    );
  }

  /// Show dialog to mark trade as complete
  Future<void> _showMarkCompleteDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markTradeComplete),
        content: Text(
          l10n.haveYouCompletedTrade(widget.match.otherUser?.username ?? 'the other user'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(l10n.yesMarkComplete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Use the trade request ID from the match model
      final result = await ProductService.instance.markTradeCompleteByMatchId(
        context,
        widget.match.id!,
      );

      if (mounted) Navigator.pop(context); // Close loading

      if (result.status == Status.COMPLETED) {
        if (mounted) {
          setState(() {
            _tradeRequestStatus = 'pending_confirmation';
            _iMarkedComplete = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.tradeMarkedWaiting),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)?.errorPrefix ?? "Error: "}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Build the correct trade action button based on current status
  void _maybeOfferDeletion() {
    if (!mounted || _hasOfferedDeletion) return;
    setState(() => _hasOfferedDeletion = true);
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _maybeOfferDeletion(); });
  }

  Future<void> _offerProductDeletion() async {
    if (!mounted) return;
    final myProductId = widget.match.myProduct?.id;
    if (myProductId == null) return;

    // Ask the user whether to remove their traded product from listings
    final delete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Trade Complete!'),
        content: Text(
          'Would you like to remove "${widget.match.myProduct?.title}" from your listings now that the trade is done?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep It'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (delete != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ProductService.instance.deleteMyProduct(context, myProductId.toString());
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product removed from listings.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Close the chat
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _buildTradeActionButton(dynamic l10n) {
    if (_tradeRequestStatus == 'completed') {
      if (!_hasOfferedDeletion) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferDeletion());
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text('Done', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      );
    }

    if (_tradeRequestStatus == 'pending_confirmation') {
      if (_iMarkedComplete) {
        // I already marked it — waiting for the other user
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 6),
              Text('Waiting...', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        );
      } else {
        // Other user marked it — I need to confirm
        return ElevatedButton.icon(
          onPressed: _showConfirmTradeDialog,
          icon: const Icon(Icons.handshake_outlined, size: 18),
          label: const Text('Confirm Trade', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      }
    }

    // Default: green Complete button
    return ElevatedButton.icon(
      onPressed: _showMarkCompleteDialog,
      icon: const Icon(Icons.check_circle_outline, size: 18),
      label: Text(l10n.complete, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Confirm the trade after the other user has marked it complete
  Future<void> _showConfirmTradeDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Trade Completion'),
        content: Text(
          'The other party has marked this trade as complete. '
          'Do you confirm that the trade with ${widget.match.otherUser?.username ?? "the other user"} has been completed successfully?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Yes, Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Use known tradeRequestId or fall back to match-based lookup
      int tradeRequestId = widget.match.tradeRequestId ?? 0;
      if (tradeRequestId == 0) {
        // Fallback: look up via markTradeCompleteByMatchId which handles the lookup
        final lookupResult = await ProductService.instance.markTradeCompleteByMatchId(
          context,
          widget.match.id!,
        );
        // After lookup+mark, the trade is now pending_confirmation from our side — done
        if (mounted) Navigator.pop(context);
        if (lookupResult.status == Status.COMPLETED) {
          if (mounted) {
            setState(() => _tradeRequestStatus = 'completed');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trade completed successfully!'), backgroundColor: Colors.green),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferDeletion());
          }
        }
        return;
      }
      final result = await ProductService.instance.confirmTradeComplete(
        context,
        tradeRequestId,
      );

      if (mounted) Navigator.pop(context);

      if (result.status == Status.COMPLETED) {
        if (mounted) {
          setState(() => _tradeRequestStatus = 'completed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trade completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferDeletion());
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildProductInfoHeader(Size size) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantColor(context),
        border: Border(
          bottom: BorderSide(color: AppColors.outlineColor(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          // My product
          _buildMiniProductCard(
            widget.match.myProduct?.image ?? '',
            widget.match.myProduct?.title ?? l10n.yourProduct,
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
            widget.match.theirProduct?.title ?? l10n.theirProduct,
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
          color: AppColors.contentBg(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineColor(context)),
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
                          color: AppColors.surfaceVariantColor(context),
                          child: Icon(
                            Icons.image,
                            color: AppColors.greyText(context),
                            size: size.width * 0.06,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceVariantColor(context),
                        child: Icon(
                          Icons.shopping_bag,
                          color: AppColors.greyText(context),
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: size.width * 0.15,
            color: AppColors.greyText(context),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            l10n.startTheConversation,
            style: TextStyle(
              fontSize: size.width * 0.045,
              color: AppColors.greyText(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            l10n.sayHelloAndDiscuss,
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: AppColors.greyText(context),
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
          color: isMe ? AppColors.primaryColor : AppColors.surfaceVariantColor(context),
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
                color: isMe ? Colors.white : AppColors.textOnBg(context),
                fontSize: size.width * 0.038,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              _formatTime(message.sentAt),
              style: TextStyle(
                color: isMe
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.greyText(context),
                fontSize: size.width * 0.028,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(Size size) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.contentBg(context),
        border: Border(
          top: BorderSide(color: AppColors.outlineColor(context), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantColor(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: l10n.typeMessage,
                    hintStyle: TextStyle(
                      color: AppColors.greyText(context),
                      fontSize: size.width * 0.038,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 0,
                    ),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  minLines: 1,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: size.width * 0.038,
                    height: 1.4,
                  ),
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
