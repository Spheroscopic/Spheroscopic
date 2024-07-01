import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPhotosState extends StateNotifier<AsyncValue<void>> {
  AddPhotosState(this.ref)
      // set the initial state (synchronously)
      : super(const AsyncData(null));
  final Ref ref;

  void loading() async {
    state = const AsyncLoading();
  }

  void completed() async {
    state = const AsyncData(null);
  }
}

final addPhotoState =
    StateNotifierProvider<AddPhotosState, AsyncValue<void>>((ref) {
  return AddPhotosState(ref);
});
