import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";
import "./errors.tsp";
import "./auth.tsp";
import "./transaction.tsp";

using Http;
using Rest;
using FormanceApiStd;

namespace Ledger;

model Ledger {
  name: string;
  addedAt: utcDateTime;
  bucket: string;
}

enum MigrationState {
  TODO: "TO DO",
  DONE
}

model Migration {
  version: int64;
  name: string;
  date: utcDateTime;
  state: MigrationState;
}

model LedgerInfo {
  name: string;
  storage: {
    migrations: Migration[]
  }
};

model CreateTransactionAction {
  action: "CREATE_TRANSACTION";
  ik?: string;
  data: CreateTransactionInput;
}

model AddMetadataAction {
  action: "ADD_METADATA";
  ik?: string;
  data: AddMetadataTarget
}

model AddMetadataTargetAccount {
  targetType: "ACCOUNT";
  targetId: string;
  metadata: Record<string>
}

model AddMetadataTargetTransaction {
  targetType: "TRANSACTION";
  targetId: integer;
  metadata: Record<string>;
}

@discriminator("targetType")
union AddMetadataTarget {
  ACCOUNT: AddMetadataTargetAccount;
  TRANSACTION: AddMetadataTargetTransaction;
}

model RevertTransactionAction {
  action: "REVERT_TRANSACTION";
  ik?: string;
  data: {
    id: string;
    force?: boolean;
    atEffectiveData?: boolean;
  };
}

model DeleteMetadataTargetTransaction {
  targetId: integer;
  targetType: "TRANSACTION";
  key: string;
}

model DeleteMetadataTargetAccount {
  targetId: string;
  targetType: "ACCOUNT";
  key: string;
}

@discriminator("targetType")
union DeleteMetadataTarget {
  ACCOUNT: DeleteMetadataTargetAccount;
  TRANSACTION: DeleteMetadataTargetTransaction;
};

model DeleteMetadataAction {
  action: "DELETE_METADATA";
  ik?: string;
  data: DeleteMetadataTarget;
};

@discriminator("action")
union BulkAction {
  CREATE_TRANSACTION: CreateTransactionAction;
  ADD_METADATA: AddMetadataAction;
  REVERT_TRANSACTION: RevertTransactionAction;
  DELETE_METADATA: DeleteMetadataAction;
};

model CreateTransactionActionResponse { 
  responseType: "CREATE_TRANSACTION";
  data: Transaction;
}

model RevertTransactionActionResponse { 
  responseType: "REVERT_TRANSACTION";
  data: Transaction;
}

model AddMetadataActionResponse { responseType: "ADD_METADATA" };

model DeleteMetadataActionResponse { responseType: "DELETE_METADATA" };

@discriminator("responseType")
union BulkResponse {
  CREATE_TRANSACTION: CreateTransactionActionResponse;
  REVERT_TRANSACTION: RevertTransactionActionResponse;
  ADD_METADATA: AddMetadataActionResponse;
  DELETE_METADATA: DeleteMetadataActionResponse;
};

@Speakeasy.group("Ledgers")
interface Ledgers {
  @FormanceApiStd.operation
  @paginated
  @useAuth(LedgerRead)
  op list(...PaginatedQuery): PaginatedResponse<Ledger> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  op get(@path ledger: string): FormanceResponse<Ledger> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  op create(@path ledger: string, bucket?: string): void | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  @route("/{ledger}/_info")
  info(@path ledger: string): FormanceResponse<LedgerInfo> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  @route("{ledger}/metadata")
  @put
  op addMetadata(@path ledger: string, @bodyRoot metadata: Record<string>): void | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  @route("{ledger}/metadata/{key}")
  @delete
  op removeMetadata(@path ledger: string, @path key: string): void | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  @route("{ledger}/_bulk")
  bulk(@path ledger: string, @bodyRoot operations: BulkAction[]): FormanceResponse<BulkResponse[]> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  @route("{ledger}/stats")
  op stats(@path ledger: string): FormanceResponse<{ @minValue(0) account: int64; @minValue(0) transactions: int64; }> | LedgerError;
}