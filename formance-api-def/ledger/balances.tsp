import "../oauth.tsp";
import "@formance/api-std";
import "@typespec/http";

namespace Ledger;

using FormanceApiStd;
using TypeSpec.Http;

model VolumeItem {
  account: string;
  asset: string;
  input: integer;
  output: integer;
  balance: integer;
}

@Speakeasy.group("Balances")
interface Balances {
  @route("{ledger}/aggregate/balances")
  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  aggregate(
    @path ledger: string,
    @query pit?: utcDateTime,
    @query useInsertionDate?: boolean,
    @query query: Record<unknown>,
  ): FormanceResponse<Record<unknown>> | LedgerError;

  @route("{ledger}/volumes")
  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  @paginated
  volumes(
    @path ledger: string,
    ...PaginatedQuery,
    @query startTime?: utcDateTime,
    @query endTime?: utcDateTime,
    @query inseritionDate?: boolean,

    @query
    @minValue(0)
    @maxValue(1000)
    groupBy?: int64,

    @query query: Record<unknown>,
  ): PaginatedResponse<VolumeItem> | LedgerError;
}
