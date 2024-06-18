import "@typespec/http";

using TypeSpec.Http;

model FormanceOAuth<Scopes extends string[]> is OAuth2Auth<[{
  type: OAuth2FlowType.clientCredentials;
  tokenUrl: "/api/auth/oauth/token"
}], Scopes>;