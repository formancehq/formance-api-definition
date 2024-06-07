import "../oauth.tsp";

alias LedgerRead = FormanceOAuth<["ledger:read"]>;
alias LedgerWrite = FormanceOAuth<["ledger:write"]>;
