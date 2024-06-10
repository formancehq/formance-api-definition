import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";
import "./errors.tsp";
import "../oauth.tsp";
import "./payments.tsp";
import "./connectors.tsp";
import "./transfer_initiations.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

@service({
  title: "Formance Payments API",

})
@server("http://localhost", "Default localhost endpoint")
namespace Payments;

@route("/api/payments")
namespace Payments {
  model ServerInfo {
    version: string;
  }

  @FormanceApiStd.operation
  @useAuth(FormanceOAuth<["payments:read"]>)
  @route("/_info")
  op info(): ServerInfo | PaymentsError;
}