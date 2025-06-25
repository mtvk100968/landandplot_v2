//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:landandplot/models/property_type.dart';

class Amenities {
  final String id;
  final String propertyId;
  final PropertyType propertyType;

  // Plot / Agri / Farm
  final bool? fencing;
  final bool? gate;
  final bool? bore;
  final bool? pipeline;
  final bool? electricity;
  final bool? plantation;

  // House / Villa / Apartment (existing)
  final bool? waterGhmc;
  final bool? gasPipeline;
  final bool? garden;
  final bool? swimmingPool;
  final bool? playingArea;
  final bool? clubHouse;
  final bool? shoppingCenter;

  // House / Villa / Apartment (new)
  final String bedrooms;
  final String bathrooms;
  final String parkingSpots;
  final String lift;
  final String security;
  final String powerBackup;

  // House / Villa / Apartment (new)
  // final bool? inUnitWasherDryer;
  // final bool? dishwasher;
  // final bool? microwave;
  final bool? stainlessSteelAppliances;
  final bool? cableAndHighSpeedInternetReady;
  final bool? ceilingFans;
  final bool? centralHeatingAndAirConditioning;
  final bool? onSiteFitnessCenter;
  final bool? controlledAccessEntry;
  final bool? elevatorAccess;
  final bool? coveredOrGarageParking;
  final bool? parkingForGuests;
  final bool? petFriendlyAreasOrDogWashStation;
  final bool? onSiteManagementAndMaintenance;
  final bool? recyclingAndCompostFacilities;
  final bool? outdoorGrillingOrPicnicAreas;
  final bool? rooftopTerraceOrCourtyardGardens;
  final bool? flooring;
  final bool? privateBalconyOrPatio;
  final bool? walkInClosets;
  final bool? graniteOrQuartzCountertops;

  final Amenities? amenities;

  Amenities({
    required this.id,
    required this.propertyId,
    required this.propertyType,
    this.fencing,
    this.gate,
    this.bore,
    this.pipeline,
    this.electricity,
    this.plantation,
    this.waterGhmc,
    this.gasPipeline,
    this.garden,
    required this.bedrooms,
    required this.bathrooms,
    required this.parkingSpots,
    required this.lift,
    required this.security,
    required this.powerBackup,
    this.swimmingPool,
    this.playingArea,
    this.clubHouse,
    // this.packageForGuests,
    // this.inUnitWasherDryer,
    // this.dishwasher,
    // this.microwave,
    this.flooring,
    this.shoppingCenter,
    this.parkingForGuests,
    this.centralHeatingAndAirConditioning,
    this.privateBalconyOrPatio,
    this.walkInClosets,
    this.graniteOrQuartzCountertops,
    this.stainlessSteelAppliances,
    this.cableAndHighSpeedInternetReady,
    this.ceilingFans,
    this.onSiteFitnessCenter,
    this.controlledAccessEntry,
    this.elevatorAccess,
    this.coveredOrGarageParking,
    this.petFriendlyAreasOrDogWashStation,
    this.onSiteManagementAndMaintenance,
    this.recyclingAndCompostFacilities,
    this.outdoorGrillingOrPicnicAreas,
    this.rooftopTerraceOrCourtyardGardens,
    this.amenities,
  });

  factory Amenities.fromMap(Map<String, dynamic> data, String documentId) {
    return Amenities(
      id: documentId,
      propertyId: data['property_id'] as String,
      propertyType: PropertyType.values.firstWhere(
        (e) =>
            e.toString() == 'PropertyType.' + (data['property_type'] as String),
      ),
      fencing: data['fencing'] as bool?,
      gate: data['gate'] as bool?,
      bore: data['bore'] as bool?,
      pipeline: data['pipeline'] as bool?,
      electricity: data['electricity'] as bool?,
      plantation: data['plantation'] as bool?,
      bedrooms: data['bedrooms']?.toString() ?? '',
      bathrooms: data['bathrooms']?.toString() ?? '',
      parkingSpots: data['parkingSpots'] ?? '',
      lift: data['lift'] ?? '',
      security: data['security'] ?? '',
      powerBackup: data['power_backup'] ?? '',
      waterGhmc: data['water_ghmc'] as bool?,
      gasPipeline: data['gas_pipeline'] as bool?,
      garden: data['garden'] as bool?,
      swimmingPool: data['swimming_pool'] as bool?,
      playingArea: data['playing_area'] as bool?,
      clubHouse: data['club_house'] as bool?,
      shoppingCenter: data['shopping_center'] as bool?,
      // inUnitWasherDryer: data['in_unit_washer_dryer'] as bool?,
      // dishwasher: data['dishwasher'] as bool?,
      // microwave: data['microwave'] as bool?,
      centralHeatingAndAirConditioning:
          data['central_heating_and_air_conditioning'] as bool?,
      privateBalconyOrPatio: data['private_balcony_or_patio'] as bool?,
      walkInClosets: data['walk_in_closets'] as bool?,
      graniteOrQuartzCountertops:
          data['granite_or_quartz_countertops'] as bool?,
      stainlessSteelAppliances: data['stainless_steel_appliances'] as bool?,
      cableAndHighSpeedInternetReady:
          data['cable_and_high_speed_internet_ready'] as bool?,
      ceilingFans: data['ceiling_fans'] as bool?,
      onSiteFitnessCenter: data['on_site_fitness_center'] as bool?,
      controlledAccessEntry: data['controlled_access_entry'] as bool?,
      elevatorAccess: data['elevator_access'] as bool?,
      coveredOrGarageParking: data['covered_or_garage_parking'] as bool?,
      petFriendlyAreasOrDogWashStation:
          data['pet_friendly_areas_or_dog_wash_station'] as bool?,
      onSiteManagementAndMaintenance:
          data['on_site_management_and_maintenance'] as bool?,
      recyclingAndCompostFacilities:
          data['recycling_and_compost_facilities'] as bool?,
      outdoorGrillingOrPicnicAreas:
          data['outdoor_grilling_or_picnic_areas'] as bool?,
      rooftopTerraceOrCourtyardGardens:
          data['rooftop_terrace_or_courtyard_gardens'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'property_id': propertyId,
      'property_type': propertyType.toString().split('.').last,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'parkingSpots': parkingSpots,
      'lift': lift,
      'security': security,
      'powerBackup': powerBackup,
      'fencing': fencing,
      'gate': gate,
      'bore': bore,
      'pipeline': pipeline,
      'electricity': electricity,
      'plantation': plantation,
      'water_ghmc': waterGhmc,
      'gas_pipeline': gasPipeline,
      'garden': garden,
      'swimming_pool': swimmingPool,
      'playing_area': playingArea,
      'club_house': clubHouse,
      'shopping_center': shoppingCenter,
      // 'in_unit_washer_dryer': inUnitWasherDryer,
      // 'dishwasher': dishwasher,
      // 'microwave': microwave,
      'central_heating_and_air_conditioning': centralHeatingAndAirConditioning,
      'private_balcony_or_patio': privateBalconyOrPatio,
      'walk_in_closets': walkInClosets,
      'granite_or_quartz_countertops': graniteOrQuartzCountertops,
      'stainless_steel_appliances': stainlessSteelAppliances,
      'cable_and_high_speed_internet_ready': cableAndHighSpeedInternetReady,
      'ceiling_fans': ceilingFans,
      'on_site_fitness_center': onSiteFitnessCenter,
      'controlled_access_entry': controlledAccessEntry,
      'elevator_access': elevatorAccess,
      'covered_or_garage_parking': coveredOrGarageParking,
      'pet_friendly_areas_or_dog_wash_station':
          petFriendlyAreasOrDogWashStation,
      'on_site_management_and_maintenance': onSiteManagementAndMaintenance,
      'recycling_and_compost_facilities': recyclingAndCompostFacilities,
      'outdoor_grilling_or_picnic_areas': outdoorGrillingOrPicnicAreas,
      'rooftop_terrace_or_courtyard_gardens': rooftopTerraceOrCourtyardGardens,
    }..removeWhere((_, v) => v == null);
  }
}
