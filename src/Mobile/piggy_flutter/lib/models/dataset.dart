class Dataset {
  Dataset(this.total);
  Dataset.fromJson(Map<String, dynamic> json) : total = json['total'];
  final double? total;
}
