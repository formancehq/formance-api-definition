import "@typespec/http";
import "@formance/api-std";
import "@typespec/openapi";
import "./errors.tsp";
import "../oauth.tsp";

namespace Payments;

using FormanceApiStd;
using TypeSpec.Http;

@minValue(0)
scalar PaymentAmount extends integer;

alias Metadata = Record<string>;

model PaymentBase {
  reference: string;
  connectorID: string;
  amount: PaymentAmount;
  type: PaymentType;
  status: PaymentStatus;
  scheme: PaymentScheme;
  asset: string;
}

model CreatePaymentRequest extends PaymentBase {
  sourceAccountID?: string;
  destinationAccountID?: string;
}

model Payment extends PaymentBase {
  id: string;
  sourceAccountID: string;
  destinationAccountID: string;
  provider?: Connector;
  initialAmount: PaymentAmount;
  createdAt: utcDateTime;
  raw: Record<unknown>;
  adjustments: PaymentAdjustment[];
  metadata?: Metadata;
}

enum PaymentType {
  `PAY-IN`,
  PAYOUT,
  TRANSFER,
  OTHER,
}

enum PaymentStatus {
  PENDING,
  SUCCEEDED,
  CANCELLED,
  FAILED,
  EXPIRED,
  REFUNDED,
  REFUNDED_FAILURE,
  DISPUTE,
  DISPUTE_WON,
  DISPUTE_LOST,
  OTHER,
}

enum PaymentScheme {
  `unknown`,
  other,
  visa,
  mastercard,
  amex,
  diners,
  discover,
  jcb,
  unionpay,
  alipay,
  cup,
  `sepa debit`,
  `sepa credit`,
  sepa,
  `apple pay`,
  `google pay`,
  doku,
  dragonpay,
  maestro,
  molpay,
  a2a,
  `ach debit`,
  ach,
  rtp,
}

model PaymentAdjustment {
  reference: string;
  createdAt: utcDateTime;
  status: PaymentStatus;
  amount: PaymentAmount;
  raw: Record<unknown>;
}

@Speakeasy.group("payments", "v1")
@route("/payments")
interface PaymentsV1 {
  @FormanceApiStd.operation
  @useAuth(FormanceOAuth<["payments:read"]>)
  get(@path payementId: string): FormanceResponse<Payment>;

  @FormanceApiStd.operation
  @useAuth(FormanceOAuth<["payments:write"]>)
  create(...CreatePaymentRequest): FormanceResponse<Payment> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(FormanceOAuth<["payments:read"]>)
  @paginated
  list(
    @query
    @minValue(1)
    @maxValue(1000)
    pageSize?: int64,

    @query cursor?: string,
    @query({
      format: "multi",
    })
    sort?: string[],
    @query query?: string,
  ): PaginatedResponse<Payment> | PaymentsError;

  @FormanceApiStd.operation
  @useAuth(FormanceOAuth<["payments:write"]>)
  @patch
  @route("{paymentId}/metadata")
  op updateMetatdata(@path paymentId: string, ...Record<string>): void | PaymentsError;
}

