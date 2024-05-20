import { createTestHost, createTestWrapper } from "@typespec/compiler/testing";
import { TypespecFormanceTestLibrary } from "../src/testing/index.js";

export async function createTypespecFormanceTestHost() {
  return createTestHost({
    libraries: [TypespecFormanceTestLibrary],
  });
}

export async function createTypespecFormanceTestRunner() {
  const host = await createTypespecFormanceTestHost();

  return createTestWrapper(host, {
    autoUsings: ["TypespecFormance"]
  });
}

