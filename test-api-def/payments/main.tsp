import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";
import "./errors.tsp";
import "../oauth.tsp";
import "./payments.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

namespace Formance;

#suppress "@typespec/http/no-service-found" ""
@Speakeasy.group
@route("/api/payments")
@useAuth(FormanceOAuth<["payments:read"]>)
namespace Payments {
  model ServerInfo {
    version: string;
  }

  @Speakeasy.autoGroup
  @route("/_info")
  op info(): ServerInfo | PaymentError;
}