class ApiResponse<T> {
  T content;
  bool success;
  String message;

  ApiResponse({this.content, this.success, this.message});
}

class MappedNetworkServiceResponse<T> {
  dynamic mappedResult;
  ApiResponse<T> networkServiceResponse;
  MappedNetworkServiceResponse(
      {this.mappedResult, this.networkServiceResponse});
}
