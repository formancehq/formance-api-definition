import "./auth.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Payments;

model CashPool {
  id: string;
  name: string;
  accounts: string[];
}

model PoolBalance {
  @minValue(0) amount: integer;
  asset: string;
}

@Speakeasy.group("CashPools")
@route("pools")
interface CashPools {
  @FormanceApiStd.operation
  @useAuth(PaymentsRead)
  @paginated
  list(...PaginatedQuery): PaginatedResponse<CashPool> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  create(
    name: string,
    accountIDs: string[],
  ): FormanceResponse<CashPool> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsRead)
  get(@path poolId: string): FormanceResponse<CashPool> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @delete
  delete(@path poolId: string): void | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @route("{poolId}/accounts")
  addAccount(@path poolId: string, accountID: string): void | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @route("{poolId}/accounts/{accountId}")
  @delete
  removeAccount(
    @path poolId: string,
    @path accountId: string,
  ): void | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @route("{poolId}/balances")
  balances(@path poolId: string, @query at: utcDateTime): FormanceResponse<{
    balances: PoolBalance[];
  }> | PaymentsError;
}
