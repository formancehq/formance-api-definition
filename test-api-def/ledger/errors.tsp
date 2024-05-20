namespace Ledger;

enum LedgerErrors {
  INTERNAL,
  INSUFFICIENT_FUND,
  VALIDATION,
  CONFLICT,
  COMPILATION_FAILED,
  METADATA_OVERRIDE,
  NOT_FOUND,
  REVERT_OCCURRING,
  ALREADY_REVERT,
  NO_POSTINGS,
  LEDGER_NOT_FOUND,
}

@error
model LedgerError {
  errorCode: LedgerErrors;
  errorMessage: string;
  details?: string;
}