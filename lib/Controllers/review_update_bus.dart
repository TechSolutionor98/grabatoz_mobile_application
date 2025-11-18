import 'dart:async';

class ReviewUpdateBus {
  ReviewUpdateBus._();
  static final ReviewUpdateBus instance = ReviewUpdateBus._();

  final StreamController<String> _controller = StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void emit(String productId) {
    if (productId.isNotEmpty) {
      _controller.add(productId);
    }
  }

  void dispose() {
    _controller.close();
  }
}
