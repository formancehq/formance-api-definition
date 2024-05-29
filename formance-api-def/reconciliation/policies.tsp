import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";
import "./errors.tsp";
import "./auth.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

namespace Reconciliation;

model Policy {
  id: string;
  name: string;
  createdAt: utcDateTime;
  ledgerName: string;
  ledgerQuery: Record<unknown>;
  paymentsPoolID: string;
}

@Speakeasy.group("PoliciesV1")
@route("policies")
interface PoliciesV1 {
  @FormanceApiStd.operation
  @useAuth(ReconciliationRead)
  create(
    name: string,
    ledgerName: string,
    ledgerQuery: Record<unknown>,
    paymentsPoolID: string,
  ): {
    @statusCode _: 201;
    ...FormanceResponse<Policy>;
  } | ReconciliationError;

  @FormanceApiStd.operation
  @FormanceApiStd.paginated
  @useAuth(ReconciliationRead)
  list(
    @query pageSize: int64 = 15,
    @query cursor?: string,
  ): PaginatedResponse<Policy> | ReconciliationError;

  @delete
  @FormanceApiStd.operation
  @useAuth(ReconciliationWrite)
  op delete(@path policyID: string): void | ReconciliationError;

  @FormanceApiStd.operation
  @useAuth(ReconciliationRead)
  op get(@path policyID: string): FormanceResponse<Policy> | ReconciliationError;
}
