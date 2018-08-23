class TransactionComment {
  final String id, content, creationTime, creatorUserName;
  final int creatorUserId;
  TransactionComment(
      {this.id,
      this.content,
      this.creationTime,
      this.creatorUserId,
      this.creatorUserName});

  TransactionComment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        content = json['content'],
        creationTime = json['creationTime'],
        creatorUserName = json['creatorUserName'],
        creatorUserId = json['creatorUserId'];
}
