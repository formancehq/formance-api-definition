import "../oauth.tsp";
import "@typespec/http";

using TypeSpec.Http;

alias AuthRead = FormanceOAuth<["auth:read"]> | BearerAuth;
alias AuthWrite = FormanceOAuth<["auth:write"]> | BearerAuth;
