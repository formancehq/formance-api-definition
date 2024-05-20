import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";
import "./errors.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

namespace Formance;

#suppress "@typespec/http/no-service-found" ""
@Speakeasy.group
@route("/api/payments")
namespace Payments {
  model ServerInfo {
    version: string;
  }

  @Speakeasy.autoGroup
  @route("/_info")
  op info(): ServerInfo | PaymentError;
}