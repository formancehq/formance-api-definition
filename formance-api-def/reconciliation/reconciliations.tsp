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

model Reconciliation {
  id: string;
  policyID: string;
  createdAt: utcDateTime;
  reconciliedAtLedger: utcDateTime;
  reconciliedAtPayments: utcDateTime;
  status: string;
  paymentsBalances: Record<integer>;
  ledgerBalances: Record<integer>;
  driftBalances: Record<integer>;
  error?: string;
}

@route("policies/{policyID}/reconciliation")
@FormanceApiStd.operation
op reconcile(
  @path policyID: string,
  reconciledAtLedger: utcDateTime,
  reconciliedAtPayments: utcDateTime,
): FormanceResponse<Reconciliation> | ReconciliationError;

@Speakeasy.group("ReconciliationsV1")
@route("reconciliations")
interface ReconciliationsV1 {

  @FormanceApiStd.operation
  @FormanceApiStd.paginated
  op list(
    @query pageSize?: int64 = 100,
    @query cursor?: string,
  ): PaginatedResponse<Reconciliation> | ReconciliationError;

  @FormanceApiStd.operation
  op get(@path reconciliationId: string): FormanceResponse<Reconciliation> | ReconciliationError;
}
