import "./auth.tsp";
import "./error.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";
import "../ledger/transaction.tsp";
import "../wallets/wallets.tsp";
import "../ledger/account.tsp";
import "../payments/payments.tsp";
import "../wallets/holds.tsp";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Flows;

model WorkflowStatus {
  stage: integer;
  instanceId: string;
  startedAt: utcDateTime;
  terminatedAt?: utcDateTime;
  error?: string;
}

model WorkflowInstance {
  workflowId: string;
  id: string;
  createdAt: utcDateTime;
  updatedAt: utcDateTime;
  status?: WorkflowStatus;
  terminated: boolean;
  terminatedAt?: utcDateTime;
  error?: utcDateTime;
}

alias StageSendSource = {
  wallet: {
    id: string;
    balance?: string;
  };
} | {
  account: {
    id: string;
    ledger?: string;
  };
} | {
  paymnts: {
    id: string;
  };
};

alias StageSendDestination = {
  wallet: {
    id: string;
    balance?: string;
  };
} | {
  account: {
    id: string;
    ledger?: string;
  };
} | {
  paymnts: {
    psp: string;
  };
};

model StageSend {
  amount?: {
    asset: string;
    amount: integer;
  };
  destination: StageSendDestination;
  source: StageSendSource;
  metadata?: Record<string>;
  timestamp: utcDateTime;
}

model StageDelay {
  until?: utcDateTime;
  duration?: string;
}

model StageWaitEvent {
  event: string;
}

model WorkflowInstanceHistory {
  name: string;
  input: StageSend | StageDelay | StageWaitEvent;
  error?: string;
  terminated: boolean;
  startedAt: utcDateTime;
  terminatedAt?: utcDateTime;
}

alias CreateTransactionInput = Ledger.CreateTransactionInput;
alias CreditWalletInput = Wallets.CreditWalletInput;
alias DebitWalletInput = Wallets.DebitWalletInput;
alias Account = Ledger.Account;
alias Transaction = Ledger.Transaction;
alias Payment = Payments.Payment;
alias Hold = Wallets.Hold;
alias Wallet = Wallets.Wallet;

alias StageInput =
  | {
      GetAccount: {
        id: string;
        ledger: string;
      };
    }
  | {
      CreateTransaction: {
        ledger?: string;
        data: CreateTransactionInput;
      };
    }
  | {
      GetPayment: {
        id: string;
      };
    }
  | {
      ConfirmHold: {
        id: string;
      };
    }
  | {
      CreditWallet: {
        id?: string;
        data: CreditWalletInput;
      };
    }
  | {
      DebitWallet: {
        id?: string;
        data: DebitWalletInput;
      };
    }
  | {
      GetWallet: {
        id: string;
      };
    }
  | {
      VoidHold: {
        id: string;
      };
    }
  | {
      ListWallets: {
        name?: string;
      };
    }
  | {
      StripeTransfer: {
        connectorId?: string;
        amount?: integer;
        asset?: string;
        destination?: string;
        waitingValidation?: boolean;
        metadata?: Record<string>;
      };
    };

alias StageOutput =
  | {
      GetAccount: {
        data: Account;
      };
    }
  | {
      CreateTransaction: {
        data: Transaction[];
      };
    }
  | {
      GetPayment: {
        data: Payment;
      };
    }
  | {
      DebitWallet: {
        data: Hold;
      };
    }
  | {
      GetWallet: {
        data: {
          ...Wallet;
          balances: Record<{
            assets: Record<integer>;
          }>;
        };
      };
    }
  | {
      ListWallet: {
        data: PaginatedResponse<Wallet>;
      };
    };

model WorkflowInstanceHistoryStage {
  name: string;
  input: StageInput;
  output?: StageOutput;
  error?: string;
  terminated: boolean;
  startedAt: utcDateTime;
  terminatedAt?: utcDateTime;
  astFailure?: string;
  attempt: integer;
  nextExecution?: utcDateTime;
}

@Speakeasy.group("Instances")
@route("instances")
interface Instances {
  @FormanceApiStd.paginated
  @useAuth(FlowsRead)
  @FormanceApiStd.operation
  list(
    ...PaginatedQuery,
    @query workflowId: string,
    @query running: boolean,
  ): PaginatedResponse<WorkflowInstance> | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsRead)
  get(@path id: string): FormanceResponse<WorkflowInstance> | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsWrite)
  @route("{id}/events")
  send(@path id: string, name: string): void | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsWrite)
  @route("{id}/abort")
  @put
  abort(@path id: string): void | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsRead)
  @route("{id}/history")
  getHistory(@path id: string): FormanceResponse<WorkflowInstanceHistory[]>;

  @FormanceApiStd.operation
  @useAuth(FlowsRead)
  @route("{id}/stages/{stageIndex}/history")
  getStageHistory(
    @path id: string,
    @path stageIndex: integer,
  ): FormanceResponse<WorkflowInstanceHistoryStage>;
}
