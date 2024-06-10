import "@formance/api-std";
import "@typespec/http";
import "./errors.tsp";
import "./auth.tsp";

using Http;
using Rest;
using FormanceApiStd;

namespace Ledger;

model Account {
  address: string;
  metadata: Record<string>;
  volumes: Record<Volume>;
  effectiveVolumes: Record<Volume>;
}

@Speakeasy.group("Accounts")
@route("{ledger}/accounts")
interface Accounts {
  
  @paginated
  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  op list(@path ledger: string, ...PaginatedQuery, @query pit?: utcDateTime, @query expand?: string): PaginatedResponse<Account> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  op get(@path ledger: string, @path address: string, @query pit?: utcDateTime, @query expand?: string): FormanceResponse<Account> | LedgerError;

  @FormanceApiStd.operation
  @head
  @useAuth(LedgerRead)
  op count(@path ledger: string, @query address: string, @query pit?: utcDateTime, @query query: Record<unknown>): {
    @statusCode _: 204,
    @header("Count") count: int64
  } | LedgerError;

  @FormanceApiStd.operation
  @action("metadata")
  @route("{address}/metadata")
  @useAuth(LedgerWrite)
  op addMetadata(@path ledger: string, @path address: string, metadata: Record<unknown>): { @statusCode _: 204 } | LedgerError;

  @FormanceApiStd.operation
  @route("{address}/metatdata/{key}")
  @useAuth(LedgerWrite)
  @delete
  op removeMetadata(@path ledger: string, @path address: string, @path key: string): void | LedgerError;
}
