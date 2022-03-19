class IsTenantAvailableResult {
  final int? state, tenantId;

  IsTenantAvailableResult({this.state, this.tenantId});

  IsTenantAvailableResult.fromJson(Map<String, dynamic> json)
      : state = json['state'],
        tenantId = json['tenantId'];
}
