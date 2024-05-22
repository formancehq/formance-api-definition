import "@typespec/http";
import "@formance/api-std";
import "@typespec/openapi";
import "./errors.tsp";
import "../oauth.tsp";

namespace Formance.Payments;

using FormanceApiStd;
using TypeSpec.Http;

model ConnectorConfigBase {
  name: string;

  @doc("The frequency at which the connector will try to fetch new BalanceTransaction objects from Stripe API.")
  pollingPeriod?: string = "120s";
}

model StripeConfig {
  ...ConnectorConfigBase;
  apiKey: string;

  @minValue(0)
  pageSize?: int64 = 10;
}

model DumypayConfig {
  name: string;

  @doc("The frequency at which the connector will try to fetch new payment objects from the directory")
  filePollingPeriod?: string = "10s";

  directory: string;
  prefixFileToIngest?: string;
  numberOfAccountsPreGenerated?: int64;
  numberOfPaymentsPreGenerated?: int64;
}

model WiseConfig {
  name: string;

  @doc("The frequency at which the connector will try to fetch new BalanceTransaction objects from Stripe API.")
  pollingPeriod?: string = "120s";

  apiKey: string;
}

model ModulrConfig {
  name: string;
  apiKey: string;
  apiSecret: string;
  endpoint?: string;

  @doc("The frequency at which the connector will try to fetch new BalanceTransaction objects from Stripe API.")
  pollingPeriod?: string = "120s";
}

model CurrencyCloudConfig {
  name: string;
  apiKey: string;
  loginID: string;

  @doc("The frequency at which the connector will try to fetch new BalanceTransaction objects from Stripe API.")
  pollingPeriod?: string = "120s";

  @doc("The endpoint to use for the API")
  endpoint?: string = "https://devapi.currencycloud.com";
}

model BankingCircleConfig {
  ...ConnectorConfigBase;
  username: string;
  password: string;
  endpoint: string;
  authorizationEndpoint: string;
  userCertificate: string;
  userCertificateKey: string;
}

model MangoPayConfig {
  ...ConnectorConfigBase;
  clientID: string;
  apiKey: string;
  endpoint: string;
}

model MoneycorpConfig {
  ...ConnectorConfigBase;
  clientID: string;
  apiKey: string;
  endpoint: string;
}

model AtlarConfig {
  ...ConnectorConfigBase;

  /** The base URL the client uses for making requests towards the Atlar API. */
  baseUrl?: string = "https://api.atlar.com";

  /** The frequency at which the connector tries to fetch the status of payment initiations from the Atlar API. */
  transferInitiationStatusPollingPeriod?: string = "120s";

  /** The access key used by the connector for authorizing requests to the Atlar API. You can obtain it along with the associated secret from the Atlar dashboard. */
  accessKey: string;

  /** The secret used by the connector for authorizing requests to the Atlar API. You can obtain it along with the associated access key from the Atlar dashboard. */
  secret: string;

  /** Number of items to fetch when querying paginated APIs. */
  @minValue(0)
  pageSize?: int64 = 25;
}

model AdyenConfig {
  ...ConnectorConfigBase;
  apiKey: string;
  hmacKey: string;
  liveEndpointPrefix?: string;
}

model GenericConfig {
  ...ConnectorConfigBase;
  apiKey: string;
  endpoint: string;
}

enum Connector {
  STRIPE,
  `DUMMY-PAY`,
  WISE,
  MODULR,
  `CURRENCY-CLOUD`,
  `BANKING-CIRCLE`,
  MANGOPAY,
  MONEYCORP,
  ATLAR,
  ADYEN,
  GENERIC,
}

alias ConnectorConfig =
  | StripeConfig
  | DumypayConfig
  | WiseConfig
  | ModulrConfig
  | CurrencyCloudConfig
  | BankingCircleConfig
  | MangoPayConfig
  | MoneycorpConfig
  | AtlarConfig
  | AdyenConfig
  | GenericConfig;

@format("uuid")
scalar TaskId extends string;

model TaskBase {
  id: TaskId;
  connectorID: string;
  createdAt: utcDateTime;
  updatedAt: utcDateTime;
  status: PaymentStatus;
  state: Record<unknown>;
  error?: string;
  descriptor: string;
}

model TaskStripe extends TaskBase {}
model TaskWise extends TaskBase {}
model TaskCurrencyCloud extends TaskBase {}
model TaskDummyPay extends TaskBase {}
model TaskModulr extends TaskBase {}
model TaskBankingCircle extends TaskBase {}
model TaskMangoPay extends TaskBase {}
model TaskMoneyCorp extends TaskBase {}

alias Task =
  | TaskStripe
  | TaskWise
  | TaskCurrencyCloud
  | TaskDummyPay
  | TaskModulr
  | TaskBankingCircle
  | TaskMangoPay
  | TaskMoneyCorp;

@Speakeasy.group
@route("connectors")
namespace Connectors {
  @Speakeasy.group
  interface V1 {
    @Speakeasy.autoGroup
    @useAuth(FormanceOAuth<["payments:write"]>)
    install(@path connector: Connector, @bodyRoot config: ConnectorConfig): {
      @statusCode _: 201;
      ...FormanceResponse<{
        connectorId: string;
      }>;
    } | PaymentsError;

    @Speakeasy.autoGroup
    @delete
    @useAuth(FormanceOAuth<["payments:write"]>)
    uninstall(
      @path connector: Connector,
      @path connectorID: string,
    ): void | PaymentsError;

    @Speakeasy.autoGroup
    @post
    @useAuth(FormanceOAuth<["payments:write"]>)
    update(
      @path connector: Connector,
      @path connectorID: string,
      @bodyRoot config: ConnectorConfig,
    ): void | PaymentsError;

    @Speakeasy.autoGroup
    @useAuth(FormanceOAuth<["payments:read"]>)
    @route("{connector}/{connectorId}/config")
    get(
      @path connector: Connector,
      @path connectorId: string,
    ): FormanceResponse<ConnectorConfig> | PaymentsError;

    @Speakeasy.autoGroup
    @useAuth(FormanceOAuth<["payments:write"]>)
    @route("{connector}/{connectorId}/reset")
    @post
    reset(
      @path connector: Connector,
      @path connectorId: string,
    ): void | PaymentsError;

    @Speakeasy.autoGroup
    @useAuth(FormanceOAuth<["payments:read"]>)
    @route("{connector}/{connectorId}/tasks")
    @paginated
    listTask(
      @path connector: Connector,
      @path connectorId: string,
      @query pageSize?: int64 = 15,
      @query cursor?: string
    ): PaginatedResponse<Task> | PaymentsError;

    @Speakeasy.autoGroup
    @useAuth(FormanceOAuth<["payments:read"]>)
    @route("{connector}/{connectorId}/tasks/{taskId}")
    getTask(
      @path connector: Connector,
      @path connectorId: string,
      @path taskId: string
    ): FormanceResponse<Task> | PaymentsError;
  }
}
