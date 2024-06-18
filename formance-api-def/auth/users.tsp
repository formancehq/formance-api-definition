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

model User {
  id: string;
  subject: string;
  email: string
}

@Speakeasy.group("Users")
@route("users")
interface Users {
  @FormanceApiStd.operation
  @FormanceApiStd.paginated
  @useAuth(AuthRead)
  list(...PaginatedQuery): PaginatedResponse<User>;

  @FormanceApiStd.operation
  @useAuth(AuthRead)
  get(@path userid: string): FormanceResponse<User>;
}