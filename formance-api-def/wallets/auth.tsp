import "../oauth.tsp";
import "@typespec/http";

using TypeSpec.Http;

alias WalletsRead = FormanceOAuth<["wallets:read"]> | BearerAuth;
alias WalletsWrite = FormanceOAuth<["wallets:write"]> | BearerAuth;
