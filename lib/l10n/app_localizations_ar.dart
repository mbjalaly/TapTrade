// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تاب تريد';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get continueWithGoogle => 'المتابعة مع جوجل';

  @override
  String get continueWithApple => 'المتابعة مع آبل';

  @override
  String get verifyPhone => 'تأكيد الهاتف';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get enterOtp => 'أدخل رمز التحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendCodeIn(String seconds) {
    return 'إعادة إرسال الرمز خلال $seconds ثانية';
  }

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInToContinue => 'سجل دخولك للمتابعة';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get orContinueWith => 'أو تابع مع';

  @override
  String get enterPhoneNumber => 'أدخل رقم هاتفك';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String get didntReceiveCode => 'لم تستلم الرمز؟';

  @override
  String get verify => 'تأكيد';

  @override
  String get createNewPassword => 'إنشاء كلمة مرور جديدة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get chooseUsername => 'اختر اسم مستخدم';

  @override
  String get usernameHint => 'سيكون هذا معرفك الفريد';

  @override
  String get createPassword => 'إنشاء كلمة المرور';

  @override
  String get passwordRequirements => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get home => 'الرئيسية';

  @override
  String get explore => 'استكشاف';

  @override
  String get matches => 'التطابقات';

  @override
  String get chat => 'المحادثات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get more => 'المزيد';

  @override
  String get products => 'المنتجات';

  @override
  String get bazaar => 'البازار';

  @override
  String get noProductsFound => 'لا توجد منتجات';

  @override
  String get swipeLeftToSkip => 'اسحب لليسار للتخطي';

  @override
  String get swipeRightToLike => 'اسحب لليمين للإعجاب';

  @override
  String get itsAMatch => 'تطابق!';

  @override
  String youAndUserLikedEachOther(String username) {
    return 'أنت و$username أعجبتم بمنتجات بعضكم البعض';
  }

  @override
  String get sendMessage => 'إرسال رسالة';

  @override
  String get keepSwiping => 'استمر بالسحب';

  @override
  String get noMoreProducts => 'لا توجد منتجات أخرى';

  @override
  String get tryAgainLater => 'حاول مرة أخرى لاحقاً';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get selectProductsToTrade => 'اختر المنتجات للمقايضة';

  @override
  String get noProductsAvailable => 'لا توجد منتجات متاحة';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get closeProductSelector => 'إغلاق اختيار المنتجات';

  @override
  String get selectProducts => 'اختر المنتجات';

  @override
  String get searchFiltersTooltip => 'فلاتر البحث';

  @override
  String get noProductDataAvailable => 'لا توجد بيانات منتج متاحة';

  @override
  String get dealsNearYou => 'صفقات بالقرب منك';

  @override
  String swipeToExploreItems(int count) {
    return 'اسحب لاستكشاف $count عناصر';
  }

  @override
  String get noNewProductsNearby => 'لا توجد منتجات جديدة قريبة';

  @override
  String showingAlreadyLikedProducts(int count) {
    return 'عرض $count منتج أعجبت به مسبقاً';
  }

  @override
  String get addYourFirstProductShort => 'أضف أول منتج لك';

  @override
  String get listProductsToStartTrading =>
      'أضف منتجات للبدء في المقايضة مع الآخرين';

  @override
  String get noNearbyTrades => 'لا توجد صفقات قريبة';

  @override
  String get tryIncreasingSearchRadius => 'حاول زيادة نطاق البحث في الإعدادات';

  @override
  String get allProductsFiltered => 'تمت تصفية جميع المنتجات';

  @override
  String get tryAdjustingFilters => 'جرب تعديل الفلاتر لرؤية المزيد من الصفقات';

  @override
  String get noMatchesYetShort => 'لا توجد تطابقات بعد';

  @override
  String get checkBackSoon => 'تحقق قريباً من فرص المقايضة الجديدة';

  @override
  String get locationAccess => 'الوصول للموقع';

  @override
  String get unableToAccessLocation =>
      'تعذر الوصول إلى موقعك. قد تكون المنتجات غير دقيقة.';

  @override
  String get errorLoadingProducts => 'خطأ في تحميل المنتجات';

  @override
  String get checkInternetConnection =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get productTitle => 'عنوان المنتج';

  @override
  String get description => 'الوصف';

  @override
  String get minPrice => 'أقل سعر';

  @override
  String get maxPrice => 'أعلى سعر';

  @override
  String get category => 'الفئة';

  @override
  String get condition => 'حالة المنتج';

  @override
  String get quantity => 'الكمية';

  @override
  String get quantityAvailable => 'الكمية المتاحة';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get priceRange => 'نطاق السعر';

  @override
  String get status => 'الحالة';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get selectCondition => 'اختر حالة المنتج';

  @override
  String get productImages => 'صور المنتج';

  @override
  String get addImages => 'إضافة صور';

  @override
  String get editImages => 'تعديل الصور';

  @override
  String get myProducts => 'منتجاتي';

  @override
  String get deleteProduct => 'حذف المنتج';

  @override
  String get confirmDeleteProduct => 'هل أنت متأكد من حذف هذا المنتج؟';

  @override
  String get productNew => 'جديد';

  @override
  String get productUsed => 'مستعمل';

  @override
  String get productLikeNew => 'شبه جديد';

  @override
  String get productGood => 'جيد';

  @override
  String get productFair => 'مقبول';

  @override
  String get backToSwipe => 'العودة للتصفح';

  @override
  String get noProductsYet => 'لا توجد منتجات بعد';

  @override
  String get addYourFirstProductToGetStarted => 'أضف أول منتج لك للبدء';

  @override
  String get noActiveProducts => 'لا توجد منتجات نشطة';

  @override
  String youHaveProductsButNoneActive(int count) {
    return 'لديك $count منتج(ات) لكن لا يوجد منتج نشط';
  }

  @override
  String get completedDeals => 'الصفقات المكتملة';

  @override
  String get thisActionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get areYouSureDeleteProduct => 'هل أنت متأكد من حذف:';

  @override
  String get productDeletedSuccessfully => 'تم حذف المنتج بنجاح';

  @override
  String get failedToDeleteProduct => 'فشل حذف المنتج';

  @override
  String get errorOccurred => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logoutSuccessful => 'تم تسجيل الخروج بنجاح';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get confirmLogout => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get confirmDeleteAccount =>
      'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get bio => 'النبذة';

  @override
  String get addBio => 'إضافة نبذة';

  @override
  String get changeProfilePhoto => 'تغيير صورة الملف الشخصي';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get tradePreferences => 'تفضيلات المقايضة';

  @override
  String get tradeRadius => 'نطاق المقايضة';

  @override
  String get meetingPreference => 'تفضيل اللقاء';

  @override
  String get publicPlace => 'مكان عام';

  @override
  String get doorstep => 'عند الباب';

  @override
  String get locationPicker => 'اختيار الموقع';

  @override
  String get setYourLocation => 'حدد موقعك';

  @override
  String get searchFilters => 'فلاتر البحث';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get pushNotifications => 'الإشعارات الفورية';

  @override
  String get emailNotifications => 'إشعارات البريد الإلكتروني';

  @override
  String get matchNotifications => 'إشعارات التطابق';

  @override
  String get messageNotifications => 'إشعارات الرسائل';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get verifyPhoneNumber => 'تأكيد رقم الهاتف';

  @override
  String get profileInformation => 'الملف الشخصي';

  @override
  String get matchesAndChat => 'التطابقات والمحادثات';

  @override
  String get faqQuestions => 'الأسئلة الشائعة';

  @override
  String get termsAndPolicies => 'الشروط والسياسات';

  @override
  String get viewTutorial => 'عرض الدليل التعليمي';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get faqComingSoon => 'صفحة الأسئلة الشائعة قريباً';

  @override
  String get account => 'الحساب';

  @override
  String get likedProducts => 'المنتجات المفضلة';

  @override
  String get dislikedProducts => 'المنتجات المرفوضة';

  @override
  String get tradeHistory => 'سجل المقايضات';

  @override
  String get pendingTrades => 'المقايضات المعلقة';

  @override
  String get completedTrades => 'المقايضات المكتملة';

  @override
  String get tradeRequest => 'طلب مقايضة';

  @override
  String get sendTradeRequest => 'إرسال طلب مقايضة';

  @override
  String get acceptTrade => 'قبول المقايضة';

  @override
  String get rejectTrade => 'رفض المقايضة';

  @override
  String get tradeSent => 'تم إرسال طلب المقايضة';

  @override
  String get tradeAccepted => 'تم قبول المقايضة';

  @override
  String get tradeRejected => 'تم رفض المقايضة';

  @override
  String get tradeCompleted => 'تم إكمال المقايضة';

  @override
  String get deals => 'الصفقات';

  @override
  String get noDeals => 'لا توجد صفقات بعد';

  @override
  String get contactTrader => 'التواصل مع التاجر';

  @override
  String get messages => 'الرسائل';

  @override
  String get noMessages => 'لا توجد رسائل بعد';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get send => 'إرسال';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get typing => 'يكتب...';

  @override
  String get noMatchesYet => 'لا توجد تطابقات بعد';

  @override
  String get keepSwipingToFindMatches =>
      'استمر بالسحب للعثور على أشخاص يريدون المقايضة معك!';

  @override
  String get matchWord => 'تطابق';

  @override
  String get matchesWord => 'تطابقات';

  @override
  String get product => 'منتج';

  @override
  String get user => 'مستخدم';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get done => 'تم';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get skip => 'تخطي';

  @override
  String get continue_ => 'متابعة';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get ok => 'موافق';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get view => 'عرض';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'فلتر';

  @override
  String get sort => 'ترتيب';

  @override
  String get refresh => 'تحديث';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get pleaseTryAgain => 'يرجى المحاولة مرة أخرى';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkYourConnection => 'يرجى التحقق من اتصالك بالإنترنت';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get welcomeToTapTrade => 'مرحباً بك في تاب تريد';

  @override
  String get tutorialSwipe => 'اسحب عبر المنتجات';

  @override
  String get tutorialMatch => 'تطابق مع التجار';

  @override
  String get tutorialChat => 'تحدث ومقايضة';

  @override
  String get tutorialComplete => 'ابدأ المقايضة';

  @override
  String get letsGetStarted => 'لنبدأ';

  @override
  String get setupProfile => 'إعداد ملفك الشخصي';

  @override
  String get addYourFirstProduct => 'أضف منتجك الأول';

  @override
  String get setYourTradePreferences => 'حدد تفضيلات المقايضة';

  @override
  String get unit => 'وحدة';

  @override
  String get units => 'وحدات';

  @override
  String get km => 'كم';

  @override
  String get miles => 'ميل';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get approved => 'معتمد';

  @override
  String get rejected => 'مرفوض';

  @override
  String get away => 'بعيد';

  @override
  String distanceAway(String distance, String unit) {
    return '$distance $unit بعيد';
  }

  @override
  String get addLocation => 'إضافة الموقع';

  @override
  String get yourLocation => 'موقعك';

  @override
  String get addInterests => 'إضافة الاهتمامات';

  @override
  String get selectInterests => 'اختر اهتماماتك';

  @override
  String get addProfilePhoto => 'إضافة صورة الملف الشخصي';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get tradingWith => 'المقايضة مع';

  @override
  String get yourProduct => 'منتجك';

  @override
  String get theirProduct => 'منتجهم';

  @override
  String get viewProfile => 'عرض الملف الشخصي';

  @override
  String get startChat => 'بدء المحادثة';

  @override
  String get mutualMatches => 'التطابقات المتبادلة';

  @override
  String get noMutualMatchesYet => 'لا توجد تطابقات متبادلة بعد';

  @override
  String get welcomeToTapTradeExclaim => 'مرحباً بك في تاب تريد!';

  @override
  String get swipeToDiscover => 'اسحب للاكتشاف';

  @override
  String get swipeToDiscoverDesc =>
      'اسحب يميناً على العناصر التي تريد مقايضتها. اسحب يساراً للتخطي. تطابق مع المستخدمين الذين يريدون عناصرك!';

  @override
  String get listYourItems => 'أضف عناصرك';

  @override
  String get listYourItemsDesc =>
      'أضف صوراً وتفاصيل العناصر التي تريد مقايضتها. المزيد من العناصر يعني المزيد من التطابقات!';

  @override
  String get chatAndTrade => 'تحدث ومقايضة';

  @override
  String get chatAndTradeDesc =>
      'عندما تتطابق، تحدث مع التجار لترتيب عملية المقايضة. مقايضة محلية آمنة وسهلة!';

  @override
  String get youreAllSet => 'أنت جاهز!';

  @override
  String get youreAllSetDesc =>
      'ابدأ السحب وإضافة العناصر والتواصل مع التجار القريبين منك. مقايضة سعيدة!';

  @override
  String get pass => 'تخطي';

  @override
  String get like => 'إعجاب';

  @override
  String get subject => 'الموضوع';

  @override
  String get message => 'الرسالة';

  @override
  String get yourQuery => 'استفسارك...';

  @override
  String get yourMessage => 'رسالتك...';

  @override
  String get sendMessageAction => 'إرسال الرسالة';

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get weLoveToHear =>
      'نحب أن نسمع منك! يرجى ملء النموذج أدناه لطرح سؤال أو مشاركة أفكارك.';

  @override
  String get name => 'الاسم';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get gender => 'الجنس';

  @override
  String get contact => 'رقم الاتصال';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get other => 'آخر';

  @override
  String get alreadyVerified => 'تم التحقق';

  @override
  String get needVerification => 'يحتاج للتحقق';

  @override
  String get pleaseAddName => 'الرجاء إضافة الاسم';

  @override
  String get pleaseAddUserName => 'يرجى إضافة اسم المستخدم';

  @override
  String get pleaseSelectGender => 'الرجاء اختيار الجنس';

  @override
  String get pleaseAddContact => 'الرجاء إضافة رقم الهاتف';

  @override
  String get phoneNumberMustBe9Digits =>
      'يجب أن يكون رقم الهاتف 9 أرقام بالضبط';

  @override
  String get pleaseAddEmail => 'الرجاء إضافة البريد الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'الرجاء إدخال بريد إلكتروني صحيح';

  @override
  String get tradePreferencesTitle => 'تفضيلات المقايضة';

  @override
  String get yourLocationLabel => 'موقعك:';

  @override
  String get locationAutomatic => 'هذا موقعك التلقائي (لا يمكن تغييره)';

  @override
  String selectTradeRadius(int radius) {
    return 'اختر نطاق المقايضة: $radius كم';
  }

  @override
  String get meetingPreferenceLabel => 'تفضيل اللقاء:';

  @override
  String get deliveryPickup => 'توصيل/استلام';

  @override
  String get willingToShip => 'مستعد للشحن';

  @override
  String get pleaseSelectTradeRadius => 'يرجى اختيار نطاق المقايضة';

  @override
  String get notificationSettingsTitle => 'إعدادات الإشعارات';

  @override
  String get chooseNotifications => 'اختر الإشعارات التي تريد استلامها';

  @override
  String get marketingPromotions => 'التسويق والعروض';

  @override
  String get promotionalOffers => 'العروض الترويجية';

  @override
  String get soundHaptics => 'الصوت والاهتزاز';

  @override
  String get soundEffects => 'المؤثرات الصوتية';

  @override
  String get tradeUpdates => 'تحديثات المقايضة';

  @override
  String get canChangeAnytime => 'يمكنك تغيير هذه الإعدادات في أي وقت';

  @override
  String get cover => 'الغلاف';

  @override
  String get tapToSetCover => 'اضغط لتعيين الغلاف';

  @override
  String get noImages => 'لا توجد صور';

  @override
  String get atLeastOneImageRequired => 'مطلوب صورة واحدة على الأقل';

  @override
  String maximumImagesAllowed(int count) {
    return 'الحد الأقصى $count صور مسموح';
  }

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get title => 'العنوان';

  @override
  String get descriptionRequired => 'الوصف *';

  @override
  String get describeYourProduct => 'صف منتجك بالتفصيل';

  @override
  String get productUpdated => 'تم تحديث المنتج';

  @override
  String get updateFailed => 'فشل التحديث';

  @override
  String get productIdMissing => 'معرف المنتج مفقود';

  @override
  String get minPriceMustBeLess =>
      'يجب أن يكون الحد الأدنى للسعر أقل من الحد الأقصى';

  @override
  String get quantityMustBeBetween => 'الكمية يجب أن تكون بين 1 و 99';

  @override
  String get descriptionTooLong => 'الوصف طويل جداً (الحد الأقصى 500 حرف)';

  @override
  String get productDescriptionRequired => 'وصف المنتج مطلوب';

  @override
  String get pleaseEnterTitle => 'يرجى إدخال العنوان';

  @override
  String get createPasswordTitle => 'إنشاء كلمة مرور';

  @override
  String get makeItStrong => 'اجعلها قوية وآمنة.';

  @override
  String get passwordMustContain => 'يجب أن تحتوي كلمة المرور على:';

  @override
  String get atLeast8Characters => '8 أحرف على الأقل';

  @override
  String get oneUppercaseLetter => 'حرف كبير واحد (A-Z)';

  @override
  String get oneLowercaseLetter => 'حرف صغير واحد (a-z)';

  @override
  String get oneNumber => 'رقم واحد (0-9)';

  @override
  String get reEnterPassword => 'أعد إدخال كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get pleaseConfirmPassword => 'الرجاء تأكيد كلمة المرور';

  @override
  String get pleaseEnterPhoneFirst => 'الرجاء إدخال رقم هاتفك أولاً';

  @override
  String get pleaseMeetAllRequirements =>
      'يرجى استيفاء جميع متطلبات كلمة المرور';

  @override
  String get createYourUsername => 'أنشئ اسم المستخدم الخاص بك';

  @override
  String get enterUsername => 'أدخل اسم المستخدم';

  @override
  String get congratulations => 'تهانينا!';

  @override
  String get youAreGoodToTrade => 'أنت جاهز للمقايضة!';

  @override
  String get easiestWayToSwap =>
      'أسهل طريقة لمقايضة العناصر مع الأشخاص القريبين. بادل ما لديك بما تريد!';

  @override
  String get currencySymbol => 'ر.س';

  @override
  String priceRangeFormat(
      String minPrice, String maxPrice, Object max, Object min) {
    return '$min - $max ريال';
  }

  @override
  String get pleaseAddUsername => 'الرجاء إضافة اسم المستخدم';

  @override
  String get phoneMust9Digits => 'يجب أن يكون رقم الهاتف ٩ أرقام بالضبط';

  @override
  String get pleaseEnterEmail => 'الرجاء إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get loginFailed => 'فشل تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get errorCheckingUsername =>
      'خطأ في التحقق من اسم المستخدم. حاول مرة أخرى.';

  @override
  String get usernameAlreadyTaken => 'اسم المستخدم هذا مستخدم بالفعل';

  @override
  String get usernameAppearance =>
      'هذا هو الاسم الذي ستظهر به في تاب تريد. اختر بحكمة!';

  @override
  String get usernameHelper => 'أحرف وأرقام وشرطات سفلية فقط';

  @override
  String addAtLeastOnePhoto(int max) {
    return 'الرجاء إضافة صورة واحدة على الأقل (الحد الأقصى $max)';
  }

  @override
  String get pleaseEnterTitleAndCategory => 'الرجاء إدخال العنوان والفئة';

  @override
  String get pleaseEnterDescription => 'الرجاء إدخال وصف المنتج';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get pleaseAddPhotos => 'الرجاء إضافة صور';

  @override
  String get productSubmitted => 'تم إرسال المنتج';

  @override
  String get failedToSubmitProduct => 'فشل في إرسال المنتج';

  @override
  String get describeProductShort => 'صف منتجك في خمس كلمات';

  @override
  String get productAddedSuccessfully => 'تمت إضافة المنتج بنجاح';

  @override
  String get markTradeComplete => 'تأكيد إتمام المقايضة؟';

  @override
  String haveYouCompletedTrade(String username) {
    return 'هل أتممت هذه المقايضة مع $username؟ سيحتاج الطرف الآخر للتأكيد قبل إنهاء المقايضة.';
  }

  @override
  String get theyWillNeedToConfirm =>
      'سيحتاج الطرف الآخر للتأكيد قبل إنهاء المقايضة.';

  @override
  String get yesMarkComplete => 'نعم، تأكيد الإتمام';

  @override
  String get complete => 'مكتمل';

  @override
  String get tradeMarkedComplete => 'تم تأكيد إتمام المقايضة!';

  @override
  String get tradeMarkedWaiting =>
      'تم تأكيد إتمام المقايضة. بانتظار تأكيد الطرف الآخر.';

  @override
  String get tradeCompletedSuccess => 'تم إكمال المقايضة بنجاح!';

  @override
  String get tapProductToReveal =>
      'الرجاء الضغط على المنتج لكشف التطابق أولاً!';

  @override
  String get traderRevealedSuccess => 'تم كشف التاجر بنجاح!';

  @override
  String get requestCannotProceed =>
      'لا يمكن متابعة طلبك حالياً، يرجى المحاولة لاحقاً';

  @override
  String get errorTryAgainLater => 'حدث خطأ. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get markAsCompleted => 'تأكيد الإتمام';

  @override
  String get confirmTradeCompletion => 'تأكيد إتمام المقايضة؟';

  @override
  String get confirmTradeCompletionMessage =>
      'قام الطرف الآخر بتأكيد إتمام المقايضة. هل تؤكد أن المقايضة تم بنجاح؟';

  @override
  String get notYet => 'ليس بعد';

  @override
  String get yesConfirm => 'نعم، تأكيد';

  @override
  String get confirmCompletion => 'تأكيد الإتمام';

  @override
  String get waitingForConfirmation => 'بانتظار التأكيد...';

  @override
  String get tradeCompletedCheck => 'تم إكمال المقايضة';

  @override
  String get revealTrader => 'كشف المتداول';

  @override
  String get matchedDeal => 'صفقة متطابقة';

  @override
  String get termsComingSoon => 'قريباً';

  @override
  String get privacyComingSoon => 'قريباً';

  @override
  String get avatar => 'الصورة الرمزية';

  @override
  String get camera => 'كاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get pleaseEnterOtp => 'الرجاء إدخال رمز التحقق';

  @override
  String get pleaseEnterValid6DigitOtp =>
      'الرجاء إدخال رمز تحقق صحيح من 6 أرقام';

  @override
  String get otpResentSuccess => 'تم إعادة إرسال رمز التحقق بنجاح!';

  @override
  String get pleaseAddPhoneNumber => 'الرجاء إضافة رقم هاتفك';

  @override
  String otpSentTo(String phone) {
    return 'تم إرسال رمز التحقق إلى $phone';
  }

  @override
  String get phoneVerifiedAuto => 'تم التحقق من الهاتف تلقائياً!';

  @override
  String get startTypingToSearch => 'ابدأ الكتابة للبحث';

  @override
  String get searchCountry => 'البحث عن دولة';

  @override
  String verificationCodeSentTo(String phone) {
    return 'تم إرسال الرمز إلى $phone';
  }

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get confirmNewPasswordHint => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordResetSuccess => 'تم إعادة تعيين كلمة المرور بنجاح!';

  @override
  String get photos => 'الصور';

  @override
  String get details => 'التفاصيل';

  @override
  String get conditionAndPrice => 'الحالة والسعر';

  @override
  String get review => 'مراجعة';

  @override
  String get preview => 'معاينة';

  @override
  String get submit => 'إرسال';

  @override
  String get tapToSetCoverPhoto => 'اضغط لتعيين صورة الغلاف، اضغط مطولاً للعرض';

  @override
  String get enterShortTitle => 'أدخل عنواناً قصيراً';

  @override
  String get loadingCategories => 'جاري تحميل الفئات...';

  @override
  String get selectACategory => 'اختر فئة';

  @override
  String get describeProductDetail =>
      'صف منتجك بالتفصيل (مطلوب، الحد الأقصى 500 حرف)';

  @override
  String get pressSubmitToUpload => 'اضغط إرسال لرفع جميع العناصر';

  @override
  String get tapImagesToView => 'اضغط على الصور للعرض';

  @override
  String get noPhotosSelected => 'لم يتم اختيار صور';

  @override
  String photosSelected(int count) {
    return 'تم اختيار $count صور';
  }

  @override
  String get addProducts => 'إضافة منتجات';

  @override
  String get productConditionLabel => 'حالة المنتج';

  @override
  String get productTitleLabel => 'عنوان المنتج';

  @override
  String get productDescriptionLabel => 'وصف المنتج *';

  @override
  String get describeProductDetailRequired => 'صف منتجك بالتفصيل (مطلوب)';

  @override
  String get pleaseAddProductImage => 'الرجاء إضافة صورة المنتج';

  @override
  String get pleaseSelectProductCategory => 'الرجاء اختيار فئة المنتج';

  @override
  String get pleaseAddProductTitle => 'الرجاء إضافة عنوان المنتج';

  @override
  String get pleaseAddProductDescription => 'الرجاء إضافة وصف المنتج';

  @override
  String get pleaseAddProductQuantity => 'الرجاء إضافة كمية المنتج';

  @override
  String get pleaseEnterValidQuantity => 'الرجاء إدخال كمية صحيحة';

  @override
  String get pleaseAddMinPrice => 'الرجاء إضافة الحد الأدنى للسعر';

  @override
  String get pleaseAddMaxPrice => 'الرجاء إضافة الحد الأقصى للسعر';

  @override
  String productAddedCount(int current) {
    return 'تمت إضافة المنتج $current/3';
  }

  @override
  String pleaseAddThreeProducts(int current) {
    return 'الرجاء إضافة ثلاثة منتجات على الأقل $current/3';
  }

  @override
  String get noCategoriesAvailable => 'لا توجد فئات متاحة';

  @override
  String imagesCount(int count) {
    return '$count صور';
  }

  @override
  String get poor => 'سيء';

  @override
  String get minMustBeLessThanMax =>
      'الحد الأدنى يجب أن يكون أقل من الحد الأقصى';

  @override
  String get maxCannotExceed1000 => 'الحد الأقصى لا يمكن أن يتجاوز 1000';

  @override
  String get maxMustBeGreaterThanMin =>
      'الحد الأقصى يجب أن يكون أكبر من الحد الأدنى';

  @override
  String get startTheConversation => 'ابدأ المحادثة!';

  @override
  String get sayHelloAndDiscuss => 'قل مرحباً وناقش المقايضة.';

  @override
  String get matchDeals => 'صفقات التطابق';

  @override
  String get refusedMatches => 'المطابقات المرفوضة';

  @override
  String get failedToLoadRefusedMatches => 'فشل في تحميل التطابقات المرفوضة';

  @override
  String get noRefusedMatches => 'لا توجد تطابقات مرفوضة';

  @override
  String get swipeLeftAppearHere => 'المنتجات التي تسحبها لليسار ستظهر هنا';

  @override
  String get removeDislike => 'إزالة الرفض؟';

  @override
  String get removeDislikeMessage =>
      'سيكون هذا المنتج متاحاً للسحب مجدداً. يمكنك الإعجاب أو الرفض في المستقبل.';

  @override
  String get remove => 'إزالة';

  @override
  String get reEnable => 'إعادة تفعيل';

  @override
  String get unknown => 'غير معروف';

  @override
  String get likedDeals => 'الصفقات المعجبة';

  @override
  String productsYouLiked(int count) {
    return 'المنتجات التي أعجبتك ($count)';
  }

  @override
  String get noLikesYet => 'لا توجد إعجابات بعد';

  @override
  String get swipeProductsToLike => 'اسحب على المنتجات للإعجاب بها';

  @override
  String get almostThere => 'أوشكت على الانتهاء!';

  @override
  String get addPhoneRecoveryNotifications =>
      'أضف رقم هاتفك لاسترداد الحساب والإشعارات.';

  @override
  String get verifyYourPhone => 'تحقق من هاتفك';

  @override
  String get sendVerificationCodeMessage =>
      'سنرسل لك رمز تحقق لتأكيد رقم هاتفك.';

  @override
  String get country => 'الدولة';

  @override
  String get smsAgreement =>
      'بالمتابعة، أنت توافق على استقبال رسائل نصية للتحقق. قد تطبق رسوم الرسائل.';

  @override
  String get sendVerificationCode => 'إرسال رمز التحقق';

  @override
  String get backToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get enterPhoneResetPassword =>
      'أدخل رقم هاتفك وسنرسل لك رمز تحقق لإعادة تعيين كلمة المرور.';

  @override
  String get createNewPasswordTitle => 'إنشاء كلمة مرور جديدة';

  @override
  String get passwordDifferentFromPrevious =>
      'يجب أن تكون كلمة المرور الجديدة مختلفة عن كلمات المرور السابقة.';

  @override
  String get passwordMin6Chars => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get pleaseEnterNewPassword => 'الرجاء إدخال كلمة مرور جديدة';

  @override
  String get atLeast6Characters => '6 أحرف على الأقل';

  @override
  String get uppercaseLetterRecommended => 'حرف كبير (مستحسن)';

  @override
  String get numberSpecialCharRecommended => 'رقم أو رمز خاص (مستحسن)';

  @override
  String get tooWeak => 'ضعيفة جداً';

  @override
  String get weak => 'ضعيفة';

  @override
  String get good => 'جيدة';

  @override
  String get strong => 'قوية';

  @override
  String get images1to4 => 'الصور (1-4)';

  @override
  String get add => 'إضافة';

  @override
  String get processingPleaseWait => 'جاري المعالجة، يرجى الانتظار';

  @override
  String get chooseFromPhotos => 'اختيار من الصور';

  @override
  String get galleryMultiple => 'المعرض (متعدد)';

  @override
  String get nameLabel => 'الاسم:';

  @override
  String get userNameLabel => 'اسم المستخدم:';

  @override
  String get genderLabel => 'الجنس:';

  @override
  String get contactLabel => 'التواصل#:';

  @override
  String get emailLabel => 'البريد الإلكتروني:';

  @override
  String get continueButton => 'متابعة';

  @override
  String get otpError => 'خطأ في رمز التحقق';

  @override
  String get addYourPhoneNumber => 'أضف رقم هاتفك لاسترداد الحساب والإشعارات.';

  @override
  String get fair => 'مقبولة';

  @override
  String get weSentCodeTo => 'أرسلنا رمزاً إلى';

  @override
  String get yourProducts => 'منتجاتك';

  @override
  String get haveYouCompletedTradeInPerson => 'هل أتممت هذه المقايضة شخصياً؟';

  @override
  String get markAsComplete => 'تأكيد الإتمام';

  @override
  String get errorPrefix => 'خطأ: ';

  @override
  String get traders => 'المتداولين';

  @override
  String get all => 'الكل';

  @override
  String get favourites => 'المفضلة';

  @override
  String get archives => 'الأرشيف';

  @override
  String get pickLocation => 'اختر الموقع';

  @override
  String get use => 'استخدم';

  @override
  String get selectOneOfMyProducts => 'اختر أحد منتجاتي (اختياري)';

  @override
  String get allMyProducts => 'جميع منتجاتي';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get apply => 'تطبيق';

  @override
  String get defaultText => 'افتراضي';

  @override
  String get filterByMyProducts => 'تصفية حسب منتجاتي (متعدد)';

  @override
  String get onlyShowMatchesForOne => 'عرض المطابقات لمنتج واحد فقط';

  @override
  String get categories => 'الفئات';

  @override
  String get interests => 'الاهتمامات';

  @override
  String get radiusKm => 'النطاق (كم)';

  @override
  String productNumber(Object id) {
    return 'المنتج #$id';
  }

  @override
  String get interestsTitle => 'الاهتمامات';

  @override
  String get interestsDescription =>
      'أخبر الجميع بما تهتم به\\nعبر إضافته إلى ملفك الشخصي.';

  @override
  String get failedToLoadInterests => 'فشل في تحميل الاهتمامات';

  @override
  String continueWithCount(Object count, Object max) {
    return 'متابعة ($count/$max)';
  }

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get passwordResetSuccessfully => 'تم إعادة تعيين كلمة المرور بنجاح!';

  @override
  String get failedToResetPassword =>
      'فشل في إعادة تعيين كلمة المرور. حاول مرة أخرى.';

  @override
  String get errorOccurredTryAgain => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get pleaseEnterPhoneNumber => 'الرجاء إدخال رقم الهاتف';

  @override
  String get phoneNumber9Digits => 'يجب أن يكون رقم الهاتف 9 أرقام بالضبط';

  @override
  String get failedToSendVerificationCode => 'فشل في إرسال رمز التحقق';

  @override
  String get pleaseEnterUsername => 'الرجاء إدخال اسم مستخدم';

  @override
  String get usernameMinLength => 'يجب أن يكون اسم المستخدم 3 أحرف على الأقل';

  @override
  String get usernameMaxLength => 'يجب أن يكون اسم المستخدم أقل من 20 حرفاً';

  @override
  String get usernameInvalidChars =>
      'يمكن أن يحتوي اسم المستخدم على أحرف وأرقام وشرطات سفلية فقط';

  @override
  String get smartWatch => 'ساعة ذكية';

  @override
  String get headphones => 'سماعات';

  @override
  String get letsTrade => 'هل نتقايض؟';

  @override
  String kmAway(Object distance) {
    return '$distance كم';
  }

  @override
  String get noMatchesNearby => 'لا توجد مطابقات قريبة';

  @override
  String get noMatchesNearbyMessage =>
      'حاول زيادة نطاق البحث أو إضافة المزيد من الاهتمامات لاكتشاف المزيد من المنتجات.';

  @override
  String get adjustSearchPreferences => 'تعديل تفضيلات البحث';

  @override
  String get noProductsToTrade => 'لا توجد منتجات للمقايضة';

  @override
  String get noProductsToTradeMessage =>
      'أضف منتجك الأول لبدء المقايضة مع الآخرين القريبين.';

  @override
  String get addAProduct => 'إضافة منتج';

  @override
  String get welcomeToDeals => 'مرحباً بك في الصفقات';

  @override
  String get myVibesMatching => 'مطابقة اهتماماتي';

  @override
  String get matchedDeals => 'الصفقات المتطابقة';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String contactNow(Object name) {
    return 'تواصل مع $name الآن';
  }

  @override
  String get addProfilePhotoOptional => 'أضف صورة ملف شخصي (اختياري)';

  @override
  String get learnWhatHappens => 'تعرف على ما يحدث عند تغيير رقمك.';

  @override
  String productFallback(Object id) {
    return 'منتج $id';
  }

  @override
  String showingProductsYouLiked(Object count) {
    return 'عرض $count منتجات أعجبتك سابقاً';
  }

  @override
  String get addButton => '+ إضافة';

  @override
  String get saveButton => 'حفظ';

  @override
  String get maxCannotExceed => 'الحد الأقصى لا يمكن أن يتجاوز 1000';

  @override
  String get noTitle => 'بدون عنوان';

  @override
  String get sar => 'ريال';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get tagline => 'المطلوب لما لا تحتاجه';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get orDivider => 'أو';

  @override
  String get byContinuingYouAgree => 'بالمتابعة، أنت توافق على ';

  @override
  String get terms => 'الشروط';

  @override
  String get andWord => ' و ';

  @override
  String get enableLocation => 'تفعيل الموقع';

  @override
  String get locationRequiredDescription =>
      'يحتاج تاب تريد إلى موقعك للعثور على المتداولين القريبين وعرض المنتجات في منطقتك.';

  @override
  String get activateProduct => 'تفعيل';

  @override
  String get productInactive => 'غير نشط';

  @override
  String get productActivatedSuccess => 'تم تفعيل المنتج!';
}
