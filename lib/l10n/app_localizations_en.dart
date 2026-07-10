// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TapTrade';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get verifyPhone => 'Verify Phone';

  @override
  String get sendCode => 'Send Code';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendCodeIn(String seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get enterVerificationCode => 'Enter verification code';

  @override
  String get didntReceiveCode => 'Didn\'t receive the code?';

  @override
  String get verify => 'Verify';

  @override
  String get createNewPassword => 'Create New Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get username => 'Username';

  @override
  String get chooseUsername => 'Choose a username';

  @override
  String get usernameHint => 'This will be your unique identifier';

  @override
  String get createPassword => 'Create Password';

  @override
  String get passwordRequirements => 'Password must be at least 8 characters';

  @override
  String get home => 'Home';

  @override
  String get explore => 'Explore';

  @override
  String get matches => 'Matches';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get more => 'More';

  @override
  String get products => 'Products';

  @override
  String get bazaar => 'BAZAAR';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get swipeLeftToSkip => 'Swipe left to skip';

  @override
  String get swipeRightToLike => 'Swipe right to like';

  @override
  String get itsAMatch => 'It\'s a Match!';

  @override
  String youAndUserLikedEachOther(String username) {
    return 'You and $username liked each other\'s products';
  }

  @override
  String get sendMessage => 'Send Message';

  @override
  String get keepSwiping => 'Keep Swiping';

  @override
  String get noMoreProducts => 'No more products to show';

  @override
  String get tryAgainLater => 'Try again later';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get selectProductsToTrade => 'Select Products to Trade';

  @override
  String get noProductsAvailable => 'No products available';

  @override
  String get selectAll => 'Select All';

  @override
  String get clearAll => 'Clear All';

  @override
  String get closeProductSelector => 'Close product selector';

  @override
  String get selectProducts => 'Select products';

  @override
  String get searchFiltersTooltip => 'Search filters';

  @override
  String get noProductDataAvailable => 'No product data available';

  @override
  String get dealsNearYou => 'Deals near you';

  @override
  String swipeToExploreItems(int count) {
    return 'Swipe to explore $count items';
  }

  @override
  String get noNewProductsNearby => 'No new products nearby';

  @override
  String showingAlreadyLikedProducts(int count) {
    return 'Showing $count products you already liked';
  }

  @override
  String get addYourFirstProductShort => 'Add your first product';

  @override
  String get listProductsToStartTrading =>
      'List products to start trading with others nearby';

  @override
  String get noNearbyTrades => 'No nearby trades';

  @override
  String get tryIncreasingSearchRadius =>
      'Try increasing your search radius in preferences';

  @override
  String get allProductsFiltered => 'All products filtered';

  @override
  String get tryAdjustingFilters =>
      'Try adjusting your filters to see more trades';

  @override
  String get noMatchesYetShort => 'No matches yet';

  @override
  String get checkBackSoon => 'Check back soon for new trading opportunities';

  @override
  String get locationAccess => 'Location access';

  @override
  String get unableToAccessLocation =>
      'Unable to access your location. Products may not be accurate.';

  @override
  String get errorLoadingProducts => 'Error loading products';

  @override
  String get checkInternetConnection =>
      'Please check your internet connection and try again';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productTitle => 'Product Title';

  @override
  String get description => 'Description';

  @override
  String get minPrice => 'Min Price';

  @override
  String get maxPrice => 'Max Price';

  @override
  String get category => 'Category';

  @override
  String get condition => 'Condition';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityAvailable => 'Quantity Available';

  @override
  String get productDetails => 'Product Details';

  @override
  String get priceRange => 'Price Range';

  @override
  String get status => 'Status';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get selectCondition => 'Select Condition';

  @override
  String get productImages => 'Product Images';

  @override
  String get addImages => 'Add Images';

  @override
  String get editImages => 'Edit Images';

  @override
  String get myProducts => 'My Products';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get confirmDeleteProduct =>
      'Are you sure you want to delete this product?';

  @override
  String get productNew => 'New';

  @override
  String get productUsed => 'Used';

  @override
  String get productLikeNew => 'Like New';

  @override
  String get productGood => 'Good';

  @override
  String get productFair => 'Fair';

  @override
  String get backToSwipe => 'Back to Swipe';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get addYourFirstProductToGetStarted =>
      'Add your first product to get started';

  @override
  String get noActiveProducts => 'No active products';

  @override
  String youHaveProductsButNoneActive(int count) {
    return 'You have $count product(s) but none are active';
  }

  @override
  String get completedDeals => 'Completed Deals';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get areYouSureDeleteProduct => 'Are you sure you want to delete:';

  @override
  String get productDeletedSuccessfully => 'Product deleted successfully';

  @override
  String get failedToDeleteProduct => 'Failed to delete product';

  @override
  String get errorOccurred => 'An error occurred. Please try again.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get logout => 'Logout';

  @override
  String get logOut => 'Log out';

  @override
  String get logoutSuccessful => 'Logout successful';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get confirmDeleteAccount =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get bio => 'Bio';

  @override
  String get addBio => 'Add Bio';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get appVersion => 'App Version';

  @override
  String get tradePreferences => 'Trade preferences';

  @override
  String get tradeRadius => 'Trade Radius';

  @override
  String get meetingPreference => 'Meeting Preference';

  @override
  String get publicPlace => 'Public Place';

  @override
  String get doorstep => 'Doorstep';

  @override
  String get locationPicker => 'Location Picker';

  @override
  String get setYourLocation => 'Set Your Location';

  @override
  String get searchFilters => 'Search Filters';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get matchNotifications => 'Match Notifications';

  @override
  String get messageNotifications => 'Message Notifications';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get verifyPhoneNumber => 'Verify Phone Number';

  @override
  String get profileInformation => 'Profile information';

  @override
  String get matchesAndChat => 'Matches & Chat';

  @override
  String get faqQuestions => 'FAQ questions';

  @override
  String get termsAndPolicies => 'Terms and policies';

  @override
  String get viewTutorial => 'View tutorial';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get faqComingSoon => 'FAQ page is coming soon';

  @override
  String get account => 'Account';

  @override
  String get likedProducts => 'Liked Products';

  @override
  String get dislikedProducts => 'Disliked Products';

  @override
  String get tradeHistory => 'Trade History';

  @override
  String get pendingTrades => 'Pending Trades';

  @override
  String get completedTrades => 'Completed Trades';

  @override
  String get tradeRequest => 'Trade Request';

  @override
  String get sendTradeRequest => 'Send Trade Request';

  @override
  String get acceptTrade => 'Accept Trade';

  @override
  String get rejectTrade => 'Reject Trade';

  @override
  String get tradeSent => 'Trade request sent';

  @override
  String get tradeAccepted => 'Trade accepted';

  @override
  String get tradeRejected => 'Trade rejected';

  @override
  String get tradeCompleted => 'Trade completed';

  @override
  String get deals => 'Deals';

  @override
  String get noDeals => 'No deals yet';

  @override
  String get contactTrader => 'Contact Trader';

  @override
  String get messages => 'Messages';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get send => 'Send';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get typing => 'typing...';

  @override
  String get noMatchesYet => 'No matches yet';

  @override
  String get keepSwipingToFindMatches =>
      'Keep swiping to find people who want to trade with you!';

  @override
  String get matchWord => 'match';

  @override
  String get matchesWord => 'matches';

  @override
  String get product => 'Product';

  @override
  String get user => 'User';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get continue_ => 'Continue';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get view => 'View';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get refresh => 'Refresh';

  @override
  String get noResults => 'No results found';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get pleaseTryAgain => 'Please try again';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get checkYourConnection => 'Please check your internet connection';

  @override
  String get getStarted => 'Get Started';

  @override
  String get welcomeToTapTrade => 'Welcome to TapTrade';

  @override
  String get tutorialSwipe => 'Swipe through products';

  @override
  String get tutorialMatch => 'Match with traders';

  @override
  String get tutorialChat => 'Chat and trade';

  @override
  String get tutorialComplete => 'Start Trading';

  @override
  String get letsGetStarted => 'Let\'s Get Started';

  @override
  String get setupProfile => 'Setup Your Profile';

  @override
  String get addYourFirstProduct => 'Add your first product';

  @override
  String get setYourTradePreferences => 'Set Your Trade Preferences';

  @override
  String get unit => 'unit';

  @override
  String get units => 'units';

  @override
  String get km => 'km';

  @override
  String get miles => 'miles';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get away => 'away';

  @override
  String distanceAway(String distance, String unit) {
    return '$distance $unit away';
  }

  @override
  String get addLocation => 'Add Location';

  @override
  String get yourLocation => 'Your Location';

  @override
  String get addInterests => 'Add Interests';

  @override
  String get selectInterests => 'Select your interests';

  @override
  String get addProfilePhoto => 'Add Profile Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get tradingWith => 'Trading with';

  @override
  String get yourProduct => 'Your Product';

  @override
  String get theirProduct => 'Their Product';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get startChat => 'Start Chat';

  @override
  String get mutualMatches => 'Mutual Matches';

  @override
  String get noMutualMatchesYet => 'No mutual matches yet';

  @override
  String get welcomeToTapTradeExclaim => 'Welcome to TapTrade!';

  @override
  String get swipeToDiscover => 'Swipe to Discover';

  @override
  String get swipeToDiscoverDesc =>
      'Swipe right on items you want to trade for. Swipe left to pass. Match with users who want your items!';

  @override
  String get listYourItems => 'List Your Items';

  @override
  String get listYourItemsDesc =>
      'Add photos and details of items you want to trade. More listings mean more matches!';

  @override
  String get chatAndTrade => 'Chat & Trade';

  @override
  String get chatAndTradeDesc =>
      'When you match, chat with traders to arrange your swap. Safe, local trading made easy!';

  @override
  String get youreAllSet => 'You\'re All Set!';

  @override
  String get youreAllSetDesc =>
      'Start swiping, listing items, and connecting with traders near you. Happy trading!';

  @override
  String get pass => 'PASS';

  @override
  String get like => 'LIKE';

  @override
  String get subject => 'Subject';

  @override
  String get message => 'Message';

  @override
  String get yourQuery => 'Your query...';

  @override
  String get yourMessage => 'Your message...';

  @override
  String get sendMessageAction => 'Send Message';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String get weLoveToHear =>
      'We\'d love to hear from you! Please fill out the form below to ask a question or share your thoughts.';

  @override
  String get name => 'Name';

  @override
  String get userName => 'User Name';

  @override
  String get gender => 'Gender';

  @override
  String get contact => 'Contact #';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get alreadyVerified => 'Already Verified';

  @override
  String get needVerification => 'Need Verification';

  @override
  String get pleaseAddName => 'Please add Name';

  @override
  String get pleaseAddUserName => 'Please add userName';

  @override
  String get pleaseSelectGender => 'Please select gender';

  @override
  String get pleaseAddContact => 'Please add contact number';

  @override
  String get phoneNumberMustBe9Digits =>
      'Phone number must be exactly 9 digits';

  @override
  String get pleaseAddEmail => 'Please add email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get tradePreferencesTitle => 'Trade Preferences';

  @override
  String get yourLocationLabel => 'Your Location:';

  @override
  String get locationAutomatic =>
      'This is your automatic location (cannot be changed)';

  @override
  String selectTradeRadius(int radius) {
    return 'Select Trade Radius: $radius KM';
  }

  @override
  String get meetingPreferenceLabel => 'Meeting Preference:';

  @override
  String get deliveryPickup => 'Delivery/Pickup';

  @override
  String get willingToShip => 'Willing to Ship';

  @override
  String get pleaseSelectTradeRadius => 'Please select trade radius';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get chooseNotifications =>
      'Choose which notifications you want to receive';

  @override
  String get marketingPromotions => 'Marketing & Promotions';

  @override
  String get promotionalOffers => 'Promotional Offers';

  @override
  String get soundHaptics => 'Sound & Haptics';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get tradeUpdates => 'Trade Updates';

  @override
  String get canChangeAnytime => 'You can change these settings at any time';

  @override
  String get cover => 'Cover';

  @override
  String get tapToSetCover => 'Tap to set cover';

  @override
  String get noImages => 'No images';

  @override
  String get atLeastOneImageRequired => 'At least 1 image is required';

  @override
  String maximumImagesAllowed(int count) {
    return 'Maximum $count images allowed';
  }

  @override
  String get saveChanges => 'Save changes';

  @override
  String get title => 'Title';

  @override
  String get descriptionRequired => 'Description *';

  @override
  String get describeYourProduct => 'Describe your product in detail';

  @override
  String get productUpdated => 'Product updated';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get productIdMissing => 'Product ID is missing';

  @override
  String get minPriceMustBeLess =>
      'Minimum price must be less than maximum price';

  @override
  String get quantityMustBeBetween => 'Quantity must be between 1 and 99';

  @override
  String get descriptionTooLong =>
      'Description is too long (max 500 characters)';

  @override
  String get productDescriptionRequired => 'Product description is required';

  @override
  String get pleaseEnterTitle => 'Please enter title';

  @override
  String get createPasswordTitle => 'Create a password';

  @override
  String get makeItStrong => 'Make it strong and secure.';

  @override
  String get passwordMustContain => 'Password must contain:';

  @override
  String get atLeast8Characters => 'At least 8 characters';

  @override
  String get oneUppercaseLetter => 'One uppercase letter (A-Z)';

  @override
  String get oneLowercaseLetter => 'One lowercase letter (a-z)';

  @override
  String get oneNumber => 'One number (0-9)';

  @override
  String get reEnterPassword => 'Re-enter your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get pleaseEnterPhoneFirst => 'Please enter your phone number first';

  @override
  String get pleaseMeetAllRequirements =>
      'Please meet all password requirements';

  @override
  String get createYourUsername => 'Create your username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get youAreGoodToTrade => 'You are good to trade!';

  @override
  String get easiestWayToSwap =>
      'The easiest way to swap items with people nearby. Trade what you have for what you want!';

  @override
  String get currencySymbol => 'SAR';

  @override
  String priceRangeFormat(
    String minPrice,
    String maxPrice,
    Object max,
    Object min,
  ) {
    return '$min - $max SAR';
  }

  @override
  String get pleaseAddUsername => 'Please add userName';

  @override
  String get phoneMust9Digits => 'Phone number must be exactly 9 digits';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get loginFailed => 'Login failed. Please try again.';

  @override
  String get errorCheckingUsername =>
      'Error checking username. Please try again.';

  @override
  String get usernameAlreadyTaken => 'This username is already taken';

  @override
  String get usernameAppearance =>
      'This is how you\'ll appear in TapTrade. Choose wisely – you can\'t change it later!';

  @override
  String get usernameHelper => 'Letters, numbers, and underscores only';

  @override
  String addAtLeastOnePhoto(int max) {
    return 'Please add at least 1 photo (maximum $max)';
  }

  @override
  String get pleaseEnterTitleAndCategory => 'Please enter title and category';

  @override
  String get pleaseEnterDescription => 'Please enter product description';

  @override
  String get userNotFound => 'User not found';

  @override
  String get pleaseAddPhotos => 'Please add photos';

  @override
  String get productSubmitted => 'Product submitted';

  @override
  String get failedToSubmitProduct => 'Failed to submit product';

  @override
  String get describeProductShort => 'Describe your product in five words';

  @override
  String get productAddedSuccessfully => 'Product Added Successfully';

  @override
  String get markTradeComplete => 'Mark Trade as Complete?';

  @override
  String haveYouCompletedTrade(String username) {
    return 'Have you completed this trade with $username? They will need to confirm before the trade is finalized.';
  }

  @override
  String get theyWillNeedToConfirm =>
      'The other party will need to confirm before the trade is finalized.';

  @override
  String get yesMarkComplete => 'Yes, Mark Complete';

  @override
  String get complete => 'Complete';

  @override
  String get tradeMarkedComplete => 'Trade marked as complete!';

  @override
  String get tradeMarkedWaiting =>
      'Trade marked as complete. Waiting for other party to confirm.';

  @override
  String get tradeCompletedSuccess => 'Trade completed successfully!';

  @override
  String get tapProductToReveal =>
      'Please tap on a product to reveal the match first!';

  @override
  String get traderRevealedSuccess => 'Trader revealed successfully!';

  @override
  String get requestCannotProceed =>
      'Your request cannot proceed at the moment please try again later';

  @override
  String get errorTryAgainLater => 'An error occurred. Please try again later.';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get confirmTradeCompletion => 'Confirm Trade Completion?';

  @override
  String get confirmTradeCompletionMessage =>
      'The other party has marked this trade as complete. Do you confirm that the trade has been completed successfully?';

  @override
  String get notYet => 'Not Yet';

  @override
  String get yesConfirm => 'Yes, Confirm';

  @override
  String get confirmCompletion => 'Confirm Completion';

  @override
  String get waitingForConfirmation => 'Waiting for Confirmation...';

  @override
  String get tradeCompletedCheck => 'Trade Completed';

  @override
  String get revealTrader => 'Reveal Trader';

  @override
  String get matchedDeal => 'Matched Deal';

  @override
  String get termsComingSoon => 'Coming soon';

  @override
  String get privacyComingSoon => 'Coming soon';

  @override
  String get avatar => 'Avatar';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get pleaseEnterOtp => 'Please enter the OTP code';

  @override
  String get pleaseEnterValid6DigitOtp => 'Please enter a valid 6-digit OTP';

  @override
  String get otpResentSuccess => 'OTP resent successfully!';

  @override
  String get pleaseAddPhoneNumber => 'Please Add Your Phone Number';

  @override
  String otpSentTo(String phone) {
    return 'OTP sent to $phone';
  }

  @override
  String get phoneVerifiedAuto => 'Phone verified automatically!';

  @override
  String get startTypingToSearch => 'Start typing to search';

  @override
  String get searchCountry => 'Search country';

  @override
  String verificationCodeSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get confirmNewPasswordHint => 'Confirm new password';

  @override
  String get passwordResetSuccess => 'Password reset successfully!';

  @override
  String get photos => 'Photos';

  @override
  String get details => 'Details';

  @override
  String get conditionAndPrice => 'Condition & Price';

  @override
  String get review => 'Review';

  @override
  String get preview => 'Preview';

  @override
  String get submit => 'Submit';

  @override
  String get tapToSetCoverPhoto => 'Tap to set cover photo, long-press to view';

  @override
  String get enterShortTitle => 'Enter a short title';

  @override
  String get loadingCategories => 'Loading categories...';

  @override
  String get selectACategory => 'Select a category';

  @override
  String get describeProductDetail =>
      'Describe your product in detail (required, max 500 characters)';

  @override
  String get pressSubmitToUpload => 'Press Submit to upload all items';

  @override
  String get tapImagesToView => 'Tap images to view';

  @override
  String get noPhotosSelected => 'No photos selected';

  @override
  String photosSelected(int count) {
    return '$count photos selected';
  }

  @override
  String get addProducts => 'Add Products';

  @override
  String get productConditionLabel => 'PRODUCT CONDITION';

  @override
  String get productTitleLabel => 'PRODUCT TITLE';

  @override
  String get productDescriptionLabel => 'PRODUCT DESCRIPTION *';

  @override
  String get describeProductDetailRequired =>
      'Describe your product in detail (required)';

  @override
  String get pleaseAddProductImage => 'Please Add Product Image';

  @override
  String get pleaseSelectProductCategory => 'Please Select Product Category';

  @override
  String get pleaseAddProductTitle => 'Please Add Product Title';

  @override
  String get pleaseAddProductDescription => 'Please Add Product Description';

  @override
  String get pleaseAddProductQuantity => 'Please Add Product Quantity';

  @override
  String get pleaseEnterValidQuantity => 'Please Enter a Valid Quantity';

  @override
  String get pleaseAddMinPrice => 'Please Add Product Minimum Price';

  @override
  String get pleaseAddMaxPrice => 'Please Add Product Maximum Price';

  @override
  String productAddedCount(int current) {
    return 'Product Added $current/3';
  }

  @override
  String pleaseAddThreeProducts(int current) {
    return 'Please Add At Least Three Product $current/3';
  }

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String imagesCount(int count) {
    return '$count images';
  }

  @override
  String get poor => 'Poor';

  @override
  String get minMustBeLessThanMax => 'Min must be less than max';

  @override
  String get maxCannotExceed1000 => 'Max cannot exceed 1000';

  @override
  String get maxMustBeGreaterThanMin => 'Max must be greater than min';

  @override
  String get startTheConversation => 'Start the conversation!';

  @override
  String get sayHelloAndDiscuss => 'Say hello and discuss your trade.';

  @override
  String get matchDeals => 'Match Deals';

  @override
  String get refusedMatches => 'Refused Matches';

  @override
  String get failedToLoadRefusedMatches => 'Failed to load refused matches';

  @override
  String get noRefusedMatches => 'No Refused Matches';

  @override
  String get swipeLeftAppearHere =>
      'Products you swipe left on will appear here';

  @override
  String get removeDislike => 'Remove Dislike?';

  @override
  String get removeDislikeMessage =>
      'This product will be available for swiping again. You can like or dislike it in the future.';

  @override
  String get remove => 'Remove';

  @override
  String get reEnable => 'Re-enable';

  @override
  String get unknown => 'Unknown';

  @override
  String get likedDeals => 'Liked Deals';

  @override
  String productsYouLiked(int count) {
    return 'Products You Liked ($count)';
  }

  @override
  String get noLikesYet => 'No likes yet';

  @override
  String get swipeProductsToLike => 'Swipe on products to like them';

  @override
  String get almostThere => 'Almost there!';

  @override
  String get addPhoneRecoveryNotifications =>
      'Add your phone number for account recovery and notifications.';

  @override
  String get verifyYourPhone => 'Verify your phone';

  @override
  String get sendVerificationCodeMessage =>
      'We\'ll send you a verification code to confirm your phone number.';

  @override
  String get country => 'Country';

  @override
  String get smsAgreement =>
      'By continuing, you agree to receive SMS messages for verification purposes. Standard messaging rates may apply.';

  @override
  String get sendVerificationCode => 'Send Verification Code';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get enterPhoneResetPassword =>
      'Enter your phone number and we\'ll send you a verification code to reset your password.';

  @override
  String get createNewPasswordTitle => 'Create new password';

  @override
  String get passwordDifferentFromPrevious =>
      'Your new password must be different from previously used passwords.';

  @override
  String get passwordMin6Chars => 'Password must be at least 6 characters';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get atLeast6Characters => 'At least 6 characters';

  @override
  String get uppercaseLetterRecommended => 'Uppercase letter (recommended)';

  @override
  String get numberSpecialCharRecommended =>
      'Number or special character (recommended)';

  @override
  String get tooWeak => 'Too weak';

  @override
  String get weak => 'Weak';

  @override
  String get good => 'Good';

  @override
  String get strong => 'Strong';

  @override
  String get images1to4 => 'Images (1-4)';

  @override
  String get add => 'Add';

  @override
  String get processingPleaseWait => 'Processing Please Wait';

  @override
  String get chooseFromPhotos => 'Choose from Photos';

  @override
  String get galleryMultiple => 'Gallery (multiple)';

  @override
  String get nameLabel => 'NAME:';

  @override
  String get userNameLabel => 'USER NAME:';

  @override
  String get genderLabel => 'GENDER:';

  @override
  String get contactLabel => 'CONTACT#:';

  @override
  String get emailLabel => 'EMAIL:';

  @override
  String get continueButton => 'CONTINUE';

  @override
  String get otpError => 'OTP Error';

  @override
  String get addYourPhoneNumber =>
      'Add your phone number for account recovery and notifications.';

  @override
  String get fair => 'Fair';

  @override
  String get weSentCodeTo => 'We sent a code to';

  @override
  String get yourProducts => 'Your Products';

  @override
  String get haveYouCompletedTradeInPerson =>
      'Have you completed this trade in person?';

  @override
  String get markAsComplete => 'Mark as Complete';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get traders => 'Traders';

  @override
  String get all => 'All';

  @override
  String get favourites => 'Favourites';

  @override
  String get archives => 'Archives';

  @override
  String get pickLocation => 'Pick Location';

  @override
  String get use => 'Use';

  @override
  String get selectOneOfMyProducts => 'Select one of my products (optional)';

  @override
  String get allMyProducts => 'All my products';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get apply => 'Apply';

  @override
  String get defaultText => 'Default';

  @override
  String get filterByMyProducts => 'Filter by My Products (multiple)';

  @override
  String get onlyShowMatchesForOne => 'Only show matches for one product';

  @override
  String get categories => 'Categories';

  @override
  String get interests => 'Interests';

  @override
  String get radiusKm => 'Radius (km)';

  @override
  String productNumber(Object id) {
    return 'Product #$id';
  }

  @override
  String get interestsTitle => 'Interests';

  @override
  String get interestsDescription =>
      'Let everyone know what you\'re interested in\nby adding it to your profile.';

  @override
  String get failedToLoadInterests => 'Failed to load interests';

  @override
  String continueWithCount(Object count, Object max) {
    return 'Continue ($count/$max)';
  }

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordResetSuccessfully => 'Password reset successfully!';

  @override
  String get failedToResetPassword =>
      'Failed to reset password. Please try again.';

  @override
  String get errorOccurredTryAgain => 'An error occurred. Please try again.';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get phoneNumber9Digits => 'Phone number must be exactly 9 digits';

  @override
  String get failedToSendVerificationCode => 'Failed to send verification code';

  @override
  String get pleaseEnterUsername => 'Please enter a username';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get usernameMaxLength => 'Username must be less than 20 characters';

  @override
  String get usernameInvalidChars =>
      'Username can only contain letters, numbers, and underscores';

  @override
  String get smartWatch => 'Smart Watch';

  @override
  String get headphones => 'Headphones';

  @override
  String get letsTrade => 'Let\'s Trade?';

  @override
  String kmAway(Object distance) {
    return '$distance km away';
  }

  @override
  String get noMatchesNearby => 'No matches found nearby';

  @override
  String get noMatchesNearbyMessage =>
      'Try increasing your search radius or adding more interests to discover more products.';

  @override
  String get adjustSearchPreferences => 'Adjust search preferences';

  @override
  String get noProductsToTrade => 'No products to trade';

  @override
  String get noProductsToTradeMessage =>
      'Add your first product to start trading with others nearby.';

  @override
  String get addAProduct => 'Add a product';

  @override
  String get welcomeToDeals => 'Welcome to Deals';

  @override
  String get myVibesMatching => 'My Vibes Matching';

  @override
  String get matchedDeals => 'Matched Deals';

  @override
  String get backToHome => 'Back To Home';

  @override
  String contactNow(Object name) {
    return 'Contact $name now';
  }

  @override
  String get addProfilePhotoOptional => 'Add a profile photo (optional)';

  @override
  String get learnWhatHappens => 'Learn what happens when your number changes.';

  @override
  String productFallback(Object id) {
    return 'Product $id';
  }

  @override
  String showingProductsYouLiked(Object count) {
    return 'Showing $count products you already liked';
  }

  @override
  String get addButton => '+ Add';

  @override
  String get saveButton => 'Save';

  @override
  String get maxCannotExceed => 'Max cannot exceed 1000';

  @override
  String get noTitle => 'No title';

  @override
  String get sar => 'SAR';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get tagline => 'The Wanted for the Unwanted';

  @override
  String get signIn => 'Sign in';

  @override
  String get orDivider => 'or';

  @override
  String get byContinuingYouAgree => 'By continuing, you agree to our ';

  @override
  String get terms => 'Terms';

  @override
  String get andWord => ' and ';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get locationRequiredDescription =>
      'TapTrade needs your location to find nearby traders and show you products in your area.';

  @override
  String get activateProduct => 'Activate';

  @override
  String get productInactive => 'Inactive';

  @override
  String get productActivatedSuccess => 'Product activated!';
}
