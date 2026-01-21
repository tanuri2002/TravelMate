import '../models/review.dart';

class ReviewService {
  final List<Review> _reviews = [];

  void addReview(Review review) {
    _reviews.add(review);
  }

  List<Review> getReviewsForDestination(String destinationId) {
    return _reviews.where((r) => r.destinationId == destinationId).toList();
  }

  double getAverageRating(String destinationId) {
    final destinationReviews = _reviews
        .where((r) => r.destinationId == destinationId)
        .toList();
    if (destinationReviews.isEmpty) return 0.0;

    double total = destinationReviews.fold(0, (sum, r) => sum + r.rating);
    return total / destinationReviews.length;
  }
}
