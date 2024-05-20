import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

import "./account.tsp";
import "./transaction.tsp";
import "../oauth.tsp";
import "./balances.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

namespace Formance;

model ServerInfo {
  version: string;
}

#suppress "@typespec/http/no-service-found" "This is the definition of a service as part of the Formance stack."
@route("/api/ledger")
@Speakeasy.group
namespace Ledger {
  @route("_info")
  @Speakeasy.autoGroup
  @useAuth(FormanceOAuth<["ledger:read"]>)
  op info(): ServerInfo;
}
