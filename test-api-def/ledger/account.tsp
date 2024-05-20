import "@formance/api-std";
import "@typespec/http";
import "./utils.tsp";
import "./errors.tsp";

using Http;
using Rest;
using FormanceApiStd;

namespace Ledger;

model Account {
  address: string;
  type: string;
  metadata: Record<string>
}

@route("{ledger}/accounts")
@Speakeasy.group
namespace Accounts {

  @Speakeasy.group
  interface V1 {
    
    @paginated
    @Speakeasy.autoGroup
    op list(@path ledger: string, @query cursor?: string): PaginatedResponse<Account> | LedgerError;

    @Speakeasy.autoGroup
    op get(@path ledger: string, @path address: string): FormanceResponse<Account> | LedgerError;

    @Speakeasy.autoGroup
    @head
    op count(@path ledger: string, @query address: string, @query metadata: Record<unknown>): int64 | LedgerError;

    @Speakeasy.autoGroup
    @action("metadata")
    @route("{address}/metadata")
    op addMetadata(@path ledger: string, @path address: string, metadata: Record<unknown>): { @statusCode _: 204 } | LedgerError;
  }
}