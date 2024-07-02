import "./auth.tsp";
import "./error.tsp";
import "@formance/api-std";
import "@typespec/compiler";
import "@typespec/http";
import "@typespec/openapi";
import "./workflows.tsp";

using FormanceApiStd;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Flows;

model Trigger {
  event: string;
  workflowId: string;
  id: string;
  createdAt: utcDateTime;
  filter?: string;
  name?: string;
  vars?: Record<unknown>;
}

model TriggerTest {
  filter?: {
    match?: boolean;
    error?: string;
  };
  variables?: Record<{
    value?: string;
    error?: string;
  }>;
}

model TriggerOccurence {
  date: utcDateTime;
  workflowInstanceId?: string;
  workflowInstance?: WorkflowInstance;
  triggerID: string;
  error?: string;
  event: unknown;
}

@Speakeasy.group("Triggers")
@route("triggers")
interface Triggers {
  @FormanceApiStd.operation
  @useAuth(FlowsRead)
  @FormanceApiStd.paginated
  list(
    @query name?: string,
    ...PaginatedQuery,
  ): PaginatedResponse<Trigger[]> | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsWrite)
  create(
    event: Trigger.event,
    workflowId: Trigger.workflowId,
    filter?: Trigger.filter,
    vars?: Trigger.vars,
    name?: Trigger.name,
  ): {
    @statusCode _: 201;
    ...FormanceResponse<Trigger>;
  } | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsRead)
  get(@path id: string): FormanceResponse<Trigger> | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsWrite)
  @delete
  delete(@path id: string): void | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsWrite)
  @route("{id}/test")
  test(
    @path id: string,
    @bodyRoot parameters: Record<unknown>,
  ): FormanceResponse<TriggerTest> | FlowError;

  @FormanceApiStd.operation
  @useAuth(FlowsRead)
  @FormanceApiStd.paginated
  @route("{id}/occurences")
  listOccurences(
    @path id: string,
    ...PaginatedQuery,
  ): PaginatedResponse<TriggerOccurence>;
}
