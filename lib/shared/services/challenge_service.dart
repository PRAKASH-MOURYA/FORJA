class ChallengeService {
  static String parseInviteCode(String uri) {
    final parsed = Uri.parse(uri);
    final firstSegment =
        parsed.pathSegments.isNotEmpty ? parsed.pathSegments.first : null;
    final isChallengePath = parsed.host == 'challenge' || firstSegment == 'challenge';
    final code = parsed.host == 'challenge'
        ? (parsed.pathSegments.isNotEmpty ? parsed.pathSegments.first : null)
        : (parsed.pathSegments.length > 1 ? parsed.pathSegments[1] : null);

    if (parsed.scheme != 'forja' || !isChallengePath || code == null || code.isEmpty) {
      throw ArgumentError('Missing invite code');
    }
    return code;
  }
}
