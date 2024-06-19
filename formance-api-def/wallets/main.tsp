import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

import "./auth.tsp";
import "./wallets.tsp";
import "./balances.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

@service({
  title: "Formance Wallets API",
})
@server("http://localhost", "Default localhost endpoint")
@route("/api/wallets")
@useAuth(FormanceOAuth<[]> | BearerAuth)
namespace Wallets;

model ServerInfo {
  version: string;
}

@route("_info")
@FormanceApiStd.operation
@useAuth(WalletsRead)
op info(): ServerInfo;