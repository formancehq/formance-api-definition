import "../oauth.tsp";
import "@typespec/http";

using TypeSpec.Http;

alias FlowsRead = FormanceOAuth<["flows:read"]> | BearerAuth;
alias FlowsWrite = FormanceOAuth<["flows:write"]> | BearerAuth;
