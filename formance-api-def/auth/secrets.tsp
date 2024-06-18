import "./auth.tsp";
//import "./error.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Auth;

model Secret {
  lastDigits: string;
  name: string;
  id: string;
  metadata?: Record<string>
}

@Speakeasy.group("Secrets")
@route("{clientId}/secrets")
interface Secrets {
  @FormanceApiStd.operation
  @useAuth(AuthWrite)
  create(@path clientId: string, name: string, metadata?: Record<string>): FormanceResponse<{
    ...Secret;
    clear: string;
  }>;

  @FormanceApiStd.operation
  @useAuth(AuthWrite)
  @delete 
  delete(@path clientId: string, @path secretId: string): void;
}