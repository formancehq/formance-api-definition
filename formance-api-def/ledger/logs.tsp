import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";
import "./errors.tsp";
import "./auth.tsp";

using Http;
using FormanceApiStd;

namespace Ledger;

enum LogEntryType {
  NEW_TRANSACTION,
  SET_METADATA,
  REVERT_TRANSACTION,
}

model LogEntry {
  @minValue(0) id: integer;
  type: LogEntryType;
  data: unknown;
  hash: string;
  date: utcDateTime;
}

@Speakeasy.group("Logs")
@route("{ledger}/logs")
interface Logs {
  @FormanceApiStd.operation
  @paginated
  @useAuth(LedgerRead)
  list(
    @path ledger: string,
    ...PaginatedQuery,
  ): PaginatedResponse<LogEntry>;

  @route("import")
  @operation
  @useAuth(LedgerWrite)
  @post
  ingest(
    @header contentType: "application/octet-stream",
    @body data: string,
    @path ledger: string,
  ): void | LedgerError;

  @route("export")
  @operation
  @useAuth(LedgerRead)
  @post
  export(
    @path ledger: string,
  ): {
    @header contentType: "application/octet-stream",
    @bodyRoot data: string,
  } | LedgerError;
}