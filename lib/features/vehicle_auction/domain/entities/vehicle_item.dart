import 'package:equatable/equatable.dart';

/// Vehicle item entity representing a vehicle in an auction
class VehicleItem extends Equatable {
  final String id;
  final String auctionId;
  final String contractNo;
  final String rcNo;
  final String make;
  final String model;
  final String chassisDesc;
  final String engineNo;
  final String chassisNo;
  final int yom; // Year of Manufacture
  final String fuelType;
  final String ppt;
  final String yardName;
  final String yardCity;
  final String yardState;
  final double basePrice;
  final double bidIncrement;
  final double multipleAmount;
  final double currentBid;
  final String? winnerId;
  final double? winningBid;
  final List<String> images;
  final String? vahanUrl;
  final String? contactPerson;
  final String? contactNumber;
  final String? remark;
  final bool rcAvailable;
  final DateTime? repoDate; // Repossession date
  final DateTime? startDate; // Override auction dates
  final DateTime? endDate;
  final String status; // upcoming, live, ended, sold
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleItem({
    required this.id,
    required this.auctionId,
    required this.contractNo,
    required this.rcNo,
    required this.make,
    required this.model,
    this.chassisDesc = '',
    required this.engineNo,
    required this.chassisNo,
    required this.yom,
    required this.fuelType,
    this.ppt = '',
    required this.yardName,
    required this.yardCity,
    required this.yardState,
    required this.basePrice,
    required this.bidIncrement,
    this.multipleAmount = 0,
    this.currentBid = 0,
    this.winnerId,
    this.winningBid,
    this.images = const [],
    this.vahanUrl,
    this.contactPerson,
    this.contactNumber,
    this.remark,
    this.rcAvailable = false,
    this.repoDate,
    this.startDate,
    this.endDate,
    this.status = 'upcoming',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the full vehicle description
  String get fullDescription => '$make $model ${chassisDesc.isNotEmpty ? '- $chassisDesc' : ''}';

  /// Get the location string
  String get location => '$yardCity, $yardState';

  /// Check if vehicle has a winner
  bool get hasWinner => winnerId != null && winnerId!.isNotEmpty;

  /// Get number of images
  int get imageCount => images.length;

  /// Check if vehicle has images
  bool get hasImages => images.isNotEmpty;

  /// Copy with method for immutable updates
  VehicleItem copyWith({
    String? id,
    String? auctionId,
    String? contractNo,
    String? rcNo,
    String? make,
    String? model,
    String? chassisDesc,
    String? engineNo,
    String? chassisNo,
    int? yom,
    String? fuelType,
    String? ppt,
    String? yardName,
    String? yardCity,
    String? yardState,
    double? basePrice,
    double? bidIncrement,
    double? multipleAmount,
    double? currentBid,
    String? winnerId,
    double? winningBid,
    List<String>? images,
    String? vahanUrl,
    String? contactPerson,
    String? contactNumber,
    String? remark,
    bool? rcAvailable,
    DateTime? repoDate,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleItem(
      id: id ?? this.id,
      auctionId: auctionId ?? this.auctionId,
      contractNo: contractNo ?? this.contractNo,
      rcNo: rcNo ?? this.rcNo,
      make: make ?? this.make,
      model: model ?? this.model,
      chassisDesc: chassisDesc ?? this.chassisDesc,
      engineNo: engineNo ?? this.engineNo,
      chassisNo: chassisNo ?? this.chassisNo,
      yom: yom ?? this.yom,
      fuelType: fuelType ?? this.fuelType,
      ppt: ppt ?? this.ppt,
      yardName: yardName ?? this.yardName,
      yardCity: yardCity ?? this.yardCity,
      yardState: yardState ?? this.yardState,
      basePrice: basePrice ?? this.basePrice,
      bidIncrement: bidIncrement ?? this.bidIncrement,
      multipleAmount: multipleAmount ?? this.multipleAmount,
      currentBid: currentBid ?? this.currentBid,
      winnerId: winnerId ?? this.winnerId,
      winningBid: winningBid ?? this.winningBid,
      images: images ?? this.images,
      vahanUrl: vahanUrl ?? this.vahanUrl,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      remark: remark ?? this.remark,
      rcAvailable: rcAvailable ?? this.rcAvailable,
      repoDate: repoDate ?? this.repoDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        auctionId,
        contractNo,
        rcNo,
        make,
        model,
        chassisDesc,
        engineNo,
        chassisNo,
        yom,
        fuelType,
        ppt,
        yardName,
        yardCity,
        yardState,
        basePrice,
        bidIncrement,
        multipleAmount,
        currentBid,
        winnerId,
        winningBid,
        images,
        vahanUrl,
        contactPerson,
        contactNumber,
        remark,
        rcAvailable,
        repoDate,
        startDate,
        endDate,
        status,
        isActive,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() => 'VehicleItem(id: $id, make: $make, model: $model)';
}
