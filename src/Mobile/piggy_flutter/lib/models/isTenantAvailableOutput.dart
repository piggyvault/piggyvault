class IsTenantAvailableOutput {
  final int state, tenantId;

  IsTenantAvailableOutput(this.state, this.tenantId);

  IsTenantAvailableOutput.fromJson(Map<String, dynamic> json)
      : state = json['state'],
        tenantId = json['tenantId'];
}
