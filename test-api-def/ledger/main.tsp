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
  title: "Dummy Ledger API"
})
@route("/api/ledger")
@Speakeasy.group
namespace Ledger;

model ServerInfo {
  version: string;
}

@route("_info")
@Speakeasy.autoGroup
op info(): ServerInfo;

