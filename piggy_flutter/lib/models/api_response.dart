class ApiResponse<T> {
  T content;
  bool success;
  String message;

  ApiResponse({this.content, this.success, this.message});

  @override
  String toString() {
    return 'ApiResponse content $content success $success message $message';
  }
}

class MappedNetworkServiceResponse<T> {
  dynamic mappedResult;
  ApiResponse<T> networkServiceResponse;
  MappedNetworkServiceResponse(
      {this.mappedResult, this.networkServiceResponse});
}
