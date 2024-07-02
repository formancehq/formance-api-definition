import "./auth.tsp";
import "./error.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Flows;

model WorkflowConfig {
  name?: string;
  stages: Record<unknown>[];
}

model Workflow {
  config: WorkflowConfig;
  createdAt: utcDateTime;
  updatedAt: utcDateTime;
  id: string;
}

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

@Speakeasy.group("Workflows")
@route("workflows")
interface Workflows {
  @FormanceApiStd.operation
  @FormanceApiStd.paginated
  @useAuth(FlowsRead)
  list(...PaginatedQuery): PaginatedResponse<Workflow> | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsWrite)
  create(...WorkflowConfig): {
    @statusCode _: 201;
    ...FormanceResponse<Workflow>;
  } | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsRead)
  get(@path id: string): FormanceResponse<Workflow> | FlowError;

  @FormanceApiStd.operation
  @delete
  @useAuth(FlowsWrite)
  delete(@path id: string): void | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsWrite)
  @route("{id}/run")
  run(
    @path id: string,
    @query wait?: boolean,
    @bodyRoot parameters: Record<unknown>,
  ): FormanceResponse<WorkflowInstance> | FlowError;
}
