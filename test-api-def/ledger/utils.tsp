import "@typespec/http";

using TypeSpec.Http;

namespace Ledger;

model LedgerQuery {
  @path
  ledger: string
}