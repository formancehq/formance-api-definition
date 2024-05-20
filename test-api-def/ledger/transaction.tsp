import "@formance/api-std";
import "@typespec/http";
import "@typespec/openapi3";
import "./errors.tsp";

namespace Ledger;

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

alias Metadata = Record<unknown>;
alias Volumes = Record<Record<{
  input: integer,
  output: integer,
  balance?: integer
}>>;

model Posting {
  amount: integer,
  asset: string,
  destination: string,
  source: string
}

model Transaction {
  timestamp: utcDateTime;
  postings: Posting[],
  reference? : string,
  metadata?: Metadata,
  txId: string,
  preCommitVolumes?: Volumes,
  postCommitVolumes?: Volumes
}


model CreateTransactionBase {
  timestamp?: utcDateTime,
  reference?: string,
  metadata?: Metadata,
}

model CreateTransactionInput {
  ...CreateTransactionBase,
  postings?: Posting[],
  script?: {
    plain: string,
    vars?: Record<unknown>
  }
}

model CreateTransactionWithPostings {
  ...CreateTransactionBase,
  postings: Posting[]
}

model CreateTransactionWithNumscript { 
  ...CreateTransactionBase,
  script: {
    plain: string,
    vars?: Record<unknown>
  }
}

@Speakeasy.group
@route("{ledger}/transactions")
namespace Transactions {

  model TransactionFilters {
    @query reference?: string,
    @query account?: string,
    @query source?: string,
    @query destination?: string,
    @query startTime?: string,
    @query endTime?: string,
    @query metadata?: Record<unknown>
  }

  @Speakeasy.group
  interface V1 {

    @Speakeasy.autoGroup
    @head
    @useAuth(LedgerAuth<["ledger:read"]>)
    op count(
      @path ledger: string,
      ...TransactionFilters
    ): int64 | LedgerError;

    @Speakeasy.autoGroup
    @useAuth(LedgerAuth<["ledger:read"]>)
    op list(
      @path ledger: string,

      @query @minValue(1) @maxValue(1000) pageSize?: int64,
      @query cursor?: string,
      ...TransactionFilters
    ): PaginatedResponse<Transaction> | LedgerError;

    @Speakeasy.autoGroup
    @post
    @useAuth(LedgerAuth<["ledger:write"]>)
    op create(@path ledger: string, ...CreateTransactionInput): FormanceResponse<Transaction[]> | LedgerError;

    @overload(Ledger.Transactions.V1.create)
    @post
    @useAuth(LedgerAuth<["ledger:write"]>)
    op createWithNumscript(@path ledger: string, ...CreateTransactionWithNumscript): FormanceResponse<Transaction[]> | LedgerError;

    @overload(Ledger.Transactions.V1.create)
    @post
    @useAuth(LedgerAuth<["ledger:write"]>)
    op createWithPostings(@path ledger: string, ...CreateTransactionWithPostings): FormanceResponse<Transaction[]> | LedgerError;

    @Speakeasy.autoGroup
    @useAuth(LedgerAuth<["ledger:read"]>)
    op get(@path ledger: string, @path txid: integer): Transaction | LedgerError;

    @route("{txid}/metadata")
    @Speakeasy.autoGroup
    @useAuth(LedgerAuth<["ledger:write"]>)
    op addMetadata(@path ledger: string, @path txid: integer, metadata: Metadata): void | LedgerError;

    @post
    @route("{txid}/revert")
    @Speakeasy.autoGroup
    @useAuth(LedgerAuth<["ledger:write"]>)
    op revert(@path ledger: string, @path txid: integer, @query disableChecks?: boolean): {
      @statusCode _: 201,
      ...FormanceResponse<Transaction>
    } | LedgerError;

    @post
    @route("/batch")
    @Speakeasy.autoGroup
    @useAuth(LedgerAuth<["ledger:write"]>)
    op batchCreate(@path ledger: string, transaction: CreateTransactionWithPostings[]): FormanceResponse<Transaction[]> | LedgerError;
  }
}
