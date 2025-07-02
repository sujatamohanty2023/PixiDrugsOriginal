class DoctorProfileModel {
  final int? doctorId;
  final int? userId;
  final String? clinicName;
  final String? clinicAddress;
  final int? experienceYears;
  final String? biography;
  final String? consultationFee;
  final String? onlineFee;
  final String? regNo;
  final List<String>? images;
  final String? expireDate;
  final String? userName;
  final String? profile;
  final String? userEmail;
  final String? userRole;
  final String? latitude;
  final String? longitude;
  final int? totalAppointments;
  final String? confirmedAppointments;
  final String? completedAppointments;
  final String? pendingAppointments;
  final double? totalOfflineRevenue;
  final double? totalOnlineRevenue;
  final double? totalRevenue;
  final List<Schedule>? schedules;
  final List<Education>? educations;
  final List<Experience>? experiences;
  final List<Specialization>? specializations;
  final List<Review>? reviews;

  DoctorProfileModel({
    this.doctorId = 0,
    this.userId = 0,
    this.clinicName = '',
    this.clinicAddress = '',
    this.experienceYears = 0,
    this.biography = '',
    this.consultationFee = '',
    this.onlineFee = '',
    this.regNo = '',
    this.images = const [],
    this.expireDate = '',
    this.userName = '',
    this.profile = '',
    this.userEmail = '',
    this.userRole = '',
    this.latitude = '',
    this.longitude = '',
    this.totalAppointments = 0,
    this.confirmedAppointments = '',
    this.completedAppointments = '',
    this.pendingAppointments = '',
    this.totalOfflineRevenue = 0.0,
    this.totalOnlineRevenue = 0.0,
    this.totalRevenue = 0.0,
    this.schedules = const [],
    this.educations = const [],
    this.experiences = const [],
    this.specializations = const [],
    this.reviews = const [],
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      doctorId: json['doctor_id'],
      userId: json['user_id'],
      clinicName: json['clinic_name'],
      clinicAddress: json['clinic_address'],
      experienceYears: json['experience_years'],
      biography: json['biography'],
      consultationFee: json['consultation_fee'],
      onlineFee: json['onlinefee'],
      regNo: json['reg_no'],
      images: List<String>.from(json['images']),
      expireDate: json['expire_date'],
      userName: json['user_name'],
      profile: json['profile'],
      userEmail: json['user_email'],
      userRole: json['user_role'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      totalAppointments: json['total_appointments'],
      confirmedAppointments: json['confirmed_appointments'],
      completedAppointments: json['completed_appointments'],
      pendingAppointments: json['pending_appointments'],
      totalOfflineRevenue: json['total_offline_revenue'].toDouble(),
      totalOnlineRevenue: json['total_online_revenue'].toDouble(),
      totalRevenue: json['total_revenue'].toDouble(),
      schedules: (json['schedules'] as List)
          .map((item) => Schedule.fromJson(item))
          .toList(),
      educations: (json['educations'] as List)
          .map((item) => Education.fromJson(item))
          .toList(),
      experiences: (json['experiences'] as List)
          .map((item) => Experience.fromJson(item))
          .toList(),
      specializations: (json['specializations'] as List)
          .map((item) => Specialization.fromJson(item))
          .toList(),
      reviews: (json['reviews'] as List)
          .map((item) => Review.fromJson(item))
          .toList(),
    );
  }
}

class Schedule {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String startTimeA;
  final String endTimeA;
  final String startTimeE;
  final String endTimeE;

  Schedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.startTimeA,
    required this.endTimeA,
    required this.startTimeE,
    required this.endTimeE,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      dayOfWeek: json['day_of_week']??'',
      startTime: json['start_time']??'',
      endTime: json['end_time']??'',
      startTimeA: json['start_time_a']??'',
      endTimeA: json['end_time_a']??'',
      startTimeE: json['start_time_e']??'',
      endTimeE: json['end_time_e']??'',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'start_time_a': startTimeA,
      'end_time_a': endTimeA,
      'start_time_e': startTimeE,
      'end_time_e': endTimeE,
    };
  }
}

class Education {
  final String degree;
  final String college;
  final String yearPass;

  Education({
    required this.degree,
    required this.college,
    required this.yearPass,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degree: json['degree'],
      college: json['college'],
      yearPass: json['year_pass'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'college': college,
      'year_pass': yearPass,
    };
  }
}

class Experience {
  final String designation;
  final String hospitalName;
  final String fromDate;
  final String toDate;

  Experience({
    required this.designation,
    required this.hospitalName,
    required this.fromDate,
    required this.toDate,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      designation: json['designation'],
      hospitalName: json['hospital_name'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'designation': designation,
      'hospital_name': hospitalName,
      'from_date': fromDate,
      'to_date': toDate,
    };
  }
}

class Specialization {
  final int id;
  final String name;

  Specialization({
    required this.id,
    required this.name,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Review {
  final int patientId;
  final int rating;
  final String reviewText;

  Review({
    required this.patientId,
    required this.rating,
    required this.reviewText,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      patientId: json['patient_id'],
      rating: json['rating'],
      reviewText: json['review_text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'rating': rating,
      'review_text': reviewText,
    };
  }
}