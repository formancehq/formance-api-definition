import { DecoratorContext, Interface } from "@typespec/compiler";
import { StateKeys } from "./lib.js";

export const namespace = "FormanceApiStd.Speakeasy";


export function $group(context: DecoratorContext, target: Interface, ...groups: string[]) {
  context.program.stateMap(StateKeys.speakeasyGroup).set(target, groups);
}
