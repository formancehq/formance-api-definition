import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

import "./account.tsp";
import "./transaction.tsp";
import "../oauth.tsp";
import "./balances.tsp";
import "./ledgers.tsp";
import "./logs.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

@service({
  title: "Formance Ledger API",
})
@server("http://localhost", "Default localhost endpoint")
@route("/api/ledger/v2")
@useAuth(BearerAuth | FormanceOAuth<[]>)
namespace Ledger;

model ServerInfo {
  version: string;
}

@route("_info")
@FormanceApiStd.operation
@useAuth(FormanceOAuth<["ledger:read"]>)
op info(): ServerInfo;
