class ModelValidators {
  static required(List<String> errors, String fieldName) {
    errors.add('Missing required field: $fieldName');
    return null;
  }
}