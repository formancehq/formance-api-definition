import "./auth.tsp";
import "./error.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Wallets;

model Balance {
  name: string;
  expiresAt?: utcDateTime;
  priority?: integer;
}

model BalancesWithAssets {
  ...Balance,
  assets: Record<integer>
}

@Speakeasy.group("Balances")
@route("wallets/{walletId}/balances")
interface Balances {
  @FormanceApiStd.operation
  @useAuth(WalletsWrite)
  create(
    @path walletId: string,
    name: Balance.name,
    expiresAt?: Balance.expiresAt,
    priority?: Balance.priority,
  ): {
    @statusCode _: 201;
    ...FormanceResponse<Balance>;
  } | WalletsError;

  @FormanceApiStd.operation
  @FormanceApiStd.paginated
  @useAuth(WalletsRead)
  list(
    @path walletId: string;
    ...PaginatedQuery
  ): PaginatedResponse<Balance> | WalletsError;

  @FormanceApiStd.operation
  @useAuth(WalletsRead)
  get(
    @path walletId: string,
    @path balanceName: string
  ): FormanceResponse<BalancesWithAssets> | WalletsError;
}
