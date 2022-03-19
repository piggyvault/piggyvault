class TransactionComment {
  final String? id, content, creationTime, creatorUserName;
  final int? creatorUserId;
  TransactionComment(
      {this.id,
      this.content,
      this.creationTime,
      this.creatorUserId,
      this.creatorUserName});

  TransactionComment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        content = json['content'],
        creationTime = json['creationTime'].toString().substring(0,
            26), // Since API data type is DATETIME2(7) which contains 7 fraction of milli seconds and flutter support only upto 6.
        creatorUserName = json['creatorUserName'],
        creatorUserId = json['creatorUserId'];
}
