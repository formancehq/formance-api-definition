import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

import "./auth.tsp";
import "./client.tsp";
import "./secrets.tsp";
import "./users.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

@service({
  title: "Formance Wallets API",
})
@server("http://localhost", "Default localhost endpoint")
@route("/api/auth")
@useAuth(BearerAuth | FormanceOAuth<[]>)
namespace Auth;

model ServerInfo {
  version: string;
}

@route("_info")
@FormanceApiStd.operation
@useAuth(AuthRead)
op info(): ServerInfo;