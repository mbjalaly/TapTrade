import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Services/TutorialService/tutorialService.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'dart:math' as math;

class IntroTutorialScreen extends StatelessWidget {
  const IntroTutorialScreen({Key? key}) : super(key: key);

  void _onDone(BuildContext context) async {
    // Mark tutorial as seen
    await TutorialService.markAsSeen();

    // Navigate to main app
    Get.offAll(() => const BottomNavigationScreen());
  }

  void _onSkip(BuildContext context) {
    // Same as done - user chose to skip
    _onDone(context);
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        // Slide 1: Welcome
        PageViewModel(
          title: AppLocalizations.of(context)?.welcomeToTapTradeExclaim ?? "Welcome to TapTrade!",
          body: AppLocalizations.of(context)?.easiestWayToSwap ?? "The easiest way to swap items with people nearby. Trade what you have for what you want!",
          image: _buildImage('assets/images/icon2.png'),
          decoration: _getPageDecoration(context),
        ),

        // Slide 2: Swipe to Discover (Animated)
        PageViewModel(
          title: AppLocalizations.of(context)?.swipeToDiscover ?? "Swipe to Discover",
          body: AppLocalizations.of(context)?.swipeToDiscoverDesc ?? "Swipe right on items you want to trade for. Swipe left to pass. Match with users who want your items!",
          image: const AnimatedSwipeDemo(),
          decoration: _getPageDecoration(context),
        ),

        // Slide 3: List Your Items
        PageViewModel(
          title: AppLocalizations.of(context)?.listYourItems ?? "List Your Items",
          body: AppLocalizations.of(context)?.listYourItemsDesc ?? "Add photos and details of items you want to trade. More listings mean more matches!",
          image: _buildUploadAnimation(),
          decoration: _getPageDecoration(context),
        ),

        // Slide 4: Chat & Trade
        PageViewModel(
          title: AppLocalizations.of(context)?.chatAndTrade ?? "Chat & Trade",
          body: AppLocalizations.of(context)?.chatAndTradeDesc ?? "When you match, chat with traders to arrange your swap. Safe, local trading made easy!",
          image: _buildChatAnimation(),
          decoration: _getPageDecoration(context),
        ),

        // Slide 5: Get Started
        PageViewModel(
          title: AppLocalizations.of(context)?.youreAllSet ?? "You're All Set!",
          body: AppLocalizations.of(context)?.youreAllSetDesc ?? "Start swiping, listing items, and connecting with traders near you. Happy trading!",
          image: _buildLottieAnimation('assets/animation/celebration.json'),
          decoration: _getPageDecoration(context),
        ),
      ],
      onDone: () => _onDone(context),
      onSkip: () => _onSkip(context),
      showSkipButton: true,
      skip: Text(
        AppLocalizations.of(context)?.skip ?? 'Skip',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText(context),
        ),
      ),
      next: Icon(Icons.arrow_forward, color: AppColors.primaryColor),
      done: Text(
        AppLocalizations.of(context)?.getStarted ?? 'Get Started',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: AppColors.primaryColor,
        color: AppColors.outlineColor(context),
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  Widget _buildImage(String assetName) {
    return Center(
      child: Image.asset(
        assetName,
        width: 400,
        height: 400,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildUploadAnimation() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing circle background
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.1),
                    ),
                  ),
                );
              },
              onEnd: () {},
            ),
            // Plus icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatAnimation() {
    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Chat bubbles with staggered animation
            Positioned(
              left: 20,
              top: 80,
              child: _AnimatedChatBubble(
                delay: 0,
                isLeft: true,
              ),
            ),
            Positioned(
              right: 20,
              top: 120,
              child: _AnimatedChatBubble(
                delay: 500,
                isLeft: false,
              ),
            ),
            Positioned(
              left: 20,
              top: 160,
              child: _AnimatedChatBubble(
                delay: 1000,
                isLeft: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLottieAnimation(String assetName) {
    return Center(
      child: Lottie.asset(
        assetName,
        width: 250,
        height: 250,
        fit: BoxFit.contain,
      ),
    );
  }

  PageDecoration _getPageDecoration(BuildContext context) {
    return PageDecoration(
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText(context),
      ),
      bodyTextStyle: GoogleFonts.poppins(
        fontSize: 16.0,
        color: AppColors.secondaryText(context),
        height: 1.5,
      ),
      imagePadding: const EdgeInsets.only(top: 40),
      pageColor: AppColors.pageBg(context),
      contentMargin: const EdgeInsets.symmetric(horizontal: 16),
      titlePadding: const EdgeInsets.only(top: 16, bottom: 12),
    );
  }
}

// Animated Swipe Demo Widget
class AnimatedSwipeDemo extends StatefulWidget {
  const AnimatedSwipeDemo({Key? key}) : super(key: key);

  @override
  State<AnimatedSwipeDemo> createState() => _AnimatedSwipeDemoState();
}

class _AnimatedSwipeDemoState extends State<AnimatedSwipeDemo>
    with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  int _currentDirection = 0; // 0 = center, 1 = right, -1 = left
  int _cardIndex = 0;

  final List<Map<String, dynamic>> _demoCards = [
    {'icon': Icons.watch, 'label': 'Smart Watch', 'color': Color(0xFF6366F1)},
    {'icon': Icons.headphones, 'label': 'Headphones', 'color': Color(0xFFEC4899)},
    {'icon': Icons.camera_alt, 'label': 'Camera', 'color': Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();

    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.5, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_fadeController);

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    while (mounted) {
      // Swipe right
      setState(() => _currentDirection = 1);
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(2.5, 0),
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeInOut,
      ));
      _rotationAnimation = Tween<double>(
        begin: 0,
        end: 0.2,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeInOut,
      ));

      await _swipeController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 500));

      // Reset and change card
      setState(() {
        _cardIndex = (_cardIndex + 1) % _demoCards.length;
        _currentDirection = 0;
      });
      _swipeController.reset();

      await Future.delayed(const Duration(milliseconds: 800));

      // Swipe left
      setState(() => _currentDirection = -1);
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-2.5, 0),
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeInOut,
      ));
      _rotationAnimation = Tween<double>(
        begin: 0,
        end: -0.2,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeInOut,
      ));

      await _swipeController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 500));

      // Reset and change card
      setState(() {
        _cardIndex = (_cardIndex + 1) % _demoCards.length;
        _currentDirection = 0;
      });
      _swipeController.reset();

      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _demoCards[_cardIndex];

    return Center(
      child: SizedBox(
        width: 320,
        height: 350,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left indicator (Pass)
            Positioned(
              left: 0,
              child: AnimatedOpacity(
                opacity: _currentDirection == -1 ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentDirection == -1
                            ? AppColors.errorColor
                            : AppColors.errorColor.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.errorColor,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 40,
                        color: _currentDirection == -1
                            ? Colors.white
                            : AppColors.errorColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PASS',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.errorColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right indicator (Like)
            Positioned(
              right: 0,
              child: AnimatedOpacity(
                opacity: _currentDirection == 1 ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentDirection == 1
                            ? AppColors.successColor
                            : AppColors.successColor.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.successColor,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 35,
                        color: _currentDirection == 1
                            ? Colors.white
                            : AppColors.successColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'LIKE',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.successColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Animated card
            AnimatedBuilder(
              animation: _swipeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _slideAnimation.value.dx * 100,
                    _slideAnimation.value.dy * 100,
                  ),
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.contentBg(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.outlineColor(context),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Card content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  currentCard['color'],
                                  currentCard['color'].withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Icon(
                              currentCard['icon'],
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            currentCard['label'],
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Like overlay
                    if (_currentDirection == 1)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: AppColors.successColor.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.successColor,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'LIKE',
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.successColor,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Pass overlay
                    if (_currentDirection == -1)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: AppColors.errorColor.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: 0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.errorColor,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'PASS',
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.errorColor,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
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
}

// Animated Chat Bubble Widget
class _AnimatedChatBubble extends StatefulWidget {
  final int delay;
  final bool isLeft;

  const _AnimatedChatBubble({
    required this.delay,
    required this.isLeft,
  });

  @override
  State<_AnimatedChatBubble> createState() => _AnimatedChatBubbleState();
}

class _AnimatedChatBubbleState extends State<_AnimatedChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: widget.delay));
      await _controller.forward();
      await Future.delayed(const Duration(milliseconds: 2000));
      await _controller.reverse();
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isLeft
                    ? AppColors.surfaceVariantColor(context)
                    : AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: widget.isLeft
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                  bottomRight: widget.isLeft
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isLeft
                          ? AppColors.greyText(context)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isLeft
                          ? AppColors.greyText(context)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isLeft
                          ? AppColors.greyText(context)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
