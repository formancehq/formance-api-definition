import "./auth.tsp";
import "./error.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "./balances.tsp";
import "./holds.tsp";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Wallets;

@format("uuid")
scalar WalletId extends string;

model Wallet {
  id: WalletId;
  metadata: Record<string>;
  name: string;
  createdAt: utcDateTime;
  ledger: string;
}

alias Funds = Record<integer>;

model WalletSummary {
  balances: BalancesWithAssets;
  availableFunds: Funds;
  expiredFunds: Funds;
  expirableFunds: Funds;
  holdFunds: Funds;
}

@Speakeasy.group("wallets")
@route("wallets")
interface Wallets {
  @FormanceApiStd.operation
  @FormanceApiStd.paginated
  @useAuth(WalletsRead)
  list(
    @query name: string,

    @query({
      format: "multi",
    })
    metadata: Record<string>,

    ...PaginatedQuery,
  ): PaginatedResponse<Wallet> | WalletsError;

  @FormanceApiStd.operation
  @useAuth(WalletsWrite)
  create(name: string, metadata: Record<string>): {
    @statusCode _: 201;
  } | WalletsError;

  @FormanceApiStd.operation
  @useAuth(WalletsRead)
  get(
    @path id: string,
  ): FormanceResponse<Wallet> | WalletNotFound | WalletsError;

  @FormanceApiStd.operation
  @useAuth(WalletsWrite)
  @patch
  update(@path id: string, metadata: Record<string>): void | WalletNotFound;

  @FormanceApiStd.operation
  @useAuth(WalletsRead)
  @route("{id}/summary")
  summary(
    @path id: string,
  ): FormanceResponse<WalletSummary> | WalletNotFound | WalletsError;

  @FormanceApiStd.operation
  @useAuth(WalletsWrite)
  @route("{id}/debit")
  debit(
    @path id: string,
    pending?: boolean,
    amount: {
      asset: string;
      amount: integer;
    },
    metadata: Record<string>,
    description?: string,
    destination?: WalletCounterpart,
    balances?: string[],
    timestamp?: utcDateTime,
  ): {
    @statusCode _: 201;
    ...FormanceResponse<Hold>;
  } | void | WalletsError;

  @FormanceApiStd.operation
  @route("{id}/credit")
  @useAuth(WalletsWrite)
  credit(
    @path id: string,
    amount: {
      asset: string;
      amount: integer;
    },
    metadata: Record<string>,
    source: WalletCounterpart,
    reference?: string,
    balance?: string,
    tinestamp?: string,
  ): void | WalletsError;
}
