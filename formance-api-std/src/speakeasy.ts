import { DecoratorContext, Namespace, Operation, Interface, Program } from "@typespec/compiler";
import { setExtension } from "@typespec/openapi";

export const namespace = "FormanceApiStd.Speakeasy";

/**
 * Collects all the groups that the operation belongs to.
 * 
 * Groups are the name of either the namespace or the interface that the operation belongs to and all its parent namespaces and interfaces, lowercased.
 * Only the namespace or interface that have the @Speakeasy.group decorator are considered.
 */
function collectSpeakeasyGroups(program: Program, current: Namespace | Interface | undefined): string[] {
  if(current === undefined) {
    return [];
  }

  const parentGroups = collectSpeakeasyGroups(program, current.namespace);

  const group = current.decorators.find(d => d.decorator === $group);
  if(group) {
    return [...parentGroups, current.name.toLowerCase()];
  } else {
    return parentGroups;
  }
}

export function $autoGroup(context: DecoratorContext, target: Operation) {
  const groups = collectSpeakeasyGroups(context.program, target.interface ?? target.namespace);

  setSpeakeseasyGroup(context.program, target, groups);
  setExtension(context.program, target, "x-speakeasy-name-overridde", target.name);
  setExtension(context.program, target, "x-speakeasy-errors", {
    statusCodes: ["default"]
  });
}

export function $group() {

}

export function setSpeakeseasyGroup(program: Program, target: Operation, group: string[]) {
  const groupStr = group.join(".");

  setExtension(program, target, "x-speakeasy-group", groupStr);
}