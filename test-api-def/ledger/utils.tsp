import "@typespec/http";

using TypeSpec.Http;

namespace Formance.Ledger;

model LedgerQuery {
  @path
  ledger: string
}