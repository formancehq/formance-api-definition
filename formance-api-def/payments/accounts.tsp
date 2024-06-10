import "./auth.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Payments;

enum AccountType {
  INTERNAL,
  UNKNOWN,
  EXTERNAL,
}

model Account {
  id: string;
  createdAt: utcDateTime;
  reference: string;
  connectorID: string;
  provider?: Connector;
  #deprecated ""
  defaultCurrency: string;
  defaultAsset: string;
  accountName: string;
  type: AccountType;
  pools: string[];
  metadata: Record<string>;
  raw: unknown;
}

model AccountBalance {
  accountId: string;
  createdAt: utcDateTime;
  lastUpdatedAt: utcDateTime;
  #deprecated ""
  currency: string;
  asset: string;
  balance: integer;
}

@route("accounts")
@Speakeasy.group("Accounts")
interface Accounts {
  @FormanceApiStd.operation
  @paginated
  @useAuth(PaymentsRead)
  list(
    ...PaginatedQuery,

    @query({
      format: "multi",
    })
    sort?: string[],

    @query query?: string,
  ): PaginatedResponse<Account> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsRead)
  get(@path accountId: string): FormanceResponse<Account> | PaymentsError;

  @FormanceApiStd.operation
  @paginated
  @useAuth(PaymentsRead)
  @route("{accountId}/balances")
  balances(
    @path accountId: string,
    ...PaginatedQuery,
    @query limit?: int64,
    @query asset?: string,
    @query from?: utcDateTime,
    @query to?: utcDateTime,
    @query({
      format: "multi",
    })
    sort: string[],
  ): PaginatedResponse<AccountBalance> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  create(
    reference: Account.reference,
    connectorID: Account.connectorID,
    createdAt: Account.createdAt,
    type: Account.type,
    defaultAsset?: Account.defaultAsset,
    accountName?: Account.accountName,
    metadata?: Account.metadata,
  ): FormanceResponse<Account> | PaymentsError;
}
