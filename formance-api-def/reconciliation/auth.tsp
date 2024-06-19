import "../oauth.tsp";
import "@typespec/http";

using TypeSpec.Http;

alias ReconciliationRead = FormanceOAuth<["reconciliation:read"]> | BearerAuth;
alias ReconciliationWrite = FormanceOAuth<["reconciliation:write"]> | BearerAuth;