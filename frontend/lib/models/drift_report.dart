class DriftReport {
  final DateTime generatedAt;
  final String user;
  final int score;
  final int scoreDelta;
  final TopAction topAction;
  final Debts debts;

  DriftReport({
    required this.generatedAt,
    required this.user,
    required this.score,
    required this.scoreDelta,
    required this.topAction,
    required this.debts,
  });

  factory DriftReport.fromJson(Map<String, dynamic> json) {
    return DriftReport(
      generatedAt: DateTime.parse(json['generated_at']),
      user: json['user'],
      score: json['score'],
      scoreDelta: json['score_delta'],
      topAction: TopAction.fromJson(json['top_action']),
      debts: Debts.fromJson(json['debts']),
    );
  }
}

class TopAction {
  final String text;
  final String type;
  final String url;

  TopAction({required this.text, required this.type, required this.url});

  factory TopAction.fromJson(Map<String, dynamic> json) {
    return TopAction(
      text: json['text'],
      type: json['type'],
      url: json['url'],
    );
  }
}

class Debts {
  final List<ReviewDebt> review;
  final List<ReplyDebt> reply;
  final List<CommitmentDebt> commitment;
  final List<StalenessDebt> staleness;
  final List<DriftDebt> drift;

  Debts({
    required this.review,
    required this.reply,
    required this.commitment,
    required this.staleness,
    required this.drift,
  });

  factory Debts.fromJson(Map<String, dynamic> json) {
    return Debts(
      review: (json['review'] as List).map((e) => ReviewDebt.fromJson(e)).toList(),
      reply: (json['reply'] as List).map((e) => ReplyDebt.fromJson(e)).toList(),
      commitment: (json['commitment'] as List).map((e) => CommitmentDebt.fromJson(e)).toList(),
      staleness: (json['staleness'] as List).map((e) => StalenessDebt.fromJson(e)).toList(),
      drift: (json['drift'] as List).map((e) => DriftDebt.fromJson(e)).toList(),
    );
  }
}

class ReviewDebt {
  final int prNumber;
  final String title;
  final String author;
  final String repo;
  final int daysWaiting;
  final int slackMentions;
  final String? blocks;
  final String url;

  ReviewDebt({
    required this.prNumber,
    required this.title,
    required this.author,
    required this.repo,
    required this.daysWaiting,
    required this.slackMentions,
    this.blocks,
    required this.url,
  });

  factory ReviewDebt.fromJson(Map<String, dynamic> json) {
    return ReviewDebt(
      prNumber: json['pr_number'],
      title: json['title'],
      author: json['author'],
      repo: json['repo'],
      daysWaiting: json['days_waiting'],
      slackMentions: json['slack_mentions'],
      blocks: json['blocks'],
      url: json['url'],
    );
  }
}

class ReplyDebt {
  final String source;
  final String channel;
  final String from;
  final int daysAgo;
  final String preview;

  ReplyDebt({
    required this.source,
    required this.channel,
    required this.from,
    required this.daysAgo,
    required this.preview,
  });

  factory ReplyDebt.fromJson(Map<String, dynamic> json) {
    return ReplyDebt(
      source: json['source'],
      channel: json['channel'],
      from: json['from'],
      daysAgo: json['days_ago'],
      preview: json['preview'],
    );
  }
}

class CommitmentDebt {
  final String taskId;
  final String title;
  final String status;
  final int daysStale;
  final DateTime lastCommitDate;

  CommitmentDebt({
    required this.taskId,
    required this.title,
    required this.status,
    required this.daysStale,
    required this.lastCommitDate,
  });

  factory CommitmentDebt.fromJson(Map<String, dynamic> json) {
    return CommitmentDebt(
      taskId: json['task_id'],
      title: json['title'],
      status: json['status'],
      daysStale: json['days_stale'],
      lastCommitDate: DateTime.parse(json['last_commit_date']),
    );
  }
}

class StalenessDebt {
  final int prNumber;
  final String title;
  final String repo;
  final int daysStale;
  final int reviews;
  final String url;

  StalenessDebt({
    required this.prNumber,
    required this.title,
    required this.repo,
    required this.daysStale,
    required this.reviews,
    required this.url,
  });

  factory StalenessDebt.fromJson(Map<String, dynamic> json) {
    return StalenessDebt(
      prNumber: json['pr_number'],
      title: json['title'],
      repo: json['repo'],
      daysStale: json['days_stale'],
      reviews: json['reviews'],
      url: json['url'],
    );
  }
}

class DriftDebt {
  final String taskId;
  final String taskTitle;
  final String taskStatus;
  final int prNumber;
  final String prStatus;
  final String contradiction;

  DriftDebt({
    required this.taskId,
    required this.taskTitle,
    required this.taskStatus,
    required this.prNumber,
    required this.prStatus,
    required this.contradiction,
  });

  factory DriftDebt.fromJson(Map<String, dynamic> json) {
    return DriftDebt(
      taskId: json['task_id'],
      taskTitle: json['task_title'],
      taskStatus: json['task_status'],
      prNumber: json['pr_number'],
      prStatus: json['pr_status'],
      contradiction: json['contradiction'],
    );
  }
}
