import '../models/photo.dart';

class PhotoService {
  final List<Photo> _photos = [];

  void uploadPhoto(Photo photo) {
    _photos.add(photo);
  }

  List<Photo> getPhotosByDestination(String destinationId) {
    return _photos.where((p) => p.destinationId == destinationId).toList();
  }

  List<Photo> getPhotosByUser(String userId) {
    return _photos.where((p) => p.userId == userId).toList();
  }
}
