import "@typespec/http";
import "@typespec/openapi";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Formance.Payments;

enum PaymentErrorCodes {
  INTERNAL,
  VALIDATION,
  NOT_FOUND
};

@error
@extension("x-speakeasy-name-override", "PaymentError")
model PaymentError {
  errorCode: PaymentErrorCodes,
  errorMessage: string
};