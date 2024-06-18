import "./auth.tsp";
//import "./error.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";
import "./secrets.tsp";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Auth;

model Client {
  public?: boolean;
  redirectUris?: string[];
  description?: string;
  name: string;
  trusted: boolean;
  postLogoutRedirectUris?: string[];
  metadata?: Record<string>;
  id: string;
  secrets?: Secret[];
  scopes?: string[];
}

model ClientData {
  public?: Client.public,
  redirectUris?: Client.redirectUris,
  description?: Client.description,
  name: Client.name,
  trusted?: Client.trusted,
  postLogoutRedirectUris?: Client.postLogoutRedirectUris,
  metadata?: Client.metadata,
  scopes?: Client.scopes
}

@Speakeasy.group("Clients")
@route("clients")
interface Clients {
  @FormanceApiStd.operation
  @FormanceApiStd.paginated
  @useAuth(AuthRead)
  list(...PaginatedQuery): PaginatedResponse<Client>;

  @FormanceApiStd.operation
  @useAuth(AuthWrite)
  create(
    ...ClientData
  ): {
    @statusCode _: 201,
    ...FormanceResponse<Client>
  };

  @FormanceApiStd.operation
  @useAuth(AuthRead)
  get(@path id: string): FormanceResponse<Client>;

  @FormanceApiStd.operation
  @useAuth(AuthWrite)
  @put
  update(@path id: string, ...ClientData): FormanceResponse<Client>;

  @FormanceApiStd.operation
  @useAuth(AuthWrite)
  @delete
  delete(@path id: string): void;
}