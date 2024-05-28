import { createTypeSpecLibrary } from "@typespec/compiler";

export const $lib = createTypeSpecLibrary({
  name: "typespec-formance",
  diagnostics: {
    "missing-cursor-parameter": {
      severity: "error",
      messages: {
        default: "Operation is missing a query parameter named 'cursor'. Add it or remove the @paginated decorator."
      }
    },
    "cursor-not-query-parameter": {
      severity: "error",
      messages: {
        default: "The 'cursor' parameter must be a query parameter."
      }
    },
    "cursor-not-optional-string": {
      severity: "error",
      messages: {
        default: "The 'cursor' parameter must be an optional string."
      }
    },
    "paginated-response-no-cursor": {
      severity: "error",
      messages: {
        default: "The response type must have a property named 'cursor', or one of its variants must have it."
      }
    },
    "paginated-response-cursor-not-object": {
      severity: "error",
      messages: {
        default: "The 'cursor' property must be an object."
      }
    },
    "paginated-response-cursor-no-next": {
      severity: "error",
      messages: {
        default: "The 'cursor' object must have a property named 'next'."
      }
    },
    "paginated-response-cursor-no-data": {
      severity: "error",
      messages: {
        default: "The 'cursor' object must have a property named 'data'."
      }
    },
    "paginated-response-cursor-next-not-string": {
      severity: "error",
      messages: {
        default: "The 'next' property of the 'cursor' object must be a string."
      }
    },
    "paginated-response-cursor-next-not-optional": {
      severity: "error",
      messages: {
        default: "The 'next' property of the 'cursor' object must be optional."
      }
    },
    "paginated-response-cursor-data-not-array": {
      severity: "error",
      messages: {
        default: "The 'data' property of the 'cursor' object must be an array."
      }
    },
  },
  state: {
    speakeasyGroup: { description: "The group that the interface belongs to for Speakeasy." },
  }
});

export const { reportDiagnostic, createDiagnostic, stateKeys: StateKeys } = $lib;
