import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a buyer's interest, visit details, negotiation status, and proof uploads per timeline step
class Buyer {
  final String name;
  final String phone;
  DateTime? date;
  double? priceOffered;

  /// 'pending', 'visited', 'negotiating', 'accepted', or 'rejected'
  String status;

  /// which timeline step this buyer is currently at (one of the short names)
  String currentStep;

  List<String> notes;
  DateTime? lastUpdated;

  // proof URLs for each step
  final List<String> interestDocs;
  final List<String> docVerifyDocs;
  final List<String> legalCheckDocs;
  final List<String> agreementDocs;
  final List<String> registrationDocs;
  final List<String> mutationDocs;
  final List<String> possessionDocs;

  Buyer({
    required this.name,
    required this.phone,
    this.date,
    this.priceOffered,
    this.status = 'pending',
    this.currentStep = 'Interest',
    this.notes = const [],
    this.lastUpdated,
    List<String>? interestDocs,
    List<String>? docVerifyDocs,
    List<String>? legalCheckDocs,
    List<String>? agreementDocs,
    List<String>? registrationDocs,
    List<String>? mutationDocs,
    List<String>? possessionDocs,
  })  : interestDocs = interestDocs ?? [],
        docVerifyDocs = docVerifyDocs ?? [],
        legalCheckDocs = legalCheckDocs ?? [],
        agreementDocs = agreementDocs ?? [],
        registrationDocs = registrationDocs ?? [],
        mutationDocs = mutationDocs ?? [],
        possessionDocs = possessionDocs ?? [];

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'phone': phone,
      'status': status,
      'currentStep': currentStep,
      'notes': notes,
      'priceOffered': priceOffered,
      'interestDocs': interestDocs,
      'docVerifyDocs': docVerifyDocs,
      'legalCheckDocs': legalCheckDocs,
      'agreementDocs': agreementDocs,
      'registrationDocs': registrationDocs,
      'mutationDocs': mutationDocs,
      'possessionDocs': possessionDocs,
    };
    if (date != null) map['date'] = Timestamp.fromDate(date!);
    if (lastUpdated != null)
      map['lastUpdated'] = Timestamp.fromDate(lastUpdated!);
    return map;
  }

  /// Create Buyer from Firestore map
  factory Buyer.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final rawUpdated = map['lastUpdated'];
    return Buyer(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] ?? 'pending',
      currentStep: map['currentStep'] ?? 'Interest',
      notes: List<String>.from(map['notes'] ?? []),
      priceOffered: (map['priceOffered'] as num?)?.toDouble(),
      date: rawDate is Timestamp ? rawDate.toDate() : null,
      lastUpdated: rawUpdated is Timestamp ? rawUpdated.toDate() : null,
      interestDocs: List<String>.from(map['interestDocs'] ?? []),
      docVerifyDocs: List<String>.from(map['docVerifyDocs'] ?? []),
      legalCheckDocs: List<String>.from(map['legalCheckDocs'] ?? []),
      agreementDocs: List<String>.from(map['agreementDocs'] ?? []),
      registrationDocs: List<String>.from(map['registrationDocs'] ?? []),
      mutationDocs: List<String>.from(map['mutationDocs'] ?? []),
      possessionDocs: List<String>.from(map['possessionDocs'] ?? []),
    );
  }
}
