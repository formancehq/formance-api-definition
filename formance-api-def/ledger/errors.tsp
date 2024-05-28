import "@typespec/http";
import "@typespec/openapi";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Ledger;

enum LedgerErrors {
  INTERNAL,
  INSUFFICIENT_FUND,
  VALIDATION,
  CONFLICT,
  COMPILATION_FAILED,
  METADATA_OVERRIDE,
  NOT_FOUND,
  REVERT_OCCURRING,
  ALREADY_REVERT,
  NO_POSTINGS,
  LEDGER_NOT_FOUND,
}

@error
@extension("x-speakeasy-name-override", "LedgerError")
model LedgerError {
  errorCode: LedgerErrors;
  errorMessage: string;
  details?: string;
}