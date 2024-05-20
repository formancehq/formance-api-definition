import "../oauth.tsp";
import "@formance/api-std";
import "@typespec/http";

namespace Formance.Ledger;

using FormanceApiStd;
using TypeSpec.Http;

model AccountBalances is Record<AssetBalances>;
model AssetBalances is Record<integer>;

@Speakeasy.group
namespace Balances {
  @Speakeasy.group
  interface V1 {

    @Speakeasy.autoGroup
    @paginated
    @route("{ledger}/balances")
    op get(@path ledger: string, @query pageSize?: string, @query cursor?: string, @query address?: string, @query after?: string): PaginatedResponse<AccountBalances[]> | LedgerError;

    @Speakeasy.autoGroup
    @route("{ledger}/aggregate/balances")
    op aggregate(@path ledger: string, @query address?: string, @query useInsertionData?: boolean): FormanceResponse<AssetBalances> | LedgerError;
  }
}