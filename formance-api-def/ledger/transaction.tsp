import "@formance/api-std";
import "@typespec/http";
import "@typespec/openapi3";
import "./errors.tsp";
import "./auth.tsp";

namespace Ledger;

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

alias Metadata = Record<string>;
alias Volumes = Record<Record<{
  input: integer;
  output: integer;
  balance?: integer;
}>>;

model Posting {
  @minValue(0) amount: integer;
  asset: string;
  destination: string;
  source: string;
}

model Transaction {
  timestamp: utcDateTime;
  postings: Posting[];
  reference?: string;
  metadata: Metadata;
  id: string;
  reverted: boolean;
}

model CreateTransactionBase {
  timestamp?: utcDateTime;
  reference?: string;
  metadata: Metadata;
}

alias CreateTransactionInput = CreateTransactionWithPostings | CreateTransactionWithNumscript;

model CreateTransactionWithPostings {
  ...CreateTransactionBase;
  postings: Posting[];
}

model CreateTransactionWithNumscript {
  ...CreateTransactionBase;
  script: {
    plain: string;
    vars?: Record<unknown>;
  };
}

model ExpendedTransaction {
  ...Transaction;
  preCommitVolumes?: Volumes;
  postCommitVolumes?: Volumes;
}

alias TransactionFilters = Record<unknown>;

@route("{ledger}/transactions")
@Speakeasy.group("Transactions")
interface Transactions {
  @FormanceApiStd.operation
  @head
  @useAuth(LedgerRead)
  count(
    @path ledger: string,
    @query pit?: utcDateTime,
    @query query?: TransactionFilters,
  ): {
    @header("Count") @minValue(0) count: int64;
    @statusCode _: 204;
  } | LedgerError;

  @FormanceApiStd.operation
  @useAuth(FormanceOAuth<["ledger:read"]>)
  @paginated
  list(
    @path ledger: string,
    @query expand?: string,
    @query pit?: boolean,
    ...PaginatedQuery,
    @query query?: TransactionFilters,
  ): PaginatedResponse<Transaction> | LedgerError;

  @FormanceApiStd.operation
  @post
  @useAuth(LedgerWrite)
  create(
    @path ledger: string,
    @bodyRoot @oneOf input: CreateTransactionInput,
    @header("Idempotency-Key") idenpotencyKey?: string,
    @query dryRun?: boolean,
  ): FormanceResponse<Transaction> | LedgerError;

  @FormanceApiStd.operation
  @useAuth(LedgerRead)
  get(
    @path ledger: string,
    @path id: integer,
    @query expand?: string,
    @query pit?: utcDateTime,
  ): FormanceResponse<ExpendedTransaction> | LedgerError;

  @route("{id}/metadata")
  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  addMetadata(
    @path ledger: string,
    @path id: integer,
    metadata: Metadata,
    @query dryRun?: boolean,
    @header("Idempotency-Key") idempotencyKey?: string,
  ): void | LedgerError;

  @route("{id}/metadata/{key}")
  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  @delete
  deleteMetadata(
    @path ledger: string,
    @path id: string,
    @path key: string,
  ): void | LedgerError;

  @post
  @route("{id}/revert")
  @FormanceApiStd.operation
  @useAuth(LedgerWrite)
  revert(
    @path ledger: string,
    @path id: integer,
    @query force?: boolean,
    @query atEffectiveDate?: utcDateTime,
  ): {
    @statusCode _: 201;
    ...FormanceResponse<Transaction>;
  } | LedgerError;
}
