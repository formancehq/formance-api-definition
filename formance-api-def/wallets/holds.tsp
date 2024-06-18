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

model WalletCounterpartAccount {
  type: "ACCOUNT";
  identifier: string;
}

model WalletCounterpartWallet {
  type: "WALLET";
  identifier: string;
  balance?: string;
}

@discriminator("type")
@oneOf
union WalletCounterpart {
  ACCOUNT: WalletCounterpartAccount,
  WALLET: WalletCounterpartWallet,
}

@format("uuid")
scalar HoldId extends string;

model Hold {
  id: HoldId;
  walletID: string;
  metadata: Record<string>;
  description: string;
  destination: WalletCounterpart;
}

@Speakeasy.group("Holds")
@route("holds")
interface Holds {
  @FormanceApiStd.operation
  @FormanceApiStd.paginated
  @useAuth(WalletsRead)
  list(
    @query walletID: string,
    ...PaginatedQuery,
  ): PaginatedResponse<Hold> | WalletsError;

  @FormanceApiStd.operation
  @useAuth(WalletsRead)
  get(@path holdId: string): FormanceResponse<Hold> | WalletsError;

  @FormanceApiStd.operation
  @useAuth(WalletsWrite)
  @route("{holdId}/confirm")
  confirm(
    @path holdId: string,
    amount?: integer,
    final?: boolean,
  ): void | WalletsError;

  @FormanceApiStd.operation
  @useAuth(WalletsWrite)
  @route("{holdId}/void")
  @post
  cancel(@path holdId: string): void | WalletsError;
}
