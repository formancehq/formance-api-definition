import "./auth.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Payments;

enum TransferInitiationType {
  TRANSFER,
  PAYOUT,
}

enum TransferInitiationStatus {
  WAITING_FOR_VALIDATION,
  PROCESSING,
  PROCESSED,
  FAILED,
  REJECTED,
  VALIDATED,
  ASK_RETRIED,
  ASK_REVERSED,
  REVERSE_PROCESSING,
  REVERSE_FAILED,
  PARTIALLY_REVERSED,
  REVERSED,
}

enum TransferInitiationWritableStatus {
  WAITING_FOR_VALIDATION,
  PROCESSING,
  PROCESSED,
  FAILED,
  REJECTED,
  VALIDATED,
}

model TransferInitiationPayment {
  paymentID: string;
  createdAt: utcDateTime;
  status: TransferInitiationStatus;
  error: string;
}

model TransferInitiation {
  id: string;
  reference: string;
  createdAt: utcDateTime;
  scheduledAt: utcDateTime;
  description: string;
  sourceAccountID: string;
  destinationAccountID: string;
  connectorID: string;
  type: TransferInitiationType;
  amount: integer;
  initialAmount: integer;
  asset: string;
  status: TransferInitiationStatus;
  error: string;
  metadata?: Record<string>;
  relatedPayments?: TransferInitiationPayment[];
}

@Speakeasy.group("TransferInitiations")
@route("transfer-initiations")
interface TransferInitiations {
  @FormanceApiStd.operation
  @paginated
  @useAuth(PaymentsRead)
  list(
    ...PaginatedQuery,

    @query({
      format: "multi",
    })
    sort?: string[],

    @query query?: Record<unknown>,
  ): PaginatedResponse<TransferInitiation> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  create(
    reference: TransferInitiation.reference,
    scheduledAt: TransferInitiation.scheduledAt,
    description: TransferInitiation.description,
    sourceAccountID: TransferInitiation.sourceAccountID,
    destinationAccountID: TransferInitiation.destinationAccountID,
    connectorID?: TransferInitiation.connectorID,
    provider?: Connector,
    type: TransferInitiation.type,
    amount: TransferInitiation.amount,
    asset: TransferInitiation.asset,
    validated: boolean,
    metadata?: TransferInitiation.metadata,
  ): FormanceResponse<TransferInitiation> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsRead)
  get(
    @path transferId: string,
  ): FormanceResponse<TransferInitiation> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @delete
  delete(@path transferId: string): void | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @route("{transferId}/status")
  updateStatus(
    @path transferId: string,
    status: TransferInitiationWritableStatus,
  ): void | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @route("{transferId}/reverse")
  op reverse(
    @path transferId: string,
    reference: TransferInitiation.reference,
    description: TransferInitiation.description,
    amount: TransferInitiation.amount,
    asset: TransferInitiation.asset,
    metatdata?: TransferInitiation.metadata
  ): void | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(PaymentsWrite)
  @route("{transferId}/retry")
  op retry(@path transferId: string): void | PaymentsError;
}
