import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

namespace Reconciliation;

@error
model ReconciliationError {
  errorCode: string;
  errorMessage: string;
  details?: string;
}