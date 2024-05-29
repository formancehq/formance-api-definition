import "@formance/api-std";
import "@typespec/http";
import "./utils.tsp";
import "./errors.tsp";
import "../oauth.tsp";

using Http;
using Rest;
using FormanceApiStd;

namespace Ledger;

model Account {
  address: string;
  type: string;
  metadata: Record<string>
}

@Speakeasy.group("AccountsV1")
@route("{ledger}/accounts")
interface AccountsV1 {
  
  @paginated
  @FormanceApiStd.operation
  @useAuth(FormanceOAuth<["ledger:read"]>)
  op list(@path ledger: string, @query cursor?: string): PaginatedResponse<Account> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(FormanceOAuth<["ledger:read"]>)
  op get(@path ledger: string, @path address: string): FormanceResponse<Account> | LedgerError;

  @FormanceApiStd.operation
  @head
  @useAuth(FormanceOAuth<["ledger:read"]>)
  op count(@path ledger: string, @query address: string, @query metadata: Record<unknown>): int64 | LedgerError;

  @FormanceApiStd.operation
  @action("metadata")
  @route("{address}/metadata")
  @useAuth(FormanceOAuth<["ledger:write"]>)
  op addMetadata(@path ledger: string, @path address: string, metadata: Record<unknown>): { @statusCode _: 204 } | LedgerError;
}
