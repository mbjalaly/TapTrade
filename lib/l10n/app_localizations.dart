import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'TapTrade'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone'**
  String get verifyPhone;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeIn(String seconds);

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @chooseUsername.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get chooseUsername;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'This will be your unique identifier'**
  String get usernameHint;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordRequirements;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @bazaar.
  ///
  /// In en, this message translates to:
  /// **'BAZAAR'**
  String get bazaar;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @swipeLeftToSkip.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to skip'**
  String get swipeLeftToSkip;

  /// No description provided for @swipeRightToLike.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to like'**
  String get swipeRightToLike;

  /// No description provided for @itsAMatch.
  ///
  /// In en, this message translates to:
  /// **'It\'s a Match!'**
  String get itsAMatch;

  /// No description provided for @youAndUserLikedEachOther.
  ///
  /// In en, this message translates to:
  /// **'You and {username} liked each other\'s products'**
  String youAndUserLikedEachOther(String username);

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @keepSwiping.
  ///
  /// In en, this message translates to:
  /// **'Keep Swiping'**
  String get keepSwiping;

  /// No description provided for @noMoreProducts.
  ///
  /// In en, this message translates to:
  /// **'No more products to show'**
  String get noMoreProducts;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later'**
  String get tryAgainLater;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @selectProductsToTrade.
  ///
  /// In en, this message translates to:
  /// **'Select Products to Trade'**
  String get selectProductsToTrade;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailable;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @closeProductSelector.
  ///
  /// In en, this message translates to:
  /// **'Close product selector'**
  String get closeProductSelector;

  /// No description provided for @selectProducts.
  ///
  /// In en, this message translates to:
  /// **'Select products'**
  String get selectProducts;

  /// No description provided for @searchFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search filters'**
  String get searchFiltersTooltip;

  /// No description provided for @noProductDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No product data available'**
  String get noProductDataAvailable;

  /// No description provided for @dealsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Deals near you'**
  String get dealsNearYou;

  /// No description provided for @swipeToExploreItems.
  ///
  /// In en, this message translates to:
  /// **'Swipe to explore {count} items'**
  String swipeToExploreItems(int count);

  /// No description provided for @noNewProductsNearby.
  ///
  /// In en, this message translates to:
  /// **'No new products nearby'**
  String get noNewProductsNearby;

  /// No description provided for @showingAlreadyLikedProducts.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} products you already liked'**
  String showingAlreadyLikedProducts(int count);

  /// No description provided for @addYourFirstProductShort.
  ///
  /// In en, this message translates to:
  /// **'Add your first product'**
  String get addYourFirstProductShort;

  /// No description provided for @listProductsToStartTrading.
  ///
  /// In en, this message translates to:
  /// **'List products to start trading with others nearby'**
  String get listProductsToStartTrading;

  /// No description provided for @noNearbyTrades.
  ///
  /// In en, this message translates to:
  /// **'No nearby trades'**
  String get noNearbyTrades;

  /// No description provided for @tryIncreasingSearchRadius.
  ///
  /// In en, this message translates to:
  /// **'Try increasing your search radius in preferences'**
  String get tryIncreasingSearchRadius;

  /// No description provided for @allProductsFiltered.
  ///
  /// In en, this message translates to:
  /// **'All products filtered'**
  String get allProductsFiltered;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters to see more trades'**
  String get tryAdjustingFilters;

  /// No description provided for @noMatchesYetShort.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get noMatchesYetShort;

  /// No description provided for @checkBackSoon.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for new trading opportunities'**
  String get checkBackSoon;

  /// No description provided for @locationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location access'**
  String get locationAccess;

  /// No description provided for @unableToAccessLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to access your location. Products may not be accurate.'**
  String get unableToAccessLocation;

  /// No description provided for @errorLoadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Error loading products'**
  String get errorLoadingProducts;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again'**
  String get checkInternetConnection;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Title'**
  String get productTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @minPrice.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get maxPrice;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Quantity Available'**
  String get quantityAvailable;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @selectCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Condition'**
  String get selectCondition;

  /// No description provided for @productImages.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get productImages;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @editImages.
  ///
  /// In en, this message translates to:
  /// **'Edit Images'**
  String get editImages;

  /// No description provided for @myProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myProducts;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @confirmDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get confirmDeleteProduct;

  /// No description provided for @productNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get productNew;

  /// No description provided for @productUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get productUsed;

  /// No description provided for @productLikeNew.
  ///
  /// In en, this message translates to:
  /// **'Like New'**
  String get productLikeNew;

  /// No description provided for @productGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get productGood;

  /// No description provided for @productFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get productFair;

  /// No description provided for @backToSwipe.
  ///
  /// In en, this message translates to:
  /// **'Back to Swipe'**
  String get backToSwipe;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @addYourFirstProductToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to get started'**
  String get addYourFirstProductToGetStarted;

  /// No description provided for @noActiveProducts.
  ///
  /// In en, this message translates to:
  /// **'No active products'**
  String get noActiveProducts;

  /// No description provided for @youHaveProductsButNoneActive.
  ///
  /// In en, this message translates to:
  /// **'You have {count} product(s) but none are active'**
  String youHaveProductsButNoneActive(int count);

  /// No description provided for @completedDeals.
  ///
  /// In en, this message translates to:
  /// **'Completed Deals'**
  String get completedDeals;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// No description provided for @areYouSureDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete:'**
  String get areYouSureDeleteProduct;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

  /// No description provided for @failedToDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get failedToDeleteProduct;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurred;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logoutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Logout successful'**
  String get logoutSuccessful;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get confirmDeleteAccount;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @addBio.
  ///
  /// In en, this message translates to:
  /// **'Add Bio'**
  String get addBio;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @tradePreferences.
  ///
  /// In en, this message translates to:
  /// **'Trade preferences'**
  String get tradePreferences;

  /// No description provided for @tradeRadius.
  ///
  /// In en, this message translates to:
  /// **'Trade Radius'**
  String get tradeRadius;

  /// No description provided for @meetingPreference.
  ///
  /// In en, this message translates to:
  /// **'Meeting Preference'**
  String get meetingPreference;

  /// No description provided for @publicPlace.
  ///
  /// In en, this message translates to:
  /// **'Public Place'**
  String get publicPlace;

  /// No description provided for @doorstep.
  ///
  /// In en, this message translates to:
  /// **'Doorstep'**
  String get doorstep;

  /// No description provided for @locationPicker.
  ///
  /// In en, this message translates to:
  /// **'Location Picker'**
  String get locationPicker;

  /// No description provided for @setYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Your Location'**
  String get setYourLocation;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Search Filters'**
  String get searchFilters;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @matchNotifications.
  ///
  /// In en, this message translates to:
  /// **'Match Notifications'**
  String get matchNotifications;

  /// No description provided for @messageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Message Notifications'**
  String get messageNotifications;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @verifyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhoneNumber;

  /// No description provided for @profileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile information'**
  String get profileInformation;

  /// No description provided for @matchesAndChat.
  ///
  /// In en, this message translates to:
  /// **'Matches & Chat'**
  String get matchesAndChat;

  /// No description provided for @faqQuestions.
  ///
  /// In en, this message translates to:
  /// **'FAQ questions'**
  String get faqQuestions;

  /// No description provided for @termsAndPolicies.
  ///
  /// In en, this message translates to:
  /// **'Terms and policies'**
  String get termsAndPolicies;

  /// No description provided for @viewTutorial.
  ///
  /// In en, this message translates to:
  /// **'View tutorial'**
  String get viewTutorial;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @faqComingSoon.
  ///
  /// In en, this message translates to:
  /// **'FAQ page is coming soon'**
  String get faqComingSoon;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @likedProducts.
  ///
  /// In en, this message translates to:
  /// **'Liked Products'**
  String get likedProducts;

  /// No description provided for @dislikedProducts.
  ///
  /// In en, this message translates to:
  /// **'Disliked Products'**
  String get dislikedProducts;

  /// No description provided for @tradeHistory.
  ///
  /// In en, this message translates to:
  /// **'Trade History'**
  String get tradeHistory;

  /// No description provided for @pendingTrades.
  ///
  /// In en, this message translates to:
  /// **'Pending Trades'**
  String get pendingTrades;

  /// No description provided for @completedTrades.
  ///
  /// In en, this message translates to:
  /// **'Completed Trades'**
  String get completedTrades;

  /// No description provided for @tradeRequest.
  ///
  /// In en, this message translates to:
  /// **'Trade Request'**
  String get tradeRequest;

  /// No description provided for @sendTradeRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Trade Request'**
  String get sendTradeRequest;

  /// No description provided for @acceptTrade.
  ///
  /// In en, this message translates to:
  /// **'Accept Trade'**
  String get acceptTrade;

  /// No description provided for @rejectTrade.
  ///
  /// In en, this message translates to:
  /// **'Reject Trade'**
  String get rejectTrade;

  /// No description provided for @tradeSent.
  ///
  /// In en, this message translates to:
  /// **'Trade request sent'**
  String get tradeSent;

  /// No description provided for @tradeAccepted.
  ///
  /// In en, this message translates to:
  /// **'Trade accepted'**
  String get tradeAccepted;

  /// No description provided for @tradeRejected.
  ///
  /// In en, this message translates to:
  /// **'Trade rejected'**
  String get tradeRejected;

  /// No description provided for @tradeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trade completed'**
  String get tradeCompleted;

  /// No description provided for @deals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get deals;

  /// No description provided for @noDeals.
  ///
  /// In en, this message translates to:
  /// **'No deals yet'**
  String get noDeals;

  /// No description provided for @contactTrader.
  ///
  /// In en, this message translates to:
  /// **'Contact Trader'**
  String get contactTrader;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get typing;

  /// No description provided for @noMatchesYet.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get noMatchesYet;

  /// No description provided for @keepSwipingToFindMatches.
  ///
  /// In en, this message translates to:
  /// **'Keep swiping to find people who want to trade with you!'**
  String get keepSwipingToFindMatches;

  /// No description provided for @matchWord.
  ///
  /// In en, this message translates to:
  /// **'match'**
  String get matchWord;

  /// No description provided for @matchesWord.
  ///
  /// In en, this message translates to:
  /// **'matches'**
  String get matchesWord;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseTryAgain;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @checkYourConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get checkYourConnection;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcomeToTapTrade.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TapTrade'**
  String get welcomeToTapTrade;

  /// No description provided for @tutorialSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe through products'**
  String get tutorialSwipe;

  /// No description provided for @tutorialMatch.
  ///
  /// In en, this message translates to:
  /// **'Match with traders'**
  String get tutorialMatch;

  /// No description provided for @tutorialChat.
  ///
  /// In en, this message translates to:
  /// **'Chat and trade'**
  String get tutorialChat;

  /// No description provided for @tutorialComplete.
  ///
  /// In en, this message translates to:
  /// **'Start Trading'**
  String get tutorialComplete;

  /// No description provided for @letsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started'**
  String get letsGetStarted;

  /// No description provided for @setupProfile.
  ///
  /// In en, this message translates to:
  /// **'Setup Your Profile'**
  String get setupProfile;

  /// No description provided for @addYourFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add your first product'**
  String get addYourFirstProduct;

  /// No description provided for @setYourTradePreferences.
  ///
  /// In en, this message translates to:
  /// **'Set Your Trade Preferences'**
  String get setYourTradePreferences;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'unit'**
  String get unit;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @miles.
  ///
  /// In en, this message translates to:
  /// **'miles'**
  String get miles;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @away.
  ///
  /// In en, this message translates to:
  /// **'away'**
  String get away;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} {unit} away'**
  String distanceAway(String distance, String unit);

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocation;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @addInterests.
  ///
  /// In en, this message translates to:
  /// **'Add Interests'**
  String get addInterests;

  /// No description provided for @selectInterests.
  ///
  /// In en, this message translates to:
  /// **'Select your interests'**
  String get selectInterests;

  /// No description provided for @addProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Profile Photo'**
  String get addProfilePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @tradingWith.
  ///
  /// In en, this message translates to:
  /// **'Trading with'**
  String get tradingWith;

  /// No description provided for @yourProduct.
  ///
  /// In en, this message translates to:
  /// **'Your Product'**
  String get yourProduct;

  /// No description provided for @theirProduct.
  ///
  /// In en, this message translates to:
  /// **'Their Product'**
  String get theirProduct;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get startChat;

  /// No description provided for @mutualMatches.
  ///
  /// In en, this message translates to:
  /// **'Mutual Matches'**
  String get mutualMatches;

  /// No description provided for @noMutualMatchesYet.
  ///
  /// In en, this message translates to:
  /// **'No mutual matches yet'**
  String get noMutualMatchesYet;

  /// No description provided for @welcomeToTapTradeExclaim.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TapTrade!'**
  String get welcomeToTapTradeExclaim;

  /// No description provided for @swipeToDiscover.
  ///
  /// In en, this message translates to:
  /// **'Swipe to Discover'**
  String get swipeToDiscover;

  /// No description provided for @swipeToDiscoverDesc.
  ///
  /// In en, this message translates to:
  /// **'Swipe right on items you want to trade for. Swipe left to pass. Match with users who want your items!'**
  String get swipeToDiscoverDesc;

  /// No description provided for @listYourItems.
  ///
  /// In en, this message translates to:
  /// **'List Your Items'**
  String get listYourItems;

  /// No description provided for @listYourItemsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add photos and details of items you want to trade. More listings mean more matches!'**
  String get listYourItemsDesc;

  /// No description provided for @chatAndTrade.
  ///
  /// In en, this message translates to:
  /// **'Chat & Trade'**
  String get chatAndTrade;

  /// No description provided for @chatAndTradeDesc.
  ///
  /// In en, this message translates to:
  /// **'When you match, chat with traders to arrange your swap. Safe, local trading made easy!'**
  String get chatAndTradeDesc;

  /// No description provided for @youreAllSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get youreAllSet;

  /// No description provided for @youreAllSetDesc.
  ///
  /// In en, this message translates to:
  /// **'Start swiping, listing items, and connecting with traders near you. Happy trading!'**
  String get youreAllSetDesc;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'PASS'**
  String get pass;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'LIKE'**
  String get like;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @yourQuery.
  ///
  /// In en, this message translates to:
  /// **'Your query...'**
  String get yourQuery;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message...'**
  String get yourMessage;

  /// No description provided for @sendMessageAction.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessageAction;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @weLoveToHear.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear from you! Please fill out the form below to ask a question or share your thoughts.'**
  String get weLoveToHear;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact #'**
  String get contact;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @alreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'Already Verified'**
  String get alreadyVerified;

  /// No description provided for @needVerification.
  ///
  /// In en, this message translates to:
  /// **'Need Verification'**
  String get needVerification;

  /// No description provided for @pleaseAddName.
  ///
  /// In en, this message translates to:
  /// **'Please add Name'**
  String get pleaseAddName;

  /// No description provided for @pleaseAddUserName.
  ///
  /// In en, this message translates to:
  /// **'Please add userName'**
  String get pleaseAddUserName;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select gender'**
  String get pleaseSelectGender;

  /// No description provided for @pleaseAddContact.
  ///
  /// In en, this message translates to:
  /// **'Please add contact number'**
  String get pleaseAddContact;

  /// No description provided for @phoneNumberMustBe9Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly 9 digits'**
  String get phoneNumberMustBe9Digits;

  /// No description provided for @pleaseAddEmail.
  ///
  /// In en, this message translates to:
  /// **'Please add email'**
  String get pleaseAddEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @tradePreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade Preferences'**
  String get tradePreferencesTitle;

  /// No description provided for @yourLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Location:'**
  String get yourLocationLabel;

  /// No description provided for @locationAutomatic.
  ///
  /// In en, this message translates to:
  /// **'This is your automatic location (cannot be changed)'**
  String get locationAutomatic;

  /// No description provided for @selectTradeRadius.
  ///
  /// In en, this message translates to:
  /// **'Select Trade Radius: {radius} KM'**
  String selectTradeRadius(int radius);

  /// No description provided for @meetingPreferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Meeting Preference:'**
  String get meetingPreferenceLabel;

  /// No description provided for @deliveryPickup.
  ///
  /// In en, this message translates to:
  /// **'Delivery/Pickup'**
  String get deliveryPickup;

  /// No description provided for @willingToShip.
  ///
  /// In en, this message translates to:
  /// **'Willing to Ship'**
  String get willingToShip;

  /// No description provided for @pleaseSelectTradeRadius.
  ///
  /// In en, this message translates to:
  /// **'Please select trade radius'**
  String get pleaseSelectTradeRadius;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @chooseNotifications.
  ///
  /// In en, this message translates to:
  /// **'Choose which notifications you want to receive'**
  String get chooseNotifications;

  /// No description provided for @marketingPromotions.
  ///
  /// In en, this message translates to:
  /// **'Marketing & Promotions'**
  String get marketingPromotions;

  /// No description provided for @promotionalOffers.
  ///
  /// In en, this message translates to:
  /// **'Promotional Offers'**
  String get promotionalOffers;

  /// No description provided for @soundHaptics.
  ///
  /// In en, this message translates to:
  /// **'Sound & Haptics'**
  String get soundHaptics;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @tradeUpdates.
  ///
  /// In en, this message translates to:
  /// **'Trade Updates'**
  String get tradeUpdates;

  /// No description provided for @canChangeAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can change these settings at any time'**
  String get canChangeAnytime;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get cover;

  /// No description provided for @tapToSetCover.
  ///
  /// In en, this message translates to:
  /// **'Tap to set cover'**
  String get tapToSetCover;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get noImages;

  /// No description provided for @atLeastOneImageRequired.
  ///
  /// In en, this message translates to:
  /// **'At least 1 image is required'**
  String get atLeastOneImageRequired;

  /// No description provided for @maximumImagesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} images allowed'**
  String maximumImagesAllowed(int count);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get descriptionRequired;

  /// No description provided for @describeYourProduct.
  ///
  /// In en, this message translates to:
  /// **'Describe your product in detail'**
  String get describeYourProduct;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated'**
  String get productUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @productIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Product ID is missing'**
  String get productIdMissing;

  /// No description provided for @minPriceMustBeLess.
  ///
  /// In en, this message translates to:
  /// **'Minimum price must be less than maximum price'**
  String get minPriceMustBeLess;

  /// No description provided for @quantityMustBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be between 1 and 99'**
  String get quantityMustBeBetween;

  /// No description provided for @descriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Description is too long (max 500 characters)'**
  String get descriptionTooLong;

  /// No description provided for @productDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Product description is required'**
  String get productDescriptionRequired;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter title'**
  String get pleaseEnterTitle;

  /// No description provided for @createPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPasswordTitle;

  /// No description provided for @makeItStrong.
  ///
  /// In en, this message translates to:
  /// **'Make it strong and secure.'**
  String get makeItStrong;

  /// No description provided for @passwordMustContain.
  ///
  /// In en, this message translates to:
  /// **'Password must contain:'**
  String get passwordMustContain;

  /// No description provided for @atLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// No description provided for @oneUppercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter (A-Z)'**
  String get oneUppercaseLetter;

  /// No description provided for @oneLowercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter (a-z)'**
  String get oneLowercaseLetter;

  /// No description provided for @oneNumber.
  ///
  /// In en, this message translates to:
  /// **'One number (0-9)'**
  String get oneNumber;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reEnterPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @pleaseEnterPhoneFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number first'**
  String get pleaseEnterPhoneFirst;

  /// No description provided for @pleaseMeetAllRequirements.
  ///
  /// In en, this message translates to:
  /// **'Please meet all password requirements'**
  String get pleaseMeetAllRequirements;

  /// No description provided for @createYourUsername.
  ///
  /// In en, this message translates to:
  /// **'Create your username'**
  String get createYourUsername;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @youAreGoodToTrade.
  ///
  /// In en, this message translates to:
  /// **'You are good to trade!'**
  String get youAreGoodToTrade;

  /// No description provided for @easiestWayToSwap.
  ///
  /// In en, this message translates to:
  /// **'The easiest way to swap items with people nearby. Trade what you have for what you want!'**
  String get easiestWayToSwap;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get currencySymbol;

  /// No description provided for @priceRangeFormat.
  ///
  /// In en, this message translates to:
  /// **'{min} - {max} SAR'**
  String priceRangeFormat(
      String minPrice, String maxPrice, Object max, Object min);

  /// No description provided for @pleaseAddUsername.
  ///
  /// In en, this message translates to:
  /// **'Please add userName'**
  String get pleaseAddUsername;

  /// No description provided for @phoneMust9Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly 9 digits'**
  String get phoneMust9Digits;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @errorCheckingUsername.
  ///
  /// In en, this message translates to:
  /// **'Error checking username. Please try again.'**
  String get errorCheckingUsername;

  /// No description provided for @usernameAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get usernameAlreadyTaken;

  /// No description provided for @usernameAppearance.
  ///
  /// In en, this message translates to:
  /// **'This is how you\'ll appear in TapTrade. Choose wisely – you can\'t change it later!'**
  String get usernameAppearance;

  /// No description provided for @usernameHelper.
  ///
  /// In en, this message translates to:
  /// **'Letters, numbers, and underscores only'**
  String get usernameHelper;

  /// No description provided for @addAtLeastOnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 1 photo (maximum {max})'**
  String addAtLeastOnePhoto(int max);

  /// No description provided for @pleaseEnterTitleAndCategory.
  ///
  /// In en, this message translates to:
  /// **'Please enter title and category'**
  String get pleaseEnterTitleAndCategory;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter product description'**
  String get pleaseEnterDescription;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @pleaseAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Please add photos'**
  String get pleaseAddPhotos;

  /// No description provided for @productSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Product submitted'**
  String get productSubmitted;

  /// No description provided for @failedToSubmitProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit product'**
  String get failedToSubmitProduct;

  /// No description provided for @describeProductShort.
  ///
  /// In en, this message translates to:
  /// **'Describe your product in five words'**
  String get describeProductShort;

  /// No description provided for @productAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product Added Successfully'**
  String get productAddedSuccessfully;

  /// No description provided for @markTradeComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Trade as Complete?'**
  String get markTradeComplete;

  /// No description provided for @haveYouCompletedTrade.
  ///
  /// In en, this message translates to:
  /// **'Have you completed this trade with {username}? They will need to confirm before the trade is finalized.'**
  String haveYouCompletedTrade(String username);

  /// No description provided for @theyWillNeedToConfirm.
  ///
  /// In en, this message translates to:
  /// **'The other party will need to confirm before the trade is finalized.'**
  String get theyWillNeedToConfirm;

  /// No description provided for @yesMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Mark Complete'**
  String get yesMarkComplete;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @tradeMarkedComplete.
  ///
  /// In en, this message translates to:
  /// **'Trade marked as complete!'**
  String get tradeMarkedComplete;

  /// No description provided for @tradeMarkedWaiting.
  ///
  /// In en, this message translates to:
  /// **'Trade marked as complete. Waiting for other party to confirm.'**
  String get tradeMarkedWaiting;

  /// No description provided for @tradeCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trade completed successfully!'**
  String get tradeCompletedSuccess;

  /// No description provided for @tapProductToReveal.
  ///
  /// In en, this message translates to:
  /// **'Please tap on a product to reveal the match first!'**
  String get tapProductToReveal;

  /// No description provided for @traderRevealedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trader revealed successfully!'**
  String get traderRevealedSuccess;

  /// No description provided for @requestCannotProceed.
  ///
  /// In en, this message translates to:
  /// **'Your request cannot proceed at the moment please try again later'**
  String get requestCannotProceed;

  /// No description provided for @errorTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get errorTryAgainLater;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// No description provided for @confirmTradeCompletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Trade Completion?'**
  String get confirmTradeCompletion;

  /// No description provided for @confirmTradeCompletionMessage.
  ///
  /// In en, this message translates to:
  /// **'The other party has marked this trade as complete. Do you confirm that the trade has been completed successfully?'**
  String get confirmTradeCompletionMessage;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get notYet;

  /// No description provided for @yesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, Confirm'**
  String get yesConfirm;

  /// No description provided for @confirmCompletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Completion'**
  String get confirmCompletion;

  /// No description provided for @waitingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Confirmation...'**
  String get waitingForConfirmation;

  /// No description provided for @tradeCompletedCheck.
  ///
  /// In en, this message translates to:
  /// **'Trade Completed'**
  String get tradeCompletedCheck;

  /// No description provided for @revealTrader.
  ///
  /// In en, this message translates to:
  /// **'Reveal Trader'**
  String get revealTrader;

  /// No description provided for @matchedDeal.
  ///
  /// In en, this message translates to:
  /// **'Matched Deal'**
  String get matchedDeal;

  /// No description provided for @termsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get termsComingSoon;

  /// No description provided for @privacyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get privacyComingSoon;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @pleaseEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OTP code'**
  String get pleaseEnterOtp;

  /// No description provided for @pleaseEnterValid6DigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit OTP'**
  String get pleaseEnterValid6DigitOtp;

  /// No description provided for @otpResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully!'**
  String get otpResentSuccess;

  /// No description provided for @pleaseAddPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please Add Your Phone Number'**
  String get pleaseAddPhoneNumber;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @phoneVerifiedAuto.
  ///
  /// In en, this message translates to:
  /// **'Phone verified automatically!'**
  String get phoneVerifiedAuto;

  /// No description provided for @startTypingToSearch.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get startTypingToSearch;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @verificationCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String verificationCodeSentTo(String phone);

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordHint;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get passwordResetSuccess;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @conditionAndPrice.
  ///
  /// In en, this message translates to:
  /// **'Condition & Price'**
  String get conditionAndPrice;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @tapToSetCoverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to set cover photo, long-press to view'**
  String get tapToSetCoverPhoto;

  /// No description provided for @enterShortTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a short title'**
  String get enterShortTitle;

  /// No description provided for @loadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get loadingCategories;

  /// No description provided for @selectACategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectACategory;

  /// No description provided for @describeProductDetail.
  ///
  /// In en, this message translates to:
  /// **'Describe your product in detail (required, max 500 characters)'**
  String get describeProductDetail;

  /// No description provided for @pressSubmitToUpload.
  ///
  /// In en, this message translates to:
  /// **'Press Submit to upload all items'**
  String get pressSubmitToUpload;

  /// No description provided for @tapImagesToView.
  ///
  /// In en, this message translates to:
  /// **'Tap images to view'**
  String get tapImagesToView;

  /// No description provided for @noPhotosSelected.
  ///
  /// In en, this message translates to:
  /// **'No photos selected'**
  String get noPhotosSelected;

  /// No description provided for @photosSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} photos selected'**
  String photosSelected(int count);

  /// No description provided for @addProducts.
  ///
  /// In en, this message translates to:
  /// **'Add Products'**
  String get addProducts;

  /// No description provided for @productConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT CONDITION'**
  String get productConditionLabel;

  /// No description provided for @productTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT TITLE'**
  String get productTitleLabel;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT DESCRIPTION *'**
  String get productDescriptionLabel;

  /// No description provided for @describeProductDetailRequired.
  ///
  /// In en, this message translates to:
  /// **'Describe your product in detail (required)'**
  String get describeProductDetailRequired;

  /// No description provided for @pleaseAddProductImage.
  ///
  /// In en, this message translates to:
  /// **'Please Add Product Image'**
  String get pleaseAddProductImage;

  /// No description provided for @pleaseSelectProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Please Select Product Category'**
  String get pleaseSelectProductCategory;

  /// No description provided for @pleaseAddProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Please Add Product Title'**
  String get pleaseAddProductTitle;

  /// No description provided for @pleaseAddProductDescription.
  ///
  /// In en, this message translates to:
  /// **'Please Add Product Description'**
  String get pleaseAddProductDescription;

  /// No description provided for @pleaseAddProductQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please Add Product Quantity'**
  String get pleaseAddProductQuantity;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please Enter a Valid Quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @pleaseAddMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Please Add Product Minimum Price'**
  String get pleaseAddMinPrice;

  /// No description provided for @pleaseAddMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Please Add Product Maximum Price'**
  String get pleaseAddMaxPrice;

  /// No description provided for @productAddedCount.
  ///
  /// In en, this message translates to:
  /// **'Product Added {current}/3'**
  String productAddedCount(int current);

  /// No description provided for @pleaseAddThreeProducts.
  ///
  /// In en, this message translates to:
  /// **'Please Add At Least Three Product {current}/3'**
  String pleaseAddThreeProducts(int current);

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @imagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} images'**
  String imagesCount(int count);

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @minMustBeLessThanMax.
  ///
  /// In en, this message translates to:
  /// **'Min must be less than max'**
  String get minMustBeLessThanMax;

  /// No description provided for @maxCannotExceed1000.
  ///
  /// In en, this message translates to:
  /// **'Max cannot exceed 1000'**
  String get maxCannotExceed1000;

  /// No description provided for @maxMustBeGreaterThanMin.
  ///
  /// In en, this message translates to:
  /// **'Max must be greater than min'**
  String get maxMustBeGreaterThanMin;

  /// No description provided for @startTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get startTheConversation;

  /// No description provided for @sayHelloAndDiscuss.
  ///
  /// In en, this message translates to:
  /// **'Say hello and discuss your trade.'**
  String get sayHelloAndDiscuss;

  /// No description provided for @matchDeals.
  ///
  /// In en, this message translates to:
  /// **'Match Deals'**
  String get matchDeals;

  /// No description provided for @refusedMatches.
  ///
  /// In en, this message translates to:
  /// **'Refused Matches'**
  String get refusedMatches;

  /// No description provided for @failedToLoadRefusedMatches.
  ///
  /// In en, this message translates to:
  /// **'Failed to load refused matches'**
  String get failedToLoadRefusedMatches;

  /// No description provided for @noRefusedMatches.
  ///
  /// In en, this message translates to:
  /// **'No Refused Matches'**
  String get noRefusedMatches;

  /// No description provided for @swipeLeftAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Products you swipe left on will appear here'**
  String get swipeLeftAppearHere;

  /// No description provided for @removeDislike.
  ///
  /// In en, this message translates to:
  /// **'Remove Dislike?'**
  String get removeDislike;

  /// No description provided for @removeDislikeMessage.
  ///
  /// In en, this message translates to:
  /// **'This product will be available for swiping again. You can like or dislike it in the future.'**
  String get removeDislikeMessage;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @reEnable.
  ///
  /// In en, this message translates to:
  /// **'Re-enable'**
  String get reEnable;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @likedDeals.
  ///
  /// In en, this message translates to:
  /// **'Liked Deals'**
  String get likedDeals;

  /// No description provided for @productsYouLiked.
  ///
  /// In en, this message translates to:
  /// **'Products You Liked ({count})'**
  String productsYouLiked(int count);

  /// No description provided for @noLikesYet.
  ///
  /// In en, this message translates to:
  /// **'No likes yet'**
  String get noLikesYet;

  /// No description provided for @swipeProductsToLike.
  ///
  /// In en, this message translates to:
  /// **'Swipe on products to like them'**
  String get swipeProductsToLike;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @addPhoneRecoveryNotifications.
  ///
  /// In en, this message translates to:
  /// **'Add your phone number for account recovery and notifications.'**
  String get addPhoneRecoveryNotifications;

  /// No description provided for @verifyYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone'**
  String get verifyYourPhone;

  /// No description provided for @sendVerificationCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a verification code to confirm your phone number.'**
  String get sendVerificationCodeMessage;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @smsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to receive SMS messages for verification purposes. Standard messaging rates may apply.'**
  String get smsAgreement;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @enterPhoneResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number and we\'ll send you a verification code to reset your password.'**
  String get enterPhoneResetPassword;

  /// No description provided for @createNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get createNewPasswordTitle;

  /// No description provided for @passwordDifferentFromPrevious.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from previously used passwords.'**
  String get passwordDifferentFromPrevious;

  /// No description provided for @passwordMin6Chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6Chars;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @atLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6Characters;

  /// No description provided for @uppercaseLetterRecommended.
  ///
  /// In en, this message translates to:
  /// **'Uppercase letter (recommended)'**
  String get uppercaseLetterRecommended;

  /// No description provided for @numberSpecialCharRecommended.
  ///
  /// In en, this message translates to:
  /// **'Number or special character (recommended)'**
  String get numberSpecialCharRecommended;

  /// No description provided for @tooWeak.
  ///
  /// In en, this message translates to:
  /// **'Too weak'**
  String get tooWeak;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @images1to4.
  ///
  /// In en, this message translates to:
  /// **'Images (1-4)'**
  String get images1to4;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @processingPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Processing Please Wait'**
  String get processingPleaseWait;

  /// No description provided for @chooseFromPhotos.
  ///
  /// In en, this message translates to:
  /// **'Choose from Photos'**
  String get chooseFromPhotos;

  /// No description provided for @galleryMultiple.
  ///
  /// In en, this message translates to:
  /// **'Gallery (multiple)'**
  String get galleryMultiple;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME:'**
  String get nameLabel;

  /// No description provided for @userNameLabel.
  ///
  /// In en, this message translates to:
  /// **'USER NAME:'**
  String get userNameLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'GENDER:'**
  String get genderLabel;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTACT#:'**
  String get contactLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL:'**
  String get emailLabel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// No description provided for @otpError.
  ///
  /// In en, this message translates to:
  /// **'OTP Error'**
  String get otpError;

  /// No description provided for @addYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Add your phone number for account recovery and notifications.'**
  String get addYourPhoneNumber;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @weSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to'**
  String get weSentCodeTo;

  /// No description provided for @yourProducts.
  ///
  /// In en, this message translates to:
  /// **'Your Products'**
  String get yourProducts;

  /// No description provided for @haveYouCompletedTradeInPerson.
  ///
  /// In en, this message translates to:
  /// **'Have you completed this trade in person?'**
  String get haveYouCompletedTradeInPerson;

  /// No description provided for @markAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @traders.
  ///
  /// In en, this message translates to:
  /// **'Traders'**
  String get traders;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @archives.
  ///
  /// In en, this message translates to:
  /// **'Archives'**
  String get archives;

  /// No description provided for @pickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick Location'**
  String get pickLocation;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @selectOneOfMyProducts.
  ///
  /// In en, this message translates to:
  /// **'Select one of my products (optional)'**
  String get selectOneOfMyProducts;

  /// No description provided for @allMyProducts.
  ///
  /// In en, this message translates to:
  /// **'All my products'**
  String get allMyProducts;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @defaultText.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultText;

  /// No description provided for @filterByMyProducts.
  ///
  /// In en, this message translates to:
  /// **'Filter by My Products (multiple)'**
  String get filterByMyProducts;

  /// No description provided for @onlyShowMatchesForOne.
  ///
  /// In en, this message translates to:
  /// **'Only show matches for one product'**
  String get onlyShowMatchesForOne;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @radiusKm.
  ///
  /// In en, this message translates to:
  /// **'Radius (km)'**
  String get radiusKm;

  /// No description provided for @productNumber.
  ///
  /// In en, this message translates to:
  /// **'Product #{id}'**
  String productNumber(Object id);

  /// No description provided for @interestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interestsTitle;

  /// No description provided for @interestsDescription.
  ///
  /// In en, this message translates to:
  /// **'Let everyone know what you\'re interested in\nby adding it to your profile.'**
  String get interestsDescription;

  /// No description provided for @failedToLoadInterests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load interests'**
  String get failedToLoadInterests;

  /// No description provided for @continueWithCount.
  ///
  /// In en, this message translates to:
  /// **'Continue ({count}/{max})'**
  String continueWithCount(Object count, Object max);

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get passwordResetSuccessfully;

  /// No description provided for @failedToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password. Please try again.'**
  String get failedToResetPassword;

  /// No description provided for @errorOccurredTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurredTryAgain;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @phoneNumber9Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly 9 digits'**
  String get phoneNumber9Digits;

  /// No description provided for @failedToSendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification code'**
  String get failedToSendVerificationCode;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @usernameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be less than 20 characters'**
  String get usernameMaxLength;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, and underscores'**
  String get usernameInvalidChars;

  /// No description provided for @smartWatch.
  ///
  /// In en, this message translates to:
  /// **'Smart Watch'**
  String get smartWatch;

  /// No description provided for @headphones.
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get headphones;

  /// No description provided for @letsTrade.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Trade?'**
  String get letsTrade;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(Object distance);

  /// No description provided for @noMatchesNearby.
  ///
  /// In en, this message translates to:
  /// **'No matches found nearby'**
  String get noMatchesNearby;

  /// No description provided for @noMatchesNearbyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try increasing your search radius or adding more interests to discover more products.'**
  String get noMatchesNearbyMessage;

  /// No description provided for @adjustSearchPreferences.
  ///
  /// In en, this message translates to:
  /// **'Adjust search preferences'**
  String get adjustSearchPreferences;

  /// No description provided for @noProductsToTrade.
  ///
  /// In en, this message translates to:
  /// **'No products to trade'**
  String get noProductsToTrade;

  /// No description provided for @noProductsToTradeMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to start trading with others nearby.'**
  String get noProductsToTradeMessage;

  /// No description provided for @addAProduct.
  ///
  /// In en, this message translates to:
  /// **'Add a product'**
  String get addAProduct;

  /// No description provided for @welcomeToDeals.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Deals'**
  String get welcomeToDeals;

  /// No description provided for @myVibesMatching.
  ///
  /// In en, this message translates to:
  /// **'My Vibes Matching'**
  String get myVibesMatching;

  /// No description provided for @matchedDeals.
  ///
  /// In en, this message translates to:
  /// **'Matched Deals'**
  String get matchedDeals;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back To Home'**
  String get backToHome;

  /// No description provided for @contactNow.
  ///
  /// In en, this message translates to:
  /// **'Contact {name} now'**
  String contactNow(Object name);

  /// No description provided for @addProfilePhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo (optional)'**
  String get addProfilePhotoOptional;

  /// No description provided for @learnWhatHappens.
  ///
  /// In en, this message translates to:
  /// **'Learn what happens when your number changes.'**
  String get learnWhatHappens;

  /// No description provided for @productFallback.
  ///
  /// In en, this message translates to:
  /// **'Product {id}'**
  String productFallback(Object id);

  /// No description provided for @showingProductsYouLiked.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} products you already liked'**
  String showingProductsYouLiked(Object count);

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get addButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @maxCannotExceed.
  ///
  /// In en, this message translates to:
  /// **'Max cannot exceed 1000'**
  String get maxCannotExceed;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @sar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get sar;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'The Wanted for the Unwanted'**
  String get tagline;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @byContinuingYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get byContinuingYouAgree;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andWord;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @locationRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'TapTrade needs your location to find nearby traders and show you products in your area.'**
  String get locationRequiredDescription;

  /// No description provided for @activateProduct.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateProduct;

  /// No description provided for @productInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get productInactive;

  /// No description provided for @productActivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product activated!'**
  String get productActivatedSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
