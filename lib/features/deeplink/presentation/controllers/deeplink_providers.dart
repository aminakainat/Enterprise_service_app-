import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/deeplink_model.dart';

class DeepLinkState {
  final ParsedDeepLink? lastHandledLink;
  final List<String> deepLinkHistory;

  DeepLinkState({
    this.lastHandledLink,
    this.deepLinkHistory = const [],
  });

  DeepLinkState copyWith({
    ParsedDeepLink? lastHandledLink,
    List<String>? deepLinkHistory,
  }) {
    return DeepLinkState(
      lastHandledLink: lastHandledLink ?? this.lastHandledLink,
      deepLinkHistory: deepLinkHistory ?? this.deepLinkHistory,
    );
  }
}

class DeepLinkController extends StateNotifier<DeepLinkState> {
  DeepLinkController() : super(DeepLinkState());

  ParsedDeepLink handleDeepLinkUrl(String url) {
    final parsed = ParsedDeepLink.fromUriString(url);
    final updatedHistory = List<String>.from(state.deepLinkHistory)..insert(0, url);

    state = state.copyWith(
      lastHandledLink: parsed,
      deepLinkHistory: updatedHistory,
    );

    return parsed;
  }
}

final deepLinkControllerProvider =
    StateNotifierProvider<DeepLinkController, DeepLinkState>((ref) {
  return DeepLinkController();
});
