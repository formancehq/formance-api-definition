enum FlowErrors {
  VALIDATION,
  NOT_FOUND,
  INTERNAL,
}

@error
model FlowError {
  errorCode: FlowErrors;
  errorMessage: string;
}
