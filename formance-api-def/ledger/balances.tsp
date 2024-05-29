import "../oauth.tsp";
import "@formance/api-std";
import "@typespec/http";

namespace Ledger;

using FormanceApiStd;
using TypeSpec.Http;

model AccountBalances is Record<AssetBalances>;
model AssetBalances is Record<integer>;

@Speakeasy.group("BalancesV1")
interface BalancesV1 {

  @FormanceApiStd.operation
  @paginated
  @route("{ledger}/balances")
  op get(@path ledger: string, @query pageSize?: string, @query cursor?: string, @query address?: string, @query after?: string): PaginatedResponse<AccountBalances[]> | LedgerError;

  @FormanceApiStd.operation
  @route("{ledger}/aggregate/balances")
  op aggregate(@path ledger: string, @query address?: string, @query useInsertionData?: boolean): FormanceResponse<AssetBalances> | LedgerError;
}
