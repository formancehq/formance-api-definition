import "@typespec/http";

using TypeSpec.Http;

namespace Wallets;

enum WalletsErrorCodes {
  VALIDATION,
  INTERNAL_ERROR,
  INSUFFICIENT_FUND,
  HOLD_CLOSED,
}

@error
model WalletsError {
  errorCode: WalletsErrorCodes;
  errorMessage: string;
}

@error
model WalletNotFound {
  @statusCode _ : 404
}