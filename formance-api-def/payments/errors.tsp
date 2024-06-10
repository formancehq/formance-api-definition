import "@typespec/http";
import "@typespec/openapi";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Payments;

enum PaymentErrorCodes {
  INTERNAL,
  VALIDATION,
  NOT_FOUND,
}

@error
@extension("x-speakeasy-name-override", "PaymentsError")
model PaymentsError {
  errorCode: PaymentErrorCodes;
  errorMessage: string;
}
