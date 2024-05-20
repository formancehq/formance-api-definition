import "@typespec/http";

using TypeSpec.Http;

namespace Formance;

model FormanceOAuth<Scopes extends valueof string[]> is OAuth2Auth<[{
  type: OAuth2FlowType.clientCredentials;
  tokenUrl: "/api/auth/token"
}], Scopes>;