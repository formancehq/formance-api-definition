import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

import "./account.tsp";
import "./transaction.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;


@service({
  title: "Dummy Ledger API",

})
@route("/api/ledger")
@Speakeasy.group
@server("http://localhost", "Default localhost endpoint")
namespace Ledger;

alias LedgerAuth<Scopes extends valueof string[]> = OAuth2Auth<[{
  type: OAuth2FlowType.clientCredentials;
  tokenUrl: "/api/auth/token"
}], Scopes>;

model ServerInfo {
  version: string;
}

@route("_info")
@Speakeasy.autoGroup
@useAuth(LedgerAuth<["ledger:read"]>)
op info(): ServerInfo;

