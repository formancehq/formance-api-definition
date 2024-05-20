import "../dist/src/decorators.js";
import "../dist/src/speakeasy.js";
import "@typespec/http";

using TypeSpec.Reflection;
using TypeSpec.Http;


namespace FormanceApiStd;

/**
 * Add the speakeasy pagination configuration matching the Formance standard to an API operation
 */
extern dec paginated(target: Operation);

model PaginatedQuery {
  @query
  cursor?: string
}

model PaginatedResponse<T> {
  cursor: {
    next?: string,
    data: T[]
  }
}

namespace Speakeasy {
  extern dec autoGroup(target: Operation);
  extern dec group(target: Namespace | Interface);
};