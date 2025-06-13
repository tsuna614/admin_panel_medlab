class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String medicalSpecialty;
  final String? qualifications;
  final int startingYear;
  final String? shortBio;
  final String? consultationFeeRange;
  final bool isVisibleToUsers;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.medicalSpecialty,
    this.qualifications,
    required this.startingYear,
    this.shortBio,
    this.consultationFeeRange,
    this.isVisibleToUsers = true,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      medicalSpecialty: json['medicalSpecialty'] as String,
      qualifications: json['qualifications'] as String?,
      startingYear: (json['startingYear'] as num).toInt(),
      shortBio: json['shortBio'] as String?,
      consultationFeeRange: json['consultationFeeRange'] as String?,
      isVisibleToUsers: json['isVisibleToUsers'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'medicalSpecialty': medicalSpecialty,
      'qualifications': qualifications,
      'startingYear': startingYear,
      'shortBio': shortBio,
      'consultationFeeRange': consultationFeeRange,
      'isVisibleToUsers': isVisibleToUsers,
    };
  }
}
