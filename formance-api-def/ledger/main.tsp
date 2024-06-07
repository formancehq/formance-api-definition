import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

import "./account.tsp";
import "./transaction.tsp";
import "../oauth.tsp";
import "./balances.tsp";
import "./ledgers.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

@service({
  title: "Formance Ledger API",

})
@server("http://localhost", "Default localhost endpoint")
namespace Ledger;

model ServerInfo {
  version: string;
}

@route("/api/ledger/v2")
namespace Ledger {
  @route("_info")
  @FormanceApiStd.operation
  @useAuth(FormanceOAuth<["ledger:read"]>)
  op info(): ServerInfo;
}
