import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConstants {
  static final String endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
  static final String projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
  static final String databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  // ID Collection
  static final String profilesCollectionId = dotenv.env['PROFILES_COLLECTION_ID']!;
  static final String productsCollectionId = dotenv.env['PRODUCTS_COLLECTION_ID']!; // <-- BARU
  static final String ordersCollectionId = dotenv.env['ORDERS_COLLECTION_ID']!; // <-- BARU
  static final String orderItemsCollectionId = dotenv.env['ORDER_ITEMS_COLLECTION_ID']!; // <-- BARU
static final String productImagesCollectionId = dotenv.env['PRODUCT_IMAGES_COLLECTION_ID']!;
  // ID Bucket Storage
  static final String productsBucketId = dotenv.env['PRODUCTS_BUCKET_ID']!; // <-- BARU

    // ID Tim
  static final String adminTeamId = dotenv.env['ADMIN_TEAM_ID']!;
}