import "../oauth.tsp";
import "@typespec/http";

using TypeSpec.Http;

alias LedgerRead = FormanceOAuth<["ledger:read"]> | BearerAuth;
alias LedgerWrite = FormanceOAuth<["ledger:write"]> | BearerAuth;
