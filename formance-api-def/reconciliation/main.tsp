import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

import "./policies.tsp";
import "./errors.tsp";
import "../oauth.tsp";
import "./reconciliations.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

@service({
  title: "Formance Reconciliation API",

})
@server("http://localhost", "Default localhost endpoint")
@route("/api/reconciliation")
namespace Reconciliation;

@FormanceApiStd.operation
@route("_info")
@useAuth(FormanceOAuth<["reconciliation:read"]>)
op info(): { verison: string } | ReconciliationError;