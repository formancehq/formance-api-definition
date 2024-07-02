import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

import "./auth.tsp";

import "./triggers.tsp";
import "./workflows.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

@service({
  title: "Formance Flows API",
})
@server("http://localhost", "Default localhost endpoint")
@route("/api/orchestration/v2")
@useAuth(BearerAuth | FormanceOAuth<[]>)
namespace Flows;

model ServerInfo {
  version: string;
}

@route("_info")
@FormanceApiStd.operation
@useAuth(FlowsRead)
op info(): ServerInfo;
