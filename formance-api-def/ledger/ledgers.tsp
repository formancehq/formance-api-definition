import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";
import "./errors.tsp";
import "./auth.tsp";

using Http;
using Rest;
using FormanceApiStd;

namespace Ledger;

model Ledger {
  name: string;
  addedAt: utcDateTime;
  bucket: string;
}

enum MigrationState {
  TODO: "TO DO",
  DONE
}

model Migration {
  version: int64;
  name: string;
  date: utcDateTime;
  state: MigrationState;
}

model LedgerInfo {
  name: string;
  storage: {
    migrations: Migration[]
  }
};

@Speakeasy.group("Ledgers")
interface Ledgers {
  @FormanceApiStd.operation
  @paginated
  @useAuth(LedgerRead)
  op list(...PaginatedQuery): PaginatedResponse<Ledger> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  op get(@path ledger: string): FormanceResponse<Ledger> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  op create(@path ledger: string, bucket?: string): void | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  @route("/{ledger}/_info")
  info(@path ledger: string): FormanceResponse<LedgerInfo> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  @route("{ledger}/metadata")
  @put
  op addMetadata(@path ledger: string, @bodyRoot metadata: Record<string>): void | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  @route("{ledger}/metadata/{key}")
  @delete
  op removeMetadata(@path ledger: string, @path key: string): void | LedgerError;
}