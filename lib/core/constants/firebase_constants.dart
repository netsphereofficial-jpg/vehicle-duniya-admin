/// Firebase collection names and constants
class FirebaseConstants {
  FirebaseConstants._();

  // Collection Names
  static const String usersCollection = 'users';
  static const String adminsCollection = 'admins';
  static const String vehiclesCollection = 'vehicles';
  static const String propertiesCollection = 'properties';
  static const String carBazaarCollection = 'car_bazaar';
  static const String bidsCollection = 'bids';
  static const String appConfigCollection = 'app_config';

  // Document IDs
  static const String settingsDoc = 'settings';

  // Storage Paths
  static const String vehicleImagesPath = 'vehicles';
  static const String propertyImagesPath = 'properties';
  static const String carBazaarImagesPath = 'car_bazaar';
  static const String userProfileImagesPath = 'users/profiles';
  static const String propertyDocumentsPath = 'properties/documents';

  // Field Names
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String status = 'status';
  static const String isActive = 'isActive';
}
