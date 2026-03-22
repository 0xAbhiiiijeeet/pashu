class ProfileDetails {
  final String? language;
  final String? address;
  final bool? addressLocked;
  final String? whatsAppNumber;
  final String? work;
  final String? education;
  final String? experienceYears;
  final DateTime? birthday;
  final int? animalCount;

  const ProfileDetails({
    this.language,
    this.address,
    this.addressLocked,
    this.whatsAppNumber,
    this.work,
    this.education,
    this.experienceYears,
    this.birthday,
    this.animalCount,
  });

  factory ProfileDetails.fromJson(Map<String, dynamic> json) {
    // Handle experienceYears - can be string, int, or null
    String? experienceYears;
    try {
      final expValue = json['experienceYears'];
      if (expValue != null && expValue != '') {
        experienceYears = expValue.toString();
      }
    } catch (e) {
      print('⚠️ Error parsing experienceYears: $e');
    }
    
    // Handle birthday/dob - backend uses 'dob', but we keep 'birthday' internally
    DateTime? birthday;
    try {
      final dobValue = json['dob'] ?? json['birthday'];
      if (dobValue != null) {
        birthday = DateTime.tryParse(dobValue as String);
      }
    } catch (e) {
      print('⚠️ Error parsing dob/birthday: $e');
    }
    
    return ProfileDetails(
      language: json['language'] as String?,
      address: json['address'] as String?,
      addressLocked: json['addressLocked'] as bool?,
      whatsAppNumber: json['whatsAppNumber'] as String?,
      work: json['work'] as String?,
      education: json['education'] as String?,
      experienceYears: experienceYears,
      birthday: birthday,
      animalCount: json['animalCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (language != null) 'language': language,
        if (address != null) 'address': address,
        if (addressLocked != null) 'addressLocked': addressLocked,
        if (whatsAppNumber != null) 'whatsAppNumber': whatsAppNumber,
        if (work != null) 'work': work,
        if (education != null) 'education': education,
        if (experienceYears != null) 'experienceYears': experienceYears,
        if (birthday != null) 'dob': birthday!.toIso8601String(), // Save as 'dob' for backend
        if (animalCount != null) 'animalCount': animalCount,
      };

  ProfileDetails copyWith({
    String? language,
    String? address,
    bool? addressLocked,
    String? whatsAppNumber,
    String? work,
    String? education,
    String? experienceYears,
    DateTime? birthday,
    int? animalCount,
  }) =>
      ProfileDetails(
        language: language ?? this.language,
        address: address ?? this.address,
        addressLocked: addressLocked ?? this.addressLocked,
        whatsAppNumber: whatsAppNumber ?? this.whatsAppNumber,
        work: work ?? this.work,
        education: education ?? this.education,
        experienceYears: experienceYears ?? this.experienceYears,
        birthday: birthday ?? this.birthday,
        animalCount: animalCount ?? this.animalCount,
      );
}

class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? profilePic;
  final String role;
  final bool onboardingComplete;
  final ProfileDetails? profileDetails;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.profilePic,
    required this.role,
    required this.onboardingComplete,
    this.profileDetails,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Debug logging
    print('🔍 Parsing UserModel from JSON: $json');
    
    // Safely get ID
    final id = (json['_id'] as String?) ?? (json['id'] as String?) ?? '';
    if (id.isEmpty) {
      print('⚠️ Warning: User ID is empty or null');
    }
    
    // Safely get phone number
    final phoneNumber = json['phoneNumber'] as String? ?? '';
    if (phoneNumber.isEmpty) {
      print('⚠️ Warning: Phone number is empty or null');
    }
    
    return UserModel(
      id: id,
      phoneNumber: phoneNumber,
      name: json['name'] as String?,
      profilePic: json['profilePic'] as String?,
      role: json['role'] as String? ?? 'user',
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      profileDetails: json['profileDetails'] != null
          ? ProfileDetails.fromJson(
              json['profileDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'phoneNumber': phoneNumber,
        if (name != null) 'name': name,
        if (profilePic != null) 'profilePic': profilePic,
        'role': role,
        'onboardingComplete': onboardingComplete,
        if (profileDetails != null) 'profileDetails': profileDetails!.toJson(),
      };

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? profilePic,
    String? role,
    bool? onboardingComplete,
    ProfileDetails? profileDetails,
  }) =>
      UserModel(
        id: id ?? this.id,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        name: name ?? this.name,
        profilePic: profilePic ?? this.profilePic,
        role: role ?? this.role,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        profileDetails: profileDetails ?? this.profileDetails,
      );

  bool get isAdmin => role == 'admin';
}
