class PitelError implements Error{
  final String? message;
  PitelError(this.message);
  
  @override
  StackTrace? get stackTrace => null;

  @override
  String toString(){
    return message ?? '';
  }
}