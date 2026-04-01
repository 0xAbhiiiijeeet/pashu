import 'package:flutter/material.dart';

/// App localization class that provides translated strings
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('hi', ''), // Hindi
  ];

  bool get isHindi => locale.languageCode == 'hi';
  bool get isEnglish => locale.languageCode == 'en';

  // ─────────────────────────────────────────────────────────────────────────
  // Common
  // ─────────────────────────────────────────────────────────────────────────

  String get appName => 'PashuMitra';

  String get continueText => isHindi ? 'जारी रखें' : 'Continue';
  String get save => isHindi ? 'दर्ज करें' : 'Save';
  String get cancel => isHindi ? 'रद्द करें' : 'Cancel';
  String get delete => isHindi ? 'हटाएं' : 'Delete';
  String get retry => isHindi ? 'पुनः प्रयास करें' : 'Retry';
  String get ok => isHindi ? 'ठीक है' : 'Ok';
  String get somethingWentWrong =>
      isHindi ? 'कुछ गलत हुआ है' : 'Something went wrong';

  // Bookings
  String yourCalls(int count) =>
      isHindi ? 'आपकी कॉल ($count)' : 'Your Calls ($count)';
  String get bookACall => isHindi ? 'कॉल बुक करें' : 'Book a call';
  String get noCallsBooked =>
      isHindi ? 'अभी तक कोई कॉल बुक नहीं की गई' : 'No calls booked yet';
  String get bookYourFirstCall =>
      isHindi ? 'अपनी पहली कॉल बुक करें' : 'Book your first call';
  String get theCallIsBooked =>
      isHindi ? 'कॉल बुक हो गई है!' : 'The call is booked!';
  String get callCompleted => isHindi ? 'कॉल पूरी हुई' : 'Call completed';
  String get callCancelled => isHindi ? 'कॉल रद्द की गई' : 'Call cancelled';
  String get friendWillCallYou =>
      isHindi ? 'मित्र आपको कॉल करेगा' : 'Friend will call you';
  String problem(String title) =>
      isHindi ? 'समस्या: $title' : 'Problem: $title';

  // Time slots
  String get between9amTo12pm =>
      isHindi ? 'सुबह 9 से दोपहर 12 बजे के बीच' : 'Between 9am-12pm';
  String get between12pmTo3pm =>
      isHindi ? 'दोपहर 12 से 3 बजे के बीच' : 'Between 12pm-3pm';
  String get between3pmTo6_30pm =>
      isHindi ? 'दोपहर 3 से शाम 6:30 बजे के बीच' : 'Between 3pm-6:30pm';
  String get loading => isHindi ? 'लोड हो रहा है...' : 'Loading...';
  String get error => isHindi ? 'त्रुटि' : 'Error';
  String get success => isHindi ? 'सफल' : 'Success';

  // ─────────────────────────────────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────────────────────────────────

  String get loginTitle => isHindi
      ? 'PashuMitra आपके पालतू जानवर का फिटनेस साथी'
      : "PashuMitra your pet's fitness partner";

  String get loginSubtitle => isHindi
      ? 'अपने सभी पशु संबंधी प्रश्नों के उत्तर पाने के लिए अपना नंबर दर्ज करें।'
      : 'Enter your number to get answers to all your animal related questions.';

  String get enterMobileNumber =>
      isHindi ? 'अपना मोबाइल नंबर दर्ज करें' : 'Enter your mobile number';

  String get trustedBy => isHindi
      ? '1 करोड़+ किसानों द्वारा विश्वसनीय'
      : 'Trusted by 1 crore+ farmers';

  String get terms => isHindi ? 'नियम' : 'Terms';
  String get privacy => isHindi ? 'गोपनीयता' : 'Privacy';
  String get pashuMitraTech =>
      isHindi ? 'पशु मित्र टेक्नोलॉजीज' : 'Pashu Mitra Technologies';

  String get enterOtp => isHindi ? 'OTP दर्ज करें' : 'Enter OTP';
  String get verifyOtp => isHindi ? 'OTP सत्यापित करें' : 'Verify OTP';
  String get changePhoneNumber =>
      isHindi ? 'फोन नंबर बदलें' : 'change phone number';
  String get didntReceiveOtp =>
      isHindi ? 'OTP नहीं मिला? पुनः भेजें' : "Didn't receive OTP? Resend";
  String didntReceiveOtpWithTimer(int seconds) => isHindi
      ? 'OTP नहीं मिला? पुनः भेजें (${seconds}s)'
      : "Didn't receive OTP? Resend (${seconds}s)";

  String get otpSentSuccess =>
      isHindi ? 'OTP सफलतापूर्वक भेजा गया' : 'OTP sent successfully';
  String get otpVerificationFailed =>
      isHindi ? 'OTP सत्यापन विफल' : 'OTP verification failed';
  String get failedToSendOtp =>
      isHindi ? 'OTP भेजने में विफल' : 'Failed to send OTP';

  // ─────────────────────────────────────────────────────────────────────────
  // Onboarding & Profile
  // ─────────────────────────────────────────────────────────────────────────

  String get name => isHindi ? 'नाम' : 'Name';
  String get nameHint => isHindi ? 'अपना नाम दर्ज करें' : 'Aditya';
  String get nameRequired => isHindi ? 'नाम आवश्यक है' : 'Name required';

  String get language => isHindi ? 'भाषा' : 'Language';
  String get languageHint => isHindi ? 'भाषा चुनें' : 'Hindi';

  String get yourAddress => isHindi ? 'आपका पता' : 'Your Address';
  String get addressHint => isHindi ? 'अपना पता लिखें' : 'Write your address';
  String get tellAddress => isHindi ? 'पता बताएं' : 'Tell address';
  String get addressChangeOnce => isHindi
      ? 'यह केवल एक बार बदला जा सकता है!'
      : 'This can only be changed once!';

  String get whatsappNo => isHindi ? 'व्हाट्सएप नंबर' : 'Whatsapp No.';
  String get phoneNo => isHindi ? 'फोन नंबर' : 'Phone No.';
  String get enterNumber => isHindi ? 'नंबर दर्ज करें' : 'Enter Number';
  String get whatsappMustBe10Digits => isHindi
      ? 'व्हाट्सएप नंबर 10 अंकों का होना चाहिए'
      : 'WhatsApp number must be 10 digits';

  String get birthday => isHindi ? 'जन्मदिन' : 'Birthday';
  String get selectBirthday => isHindi ? 'जन्मदिन चुनें' : 'Select birthday';

  String get work => isHindi ? 'काम' : 'Work';
  String get workHint => isHindi ? 'अपना व्यवसाय चुनें' : 'Select your work';

  String get education => isHindi ? 'पढ़ाई' : 'Education';
  String get educationHint =>
      isHindi ? 'अपनी शिक्षा बताएं' : 'Tell your education';

  String get animalCount => isHindi ? 'पशु संख्या' : 'Animal Count';
  String get animalCountHint =>
      isHindi ? 'अपने पशुओं की संख्या लिखें' : 'Enter number of animals';

  String get experience => isHindi ? 'पशुपालन का अनुभव' : 'Experience';
  String get experienceHint => isHindi
      ? 'कितने साल से कर रहे हैं बताएं'
      : 'How many years of experience';

  String get editProfile => isHindi ? 'प्रोफाइल संपादित करें' : 'Edit Profile';
  String get profile => isHindi ? 'प्रोफाइल' : 'Profile';
  String get edit => isHindi ? 'बदलें' : 'Edit';
  String get incomplete => isHindi ? 'अधूरा' : 'Incomplete';
  String get complete => isHindi ? 'पूर्ण' : 'Complete';
  String get india => isHindi ? 'भारत' : 'India';
  String get yourProfile => isHindi ? 'आपकी प्रोफाइल' : 'Your Profile';
  String get checkingForUpdates =>
      isHindi ? 'अपडेट जांच रहे हैं...' : 'Checking for updates...';
  String get appUpToDate =>
      isHindi ? 'आपका ऐप अप टू डेट है!' : 'Your app is up to date!';
  String get unableToCheckUpdates => isHindi
      ? 'अपडेट जांचने में असमर्थ। कृपया दोबारा कोशिश करें।'
      : 'Unable to check for updates. Please try again.';
  String get refundAndCancellation => isHindi
      ? 'रिफंड और रद्दीकरण'
      : 'Refund & Cancellation';
  String get allRightsReserved => isHindi
      ? '© 2026 पशु मित्र। सर्वाधिकार सुरक्षित।'
      : '© 2026 Pashu Mitra. All rights reserved.';

  // Subscription
  String get freeTrial =>
      isHindi ? '1 दिन का मुफ्त ट्रायल' : '1 day free trial';
  String get priceAfterTrial =>
      isHindi ? '1 दिन के बाद ₹999 प्रति माह' : '₹999 per month after 1 day';
  String get starting => isHindi ? 'शुरुआत' : 'Starting';
  String get ending => isHindi ? 'समाप्ति' : 'Ending';
  String get nextPaymentOn => isHindi
      ? 'अगला भुगतान XX फरवरी 2026 को होगा'
      : 'The next payment will be on XX February 2026';
  String get cancelSubscription => isHindi ? 'रद्द करें' : 'Cancel';

  // Menu Items
  String get tellFriends => isHindi ? 'दोस्तों को बताएं' : 'Tell Friends';
  String get talkToUs => isHindi ? 'हमसे बात करें' : 'Talk to Us';
  String get logout => isHindi ? 'लॉगआउट' : 'Logout';

  // Profile Picture
  String get camera => isHindi ? 'कैमरा' : 'Camera';
  String get gallery => isHindi ? 'गैलरी' : 'Gallery';
  String get removePhoto => isHindi ? 'फोटो हटाएं' : 'Remove Photo';
  String get profilePhotoUpdated =>
      isHindi ? 'प्रोफाइल फोटो अपडेट की गई' : 'Profile photo updated';
  String get failedToUploadPhoto =>
      isHindi ? 'फोटो अपलोड करने में विफल' : 'Failed to upload photo';
  String get failedToPickPhoto =>
      isHindi ? 'फोटो चुनने में विफल' : 'Failed to pick photo';

  // Share/Copy Link
  String get linkCopied => isHindi
      ? 'लिंक कॉपी किया गया! अपने दोस्तों के साथ शेयर करें'
      : 'Link copied! Share with your friends';
  String get failedToCopyLink =>
      isHindi ? 'लिंक कॉपी करने में विफल' : 'Failed to copy link';

  // WhatsApp
  String get couldNotOpenWhatsApp => isHindi
      ? 'व्हाट्सएप नहीं खोल सके। कृपया व्हाट्सएप इंस्टॉल करें।'
      : 'Could not open WhatsApp. Please install WhatsApp.';
  String get errorOpeningWhatsApp =>
      isHindi ? 'व्हाट्सएप खोलने में त्रुटि' : 'Error opening WhatsApp';

  // User-friendly error messages
  String get internetSlowTryAgain => isHindi
      ? 'आपका इंटरनेट धीमा लग रहा है। कृपया दोबारा कोशिश करें।'
      : 'Your internet seems slow. Please try again.';
  String get checkInternetConnection => isHindi
      ? 'कृपया अपना इंटरनेट कनेक्शन जांचें और दोबारा कोशिश करें।'
      : 'Please check your internet connection and try again.';
  String get otpIncorrectTryAgain => isHindi
      ? 'आपका OTP गलत है। कृपया जांचकर दोबारा कोशिश करें।'
      : 'The OTP you entered is incorrect. Please check and try again.';
  String get sessionExpiredLoginAgain => isHindi
      ? 'आपका सेशन समाप्त हो गया है। कृपया दोबारा लॉगिन करें।'
      : 'Your session has expired. Please login again.';
  String get subscriptionRequiredMessage => isHindi
      ? 'इस सुविधा के लिए आपको सक्रिय सदस्यता चाहिए। कृपया प्रोफाइल → सदस्यता में जाकर भुगतान पूरा करें।'
      : 'You need an active subscription to use this feature. Please go to Profile → Subscription to complete your payment.';
  String get serverTroubleMessage => isHindi
      ? 'हमारे सर्वर से जुड़ने में समस्या हो रही है। कृपया दोबारा कोशिश करें।'
      : 'We\'re having trouble connecting to our servers. Please try again.';
  String get securityIssueTryAgain => isHindi
      ? 'सुरक्षा की समस्या है। कृपया दोबारा कोशिश करें या सहायता से संपर्क करें।'
      : 'There\'s a security issue. Please try again or contact support.';
  String get somethingUnexpectedHappened => isHindi
      ? 'कुछ अप्रत्याशित हुआ है। कृपया दोबारा कोशिश करें।'
      : 'Something unexpected happened. Please try again.';
  String get appTakingLongerToStart => isHindi
      ? 'ऐप शुरू होने में अधिक समय लग रहा है। कृपया दोबारा कोशिश करें।'
      : 'App is taking longer to start. Please try again.';
  String get unableToSendOtp => isHindi
      ? 'OTP भेजने में असमर्थ। कृपया अपना नंबर जांचें और दोबारा कोशिश करें।'
      : 'Unable to send OTP. Please check your number and try again.';
  String get unableToVerifyOtp => isHindi
      ? 'OTP सत्यापित करने में असमर्थ। कृपया सही OTP दर्ज करें।'
      : 'Unable to verify OTP. Please enter the correct OTP.';
  String get unableToResendOtp => isHindi
      ? 'OTP दोबारा भेजने में असमर्थ। कृपया कुछ देर बाद कोशिश करें।'
      : 'Unable to resend OTP. Please try again in a moment.';
  String get unableToUpdateProfile => isHindi
      ? 'प्रोफाइल अपडेट करने में असमर्थ। कृपया दोबारा कोशिश करें।'
      : 'Unable to update your profile. Please try again.';
  String get unableToUploadPhoto => isHindi
      ? 'फोटो अपलोड करने में असमर्थ। कृपया दोबारा कोशिश करें।'
      : 'Unable to upload photo. Please try again.';
  String get unableToRefreshProfile => isHindi
      ? 'प्रोफाइल रिफ्रेश करने में असमर्थ। कृपया दोबारा कोशिश करें।'
      : 'Unable to refresh your profile. Please try again.';
  String get whatsappNotInstalled => isHindi
      ? 'व्हाट्सएप इंस्टॉल नहीं है। कृपया व्हाट्सएप इंस्टॉल करें।'
      : 'WhatsApp is not installed. Please install WhatsApp.';
  String get unableToOpenWhatsapp => isHindi
      ? 'व्हाट्सएप खोलने में असमर्थ। कृपया दोबारा कोशिश करें।'
      : 'Unable to open WhatsApp. Please try again.';
  String get unableToCompleteRegistration => isHindi
      ? 'पंजीकरण पूरा करने में असमर्थ। कृपया दोबारा कोशिश करें।'
      : 'Unable to complete registration. Please try again.';
  String get unableToStartSubscription => isHindi
      ? 'सदस्यता शुरू करने में असमर्थ। कृपया दोबारा कोशिश करें।'
      : 'Unable to start subscription. Please try again.';
  String get paymentProcessingIssue => isHindi
      ? 'भुगतान प्रक्रिया में समस्या। कृपया दोबारा कोशिश करें।'
      : 'Payment processing issue. Please try again.';
  String get unableToAddComment => isHindi
      ? 'टिप्पणी जोड़ने में असमर्थ। कृपया दोबारा कोशिश करें।'
      : 'Unable to add comment. Please try again.';

  // Comment Section
  String get addAComment => isHindi ? 'टिप्पणी जोड़ें...' : 'Add a comment...';
  String get commentAddedSuccessfully =>
      isHindi ? 'टिप्पणी सफलतापूर्वक जोड़ी गई' : 'Comment added successfully';
  String get failedToAddComment =>
      isHindi ? 'टिप्पणी जोड़ने में विफल' : 'Failed to add comment';
  String get justNow => isHindi ? 'अभी' : 'Just now';
  String minutesAgo(int minutes) =>
      isHindi ? '$minutesमिनट पहले' : '${minutes}m ago';
  String hoursAgo(int hours) => isHindi ? '$hoursघंटे पहले' : '${hours}h ago';
  String daysAgo(int days) => isHindi ? '$daysदिन पहले' : '${days}d ago';

  // Subscription Status
  String get active => isHindi ? 'सक्रिय' : 'Active';
  String get trial => isHindi ? 'ट्रायल' : 'Trial';
  String get halted => isHindi ? 'रोका गया' : 'Halted';
  String get cancelled => isHindi ? 'रद्द किया गया' : 'Cancelled';
  String get expired => isHindi ? 'समाप्त' : 'Expired';
  String get trialActive => isHindi ? '₹1 ट्रायल सक्रिय' : '₹1 Trial Active';
  String get pricePerYear => isHindi ? '₹999 / माह' : '₹999 / month';
  String get activeSubscription =>
      isHindi ? 'सक्रिय सदस्यता' : 'Active subscription';
  String get afterTrialPrice =>
      isHindi ? 'ट्रायल के बाद ₹999 प्रति माह' : '₹999 per month after trial';
  String trialEndsOn(String date) =>
      isHindi ? 'ट्रायल $date को समाप्त होगा' : 'Trial ends on $date';
  String nextPaymentOnDate(String date) =>
      isHindi ? 'अगला भुगतान $date को' : 'Next payment on $date';
  String totalPayments(int count) =>
      isHindi ? 'कुल भुगतान: $count' : 'Total payments: $count';
  String get subscribeNow => isHindi ? 'अभी सदस्यता लें' : 'Subscribe Now';
  String get subscribeForMoreBenefits =>
      isHindi ? 'सदस्यता लें और अधिक लाभ पाएं' : 'Subscribe for More Benefits';
  String get unlimitedCallsWithExperts =>
      isHindi ? '• विशेषज्ञों से असीमित कॉल' : '• Unlimited calls with experts';
  String get support24x7 =>
      isHindi ? '• 24/7 पशु स्वास्थ्य सहायता' : '• 24/7 animal health support';
  String get personalizedCareAdvice =>
      isHindi ? '• व्यक्तिगत देखभाल सलाह' : '• Personalized care advice';
  String get contactUsToCancel => isHindi
      ? 'सदस्यता रद्द करने के लिए हमसे संपर्क करें'
      : 'Contact us to cancel subscription';

  // Profile Refresh
  String get profileRefreshed =>
      isHindi ? 'प्रोफाइल अपडेट की गई' : 'Profile refreshed';
  String get failedToRefresh =>
      isHindi ? 'रिफ्रेश करने में विफल' : 'Failed to refresh';
  String get profileUpdatedSuccessfully => isHindi
      ? 'प्रोफाइल सफलतापूर्वक अपडेट की गई'
      : 'Profile updated successfully';
  String get failedToUpdateProfile =>
      isHindi ? 'प्रोफाइल अपडेट करने में विफल' : 'Failed to update profile';

  // Discard Changes Dialog
  String get discardChanges =>
      isHindi ? 'परिवर्तन छोड़ें?' : 'Discard changes?';
  String get goBackWithoutSaving => isHindi
      ? 'क्या आप बिना सहेजे वापस जाना चाहते हैं?'
      : 'Do you want to go back without saving?';
  String get discard => isHindi ? 'छोड़ें' : 'Discard';

  // Post Card
  String userProblem(String name) =>
      isHindi ? '$name ji की समस्या' : '$name ji\'s problem';
  String get animalFriendAnswer =>
      isHindi ? 'पशु मित्र का उत्तर' : 'Animal friend answer';
  String likes(int count) => isHindi ? '$count पसंद' : '$count Likes';
  String commentsCount(int count) =>
      isHindi ? '$count टिप्पणी' : '$count Comment';
  String get generalCategory => isHindi ? 'सामान्य' : 'General';

  // ─────────────────────────────────────────────────────────────────────────
  // Home
  // ─────────────────────────────────────────────────────────────────────────

  String get home => isHindi ? 'होम' : 'Home';

  String get callBookedTitle =>
      isHindi ? 'कॉल बुक हो गई!' : 'The call is booked!';
  String get friendWillCall =>
      isHindi ? 'मित्र आपको कॉल करेगा' : 'Friend will call you';

  String get toAvoidLosses =>
      isHindi ? 'नुकसान से बचने के लिए, ' : 'To avoid losses, ';
  String get callBookedWith => isHindi
      ? 'पशु मित्र के साथ कॉल बुक की गई'
      : 'Call Booked with Pashu Mitra';

  String get todayBetween => isHindi
      ? 'आज, सुबह 9 बजे - शाम 6:30 बजे के बीच'
      : 'Today, between 9am - 6:30 pm';

  String get savingsPerYear =>
      isHindi ? '₹10,000 प्रति वर्ष बचत' : '₹10,000 savings per year';
  String get extraEarnings => isHindi
      ? '₹1,500 प्रति माह अतिरिक्त कमाई'
      : '₹1,500 extra earnings per month';
  String get homeRemedy =>
      isHindi ? 'घरेलू उपचार, बिना खर्च के' : 'Home remedy, without spending';

  String get whatMitraTells => isHindi
      ? 'मित्र कॉल पर जो बताएगा, वह यहां ऐप में दिखेगा।'
      : 'What Mitra tells on call, will show here in app.';

  String get talkToPashuMitra =>
      isHindi ? 'पशु मित्र से बात करें' : 'Talk to Pashu Mitra';
  String get orSomethingElse => isHindi ? 'या कुछ और?' : 'or something else?';
  String get milkKhata => isHindi ? 'दूध खाता' : 'Milk Ledger';
  String get milkKhataSubtitle => isHindi
      ? 'ग्राहकों का दूध हिसाब रखें'
      : 'Keep customer milk records';

  String get animalProblems => isHindi ? 'पशु समस्याएं' : 'Animal Problems';

  String get failedToLoadProblems =>
      isHindi ? 'समस्याएं लोड करने में विफल' : 'Failed to load problems';
  String get noProblemsAvailable =>
      isHindi ? 'कोई समस्या उपलब्ध नहीं' : 'No problems available';

  // ─────────────────────────────────────────────────────────────────────────
  // Booking
  // ─────────────────────────────────────────────────────────────────────────

  String get bookCall => isHindi ? 'कॉल बुक करें' : 'Book Call';
  String get selectTimeSlot => isHindi ? 'समय स्लॉट चुनें' : 'Select Time Slot';
  String get confirmBooking =>
      isHindi ? 'बुकिंग की पुष्टि करें' : 'Confirm Booking';

  String get morning => isHindi ? 'सुबह' : 'Morning';
  String get afternoon => isHindi ? 'दोपहर' : 'Afternoon';
  String get evening => isHindi ? 'शाम' : 'Evening';

  String get between9to12 => isHindi ? '9am-12pm के बीच' : 'Between 9am-12pm';
  String get between12to3 => isHindi ? '12pm-3pm के बीच' : 'Between 12pm-3pm';
  String get between3to6 =>
      isHindi ? '3pm-6:30pm के बीच' : 'Between 3pm-6:30pm';

  String get bookingSuccess =>
      isHindi ? 'बुकिंग सफल रही!' : 'Booking successful!';
  String get bookingFailed => isHindi ? 'बुकिंग विफल रही' : 'Booking failed';

  String get myBookings => isHindi ? 'मेरी बुकिंग' : 'My bookings';
  String get bookedCalls => isHindi ? 'बुक की गई कॉल' : 'Booked Calls';
  String get completedCalls => isHindi ? 'पूर्ण की गई कॉल' : 'Completed Calls';
  String get noBookings => isHindi ? 'कोई बुकिंग नहीं' : 'No bookings yet';

  // ─────────────────────────────────────────────────────────────────────────
  // Q&A / Posts
  // ─────────────────────────────────────────────────────────────────────────

  String get quesAns => isHindi ? 'प्रश्न-उत्तर' : 'Ques-Ans';
  String get askQuestion => isHindi ? 'प्रश्न पूछें' : 'Ask Question';
  String get answer => isHindi ? 'उत्तर' : 'Answer';
  String get comments => isHindi ? 'टिप्पणियाँ' : 'Comments';
  String get addComment => isHindi ? 'टिप्पणी जोड़ें' : 'Add Comment';
  String get writeComment =>
      isHindi ? 'टिप्पणी लिखें...' : 'Write a comment...';
  String get post => isHindi ? 'पोस्ट करें' : 'Post';
  String get share => isHindi ? 'शेयर करें' : 'Share';

  String get noPostsAvailable =>
      isHindi ? 'कोई पोस्ट उपलब्ध नहीं' : 'No posts available';
  String get failedToLoadPosts =>
      isHindi ? 'पोस्ट लोड करने में विफल' : 'Failed to load posts';

  // ─────────────────────────────────────────────────────────────────────────
  // Dropdown Options
  // ─────────────────────────────────────────────────────────────────────────

  // Backend enum values - must match exactly
  List<String> get languageOptions =>
      isHindi ? ['अंग्रेज़ी', 'हिंदी'] : ['English', 'Hindi'];

  List<String> get workOptions => isHindi
      ? ['डेयरी का काम', 'किसान', 'व्यापारी', 'घर के लिए', 'अन्य']
      : ['Dairy work', 'Farmer', 'Businessman', 'For home', 'Other'];

  List<String> get educationOptions => isHindi
      ? [
          '5वीं',
          '6वीं',
          '7वीं',
          '8वीं',
          '9वीं',
          '10वीं',
          '11वीं',
          '12वीं',
          'अन्य'
        ]
      : ['5th', '6th', '7th', '8th', '9th', '10th', '11th', '12th', 'Other'];

  List<String> get experienceOptions => isHindi
      ? ['0-5 साल', '5-10 साल', '10-15 साल', '15-20 साल', '20+ साल']
      : ['0-5 Years', '5-10 Years', '10-15 Years', '15-20 Years', '20+ Years'];

  // ─────────────────────────────────────────────────────────────────────────
  // Marketplace
  // ─────────────────────────────────────────────────────────────────────────

  String get marketplace => isHindi ? 'बाज़ार' : 'Marketplace';
  String get buyCows => isHindi ? 'गाय खरीदें' : 'Buy Cows';
  String get sellCow => isHindi ? 'गाय बेचें' : 'Sell Cow';
  String get sellYourCow => isHindi ? 'अपनी गाय बेचें' : 'Sell Your Cow';
  String get noCowsAvailable => isHindi
      ? 'बिक्री के लिए कोई गाय उपलब्ध नहीं'
      : 'No cows available for sale';
  String get checkBackLater => isHindi
      ? 'नई लिस्टिंग के लिए बाद में जांचें'
      : 'Check back later for new listings';
  String get noCowsListed =>
      isHindi ? 'अभी तक कोई गाय सूचीबद्ध नहीं' : 'No cows listed yet';
  String get tapToGetStarted => isHindi
      ? 'शुरू करने के लिए "अपनी गाय बेचें" पर टैप करें'
      : 'Tap "Sell Your Cow" to get started';

  // Market Filters
  String get search => isHindi ? 'खोजें...' : 'Search...';
  String get searchBreed => isHindi ? 'नस्ल खोजें...' : 'Search breed...';
  String get maxPrice => isHindi ? 'अधिकतम कीमत:' : 'Max Price:';
  String get clear => isHindi ? 'हटाएं' : 'Clear';
  String get any => isHindi ? 'कोई भी' : 'Any';
  String get noCowsMatchFilters => isHindi
      ? 'आपके फिल्टर से कोई गाय मेल नहीं खाती।'
      : 'No cows match your filters.';

  // Cow Details
  String get breed => isHindi ? 'नस्ल' : 'Breed';
  String get age => isHindi ? 'उम्र' : 'Age';
  String get price => isHindi ? 'कीमत' : 'Price';
  String get milkYield => isHindi ? 'दूध उत्पादन' : 'Milk Yield';
  String get description => isHindi ? 'विवरण' : 'Description';
  String get images => isHindi ? 'तस्वीरें' : 'Images';
  String get sellerInformation =>
      isHindi ? 'विक्रेता की जानकारी' : 'Seller Information';
  String get cowImages => isHindi ? 'गाय की तस्वीरें' : 'Cow Images';

  String years(int count) => isHindi ? '$count साल' : '$count years';
  String litersPerDay(double liters) =>
      isHindi ? '$liters ली/दिन' : '${liters}L/day';

  // Upload Cow
  String get enterBreed => isHindi ? 'नस्ल दर्ज करें' : 'Enter breed';
  String get breedHint =>
      isHindi ? 'जैसे, गिर, साहीवाल, जर्सी' : 'e.g., Gir, Sahiwal, Jersey';
  String get ageYears => isHindi ? 'उम्र (साल)' : 'Age (years)';
  String get priceRupees => isHindi ? 'कीमत (₹)' : 'Price (₹)';
  String get milkYieldLiters =>
      isHindi ? 'दूध उत्पादन (लीटर/दिन)' : 'Milk Yield (Liters/day)';
  String get describeCow =>
      isHindi ? 'अपनी गाय का वर्णन करें...' : 'Describe your cow...';
  String get addImages =>
      isHindi ? 'तस्वीरें जोड़ें (आवश्यक)' : 'Add Images (Required)';
  String addMoreImages(int count) =>
      isHindi ? 'और तस्वीरें जोड़ें ($count/5)' : 'Add More Images ($count/5)';
  String get pleaseEnterBreed =>
      isHindi ? 'कृपया नस्ल दर्ज करें' : 'Please enter breed';
  String get pleaseEnterAge =>
      isHindi ? 'कृपया उम्र दर्ज करें' : 'Please enter age';
  String get pleaseEnterValidAge =>
      isHindi ? 'कृपया मान्य उम्र दर्ज करें' : 'Please enter valid age';
  String get pleaseEnterPrice =>
      isHindi ? 'कृपया कीमत दर्ज करें' : 'Please enter price';
  String get pleaseEnterValidPrice =>
      isHindi ? 'कृपया मान्य कीमत दर्ज करें' : 'Please enter valid price';
  String get pleaseEnterYield =>
      isHindi ? 'कृपया दूध उत्पादन दर्ज करें' : 'Please enter milk yield';
  String get pleaseEnterValidYield =>
      isHindi ? 'कृपया मान्य उत्पादन दर्ज करें' : 'Please enter valid yield';
  String get pleaseEnterDescription =>
      isHindi ? 'कृपया विवरण दर्ज करें' : 'Please enter description';
  String get pleaseAddAtLeastOneImage => isHindi
      ? 'कृपया कम से कम एक तस्वीर जोड़ें'
      : 'Please add at least one image';
  String get uploadingImages =>
      isHindi ? 'तस्वीरें अपलोड हो रही हैं...' : 'Uploading Images...';
  String get submitting => isHindi ? 'सबमिट हो रहा है...' : 'Submitting...';
  String get submitForApproval =>
      isHindi ? 'अनुमोदन के लिए सबमिट करें' : 'Submit for Approval';
  String get cowListingSubmitted => isHindi
      ? 'गाय की लिस्टिंग अनुमोदन के लिए सबमिट की गई'
      : 'Cow listing submitted for approval';
  String get failedToSubmitListing =>
      isHindi ? 'लिस्टिंग सबमिट करने में विफल' : 'Failed to submit listing';
  String get failedToUploadImages =>
      isHindi ? 'तस्वीरें अपलोड करने में विफल' : 'Failed to upload images';
  String get failedToPickImages =>
      isHindi ? 'तस्वीरें चुनने में विफल' : 'Failed to pick images';

  // Status
  String get pending => isHindi ? 'लंबित' : 'Pending';
  String get approved => isHindi ? 'स्वीकृत' : 'Approved';
  String get rejected => isHindi ? 'अस्वीकृत' : 'Rejected';
  String get sold => isHindi ? 'बिक गई' : 'Sold';

  // Contact
  String get call => isHindi ? 'कॉल करें' : 'Call';
  String get whatsapp => isHindi ? 'व्हाट्सएप' : 'WhatsApp';
  String get couldNotMakeCall =>
      isHindi ? 'कॉल नहीं कर सके' : 'Could not make call';

  // ─────────────────────────────────────────────────────────────────────────
  // Milk Calculator
  // ─────────────────────────────────────────────────────────────────────────

  String get milkCalculator => isHindi ? 'दूध कैलकुलेटर' : 'Milk Calculator';
  String get calculateDailyMilkIncome =>
      isHindi ? 'दैनिक दूध आय की गणना करें' : 'Calculate daily milk income';
  String get enterDetails => isHindi ? 'विवरण दर्ज करें' : 'Enter Details';
  String get numberOfAnimals =>
      isHindi ? 'पशुओं की संख्या' : 'Number of Animals';
  String get avgMilkPerAnimal =>
      isHindi ? 'प्रति पशु औसत दूध (ली)' : 'Avg Milk per Animal (L)';
  String get homeConsumption =>
      isHindi ? 'घरेलू उपयोग (ली)' : 'Home Consumption (L)';
  String get pricePerLiter =>
      isHindi ? 'प्रति लीटर कीमत (₹)' : 'Price per Liter (₹)';
  String get calculate => isHindi ? 'गणना करें' : 'Calculate';
  String get results => isHindi ? 'परिणाम' : 'Results';
  String get totalMilkProduced =>
      isHindi ? 'कुल दूध उत्पादन' : 'Total Milk Produced';
  String get milkSold => isHindi ? 'बेचा गया दूध' : 'Milk Sold';
  String get dailyIncome => isHindi ? 'दैनिक आय' : 'Daily Income';
  String get monthlyIncomeEst =>
      isHindi ? 'मासिक आय (अनुमानित)' : 'Monthly Income (Est.)';
  String get newCalculation => isHindi ? 'नई गणना' : 'New Calculation';
  String get calculationHistory =>
      isHindi ? 'गणना इतिहास' : 'Calculation History';
  String get noCalculationsYet =>
      isHindi ? 'अभी तक कोई गणना नहीं' : 'No calculations yet';
  String get startCalculating => isHindi
      ? 'गणना शुरू करने के लिए देखें'
      : 'Start calculating to see history';
  String get deleteCalculation => isHindi ? 'गणना हटाएं' : 'Delete Calculation';
  String get areYouSureDeleteCalculation => isHindi
      ? 'क्या आप इस गणना को हटाना चाहते हैं?'
      : 'Are you sure you want to delete this calculation?';
  String get calculationDeleted =>
      isHindi ? 'गणना हटा दी गई' : 'Calculation deleted';
  String get failedToDelete => isHindi ? 'हटाने में विफल' : 'Failed to delete';
  String get calculationFailed => isHindi ? 'गणना विफल' : 'Calculation failed';
  String get required => isHindi ? 'आवश्यक' : 'Required';
  String get enterValidNumber =>
      isHindi ? 'मान्य संख्या दर्ज करें' : 'Enter valid number';
  String get enterValidAmount =>
      isHindi ? 'मान्य राशि दर्ज करें' : 'Enter valid amount';
  String get enterValidPrice =>
      isHindi ? 'मान्य कीमत दर्ज करें' : 'Enter valid price';
  String get animals => isHindi ? 'पशु' : 'Animals';
  String get avgMilkAnimal => isHindi ? 'औसत दूध/पशु' : 'Avg Milk/Animal';
  String get totalProduced => isHindi ? 'कुल उत्पादन' : 'Total Produced';
  String get homeUse => isHindi ? 'घरेलू उपयोग' : 'Home Use';
  String get milkSoldTitle =>
      isHindi ? 'कितना दूध बेचा' : 'Milk Sales';
  String get milkSoldSubtitle => isHindi
      ? 'आज ग्राहकों को बेचा गया दूध दर्ज करें'
      : 'Record the milk sold to customers today';
  String get addCustomer =>
      isHindi ? 'ग्राहक जोड़ें' : 'Add Customer';
  String get milkLedgerTitle =>
      isHindi ? 'दूध का हिसाब' : 'Milk Ledger';
  String get addMilkEntry =>
      isHindi ? 'दूध एंट्री जोड़ें' : 'Add Milk Entry';
  String get noEntriesForDay => isHindi
      ? 'इस दिन के लिए कोई ग्राहक प्रविष्टि नहीं मिली'
      : 'No customer entries found for this day';
  String get saveRecord =>
      isHindi ? 'रिकॉर्ड सहेजें' : 'Save Record';
  String get failedToSaveRecord =>
      isHindi ? 'रिकॉर्ड सहेजने में असफल' : 'Failed to save record';

  // ─────────────────────────────────────────────────────────────────────────
  // Booking Bottom Sheet
  // ─────────────────────────────────────────────────────────────────────────

  String get talkTo => isHindi ? 'बात करें' : 'Talk to';
  String get mitr => isHindi ? 'मित्र' : 'MITR';
  String get availability9to6 =>
      isHindi ? 'सुबह 9 से शाम 6:30 बजे उपलब्धता' : '9am - 6:30pm Availability';
  String get tenYearsExperience =>
      isHindi ? '10 साल का अनुभव' : '10 years experience';
  String get exactSolution => isHindi ? 'सटीक समाधान' : 'exact solution';
  String get timeIsUpToday => isHindi
      ? 'आज का समय समाप्त हो गया भाई। कल के लिए बुक करें।'
      : 'Time is up today brother. Book for tomorrow.';
  String get whatTimeToTalk => isHindi
      ? 'आप किस समय बात करना चाहते हैं?'
      : 'What time do you want to talk?';
  String get tomorrow => isHindi ? 'कल' : 'Tomorrow';
  String get unableToBookCall => isHindi
      ? 'कॉल बुक करने में असमर्थ। कृपया दोबारा कोशिश करें।'
      : 'Unable to book call. Please try again.';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
