import "../oauth.tsp";

import "@typespec/http";

using TypeSpec.Http;

alias PaymentsWrite = FormanceOAuth<["payments:write"]> | BearerAuth;
alias PaymentsRead = FormanceOAuth<["payments:read"]> | BearerAuth;
