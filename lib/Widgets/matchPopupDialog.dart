import 'package:flutter/material.dart';
import 'package:taptrade/Models/ChatModels/matchModel.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customButtom.dart';

/// Animated "It's a Match!" popup that appears when two users mutually like each other
class MatchPopupDialog extends StatefulWidget {
  final MatchModel match;
  final VoidCallback onSendMessage;
  final VoidCallback onKeepSwiping;

  const MatchPopupDialog({
    Key? key,
    required this.match,
    required this.onSendMessage,
    required this.onKeepSwiping,
  }) : super(key: key);

  /// Show the match popup as a fullscreen dialog
  static Future<void> show({
    required BuildContext context,
    required MatchModel match,
    required VoidCallback onSendMessage,
    required VoidCallback onKeepSwiping,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MatchPopupDialog(
          match: match,
          onSendMessage: onSendMessage,
          onKeepSwiping: onKeepSwiping,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  State<MatchPopupDialog> createState() => _MatchPopupDialogState();
}

class _MatchPopupDialogState extends State<MatchPopupDialog>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _cardsController;
  late AnimationController _buttonsController;

  late Animation<double> _titleScale;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _leftCardSlide;
  late Animation<Offset> _rightCardSlide;
  late Animation<double> _cardsOpacity;
  late Animation<double> _buttonsOpacity;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    // Title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _titleScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );

    // Cards animation
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _leftCardSlide = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardsController,
      curve: Curves.easeOutBack,
    ));
    _rightCardSlide = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardsController,
      curve: Curves.easeOutBack,
    ));
    _cardsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeIn),
    );

    // Buttons animation
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeIn),
    );
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOut,
    ));

    // Start animations in sequence
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardsController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cardsController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "It's a Match!" title
            AnimatedBuilder(
              animation: _titleController,
              builder: (context, child) {
                return Opacity(
                  opacity: _titleOpacity.value,
                  child: Transform.scale(
                    scale: _titleScale.value,
                    child: child,
                  ),
                );
              },
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00E3DF), Color(0xFFF2B721)],
                ).createShader(bounds),
                child: Text(
                  "It's a Match!",
                  style: TextStyle(
                    fontSize: size.width * 0.1,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Subtitle with other user's name
            AnimatedBuilder(
              animation: _titleController,
              builder: (context, child) {
                return Opacity(
                  opacity: _titleOpacity.value,
                  child: child,
                );
              },
              child: Text(
                'You and ${widget.match.otherUser?.username ?? 'someone'} liked each other!',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: size.height * 0.05),

            // Product cards
            SizedBox(
              height: size.height * 0.35,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // My product (left)
                  AnimatedBuilder(
                    animation: _cardsController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _cardsOpacity.value,
                        child: SlideTransition(
                          position: _leftCardSlide,
                          child: child,
                        ),
                      );
                    },
                    child: Positioned(
                      left: size.width * 0.05,
                      child: Transform.rotate(
                        angle: -0.15,
                        child: _buildProductCard(
                          size,
                          widget.match.myProduct?.image ?? '',
                          widget.match.myProduct?.title ?? 'Your product',
                          true,
                        ),
                      ),
                    ),
                  ),

                  // Their product (right)
                  AnimatedBuilder(
                    animation: _cardsController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _cardsOpacity.value,
                        child: SlideTransition(
                          position: _rightCardSlide,
                          child: child,
                        ),
                      );
                    },
                    child: Positioned(
                      right: size.width * 0.05,
                      child: Transform.rotate(
                        angle: 0.15,
                        child: _buildProductCard(
                          size,
                          widget.match.theirProduct?.image ?? '',
                          widget.match.theirProduct?.title ?? 'Their product',
                          false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.05),

            // Action buttons
            AnimatedBuilder(
              animation: _buttonsController,
              builder: (context, child) {
                return Opacity(
                  opacity: _buttonsOpacity.value,
                  child: SlideTransition(
                    position: _buttonsSlide,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: Column(
                  children: [
                    // Send message button
                    AppButton(
                      text: 'Send a Message',
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onSendMessage();
                      },
                      width: size.width * 0.8,
                    ),

                    SizedBox(height: size.height * 0.02),

                    // Keep swiping button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onKeepSwiping();
                      },
                      child: Text(
                        'Keep Swiping',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Size size, String imageUrl, String title, bool isMyProduct) {
    return Container(
      width: size.width * 0.4,
      height: size.height * 0.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Product image
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.image_not_supported,
                          size: size.width * 0.1,
                          color: AppColors.greyTextColor,
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.shopping_bag,
                      size: size.width * 0.1,
                      color: AppColors.greyTextColor,
                    ),
                  ),

            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.08,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Product title
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // "Yours" or "Theirs" label
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMyProduct
                      ? AppColors.primaryColor.withOpacity(0.9)
                      : AppColors.secondaryColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isMyProduct ? 'Yours' : 'Theirs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
