import "./ledger";
import "./payments";
import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

using TypeSpec.OpenAPI;
using TypeSpec.Http;

@service({
  title: "Formance API",

})
@server("http://localhost", "Default localhost endpoint")
namespace Formance;
