import { resolvePath } from "@typespec/compiler";
import { createTestLibrary, TypeSpecTestLibrary } from "@typespec/compiler/testing";
import { fileURLToPath } from "url";

export const TypespecFormanceTestLibrary: TypeSpecTestLibrary = createTestLibrary({
  name: "typespec-formance",
  packageRoot: resolvePath(fileURLToPath(import.meta.url), "../../../../"),
});
