import "./auth.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Payments;

model BankAccountRelatedAccount {
  id: string;
  createdAt: utcDateTime;
  provider: string;
  connectorID: string;
  accountID: string;
}

model BankAccount {
  id: string;
  name: string;
  createdAt: utcDateTime;
  country: string;
  connectorID: string;
  accountID?: string;
  provider?: string;
  iban?: string;
  accountNumber?: string;
  swiftBicCode?: string;
  relatedAccounts?: BankAccountRelatedAccount[];
  metadata?: Record<string>;
}

@Speakeasy.group("BankAccounts")
@route("bank-accounts")
interface BankAccounts {
  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  create(
    country: BankAccount.country,
    connectorID: BankAccount.connectorID,
    name: BankAccount.name,
    accountNumber?: BankAccount.accountNumber,
    iban?: BankAccount.iban,
    swiftBicCode?: BankAccount.swiftBicCode,
    metadata?: BankAccount.metadata,
  ): FormanceResponse<BankAccount> | PaymentsError;

  @FormanceApiStd.operation
  @paginated
  @useAuth(PaymentsWrite)
  list(
    ...PaginatedQuery,
    @query({
      format: "multi",
    })
    sort?: string[],
  ): PaginatedResponse<BankAccount> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  get(
    @path bankAccountId: string,
  ): FormanceResponse<BankAccount> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @route("{bankAccountId}/forward")
  forward(
    @path bankAccountId: string,
    connectorID: string
  ): FormanceResponse<BankAccount> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @route("{bankAccountId}/metadata")
  updateMetatdata(
    @path bankAccountId: string,
    metadata: Record<string>
  ): void | PaymentsError;
}
