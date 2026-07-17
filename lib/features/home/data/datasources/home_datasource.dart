import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';

class HomeDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BannerModel>> getBanners({String zone = 'header'}) async {
    try {
      final snapshot = await _firestore
          .collection('banners')
          .where('zone', isEqualTo: zone)
          .limit(20)
          .get();
      var items = snapshot.docs
          .map((d) => BannerModel.fromFirestore(d.data()))
          .where((b) => b.isActive)
          .toList();
      items.sort((a, b) => a.order.compareTo(b.order));
      return items;
    } catch (e) {
      return [];
    }
  }

  Future<BannerModel?> getBottomBanner() async {
    try {
      final snapshot = await _firestore
          .collection('banners')
          .where('zone', isEqualTo: 'bottom')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return BannerModel.fromFirestore(snapshot.docs.first.data());
    } catch (e) {
      return null;
    }
  }

  Future<BannerModel?> getBannerById(String id) async {
    try {
      final doc = await _firestore.collection('banners').doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return BannerModel.fromFirestore(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').limit(50).get();
      var items = snapshot.docs
          .map((d) => CategoryModel.fromFirestore(d.data()))
          .where((c) => c.isActive)
          .toList();
      items.sort((a, b) => a.order.compareTo(b.order));
      return items;
    } catch (e) {
      return [];
    }
  }
}
