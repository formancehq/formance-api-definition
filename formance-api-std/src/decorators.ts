import { DecoratorContext, Operation, Type, isArrayModelType, isStringType, walkPropertiesInherited } from "@typespec/compiler";
import { setExtension } from "@typespec/openapi";
import { $query } from "@typespec/http";
import { reportDiagnostic } from "./lib.js";

export const namespace = "FormanceApiStd";

function validateQueryParameter(context: DecoratorContext, target: Operation) {
  const parameters = target.parameters.properties;
  // Check if the operation has a query parameter named "cursor"
  const cursor = parameters.get("cursor");
  if(cursor === undefined) {
    reportDiagnostic(context.program, {
      code: 'missing-cursor-parameter',
      target: target,
    })

    return;
  }

  // Check that the cursor parameter is a string and is optional
  if(cursor.optional === false || !isStringType(context.program, cursor.type)) {
    reportDiagnostic(context.program, {
      code: 'cursor-not-optional-string',
      target: cursor,
    })

    return;
  }

  // Check if the cursor parameter is a query parameter
  if(!cursor.decorators.find(d => d.decorator === $query)) {
    reportDiagnostic(context.program, {
      code: 'cursor-not-query-parameter',
      target: cursor,
    })

    return;
  }
}

// A valid response body must have a property named "cursor". 
// The value of this property must be an object with two properties: "next" and "data". 
// The "next" property must be a string and the "data" property must be an array.
function validateResponseType(context: DecoratorContext, type: Type): boolean {
  //console.log(type);
  // If the type is an union, we recursively check all the types in the union
  if(type.kind === "Union") {
    const variants = Array.from(type.variants.values());
    return variants.some(t => validateResponseType(context, t.type));
  }

  // If the type is not an object, we return false
  if(type.kind !== "Model") {
    return false;
  }

  const properties = [...walkPropertiesInherited(type)];

  // Check if the type has a property named "cursor"
  const cursor = properties.find(p => p.name === "cursor");
  if(!cursor) {
    return false;
  }

  // From now on, we return true regardless of the outcome of the following checks. 
  // Because now that we have a cursor property, we assume that this variant was intended 
  // to be a paginated response and we don't need to find another variant with a cursor property.

  const cursorType = cursor.type;

  // Check that the cursor property is an object
  if(cursorType.kind !== 'Model') {
    return true;
  }

  const cursorProperties = [...walkPropertiesInherited(cursorType)];

  // Check that the cursor object has two properties: "next" and "data"
  const nextProperty = cursorProperties.find(p => p.name === "next");
  const dataProperty = cursorProperties.find(p => p.name === "data");
  if(!nextProperty || !dataProperty) {
    if(!nextProperty) {
      reportDiagnostic(context.program, {
        code: 'paginated-response-cursor-no-next',
        target: cursorType,
      })
    }

    if(!dataProperty) {
      reportDiagnostic(context.program, {
        code: 'paginated-response-cursor-no-data',
        target: cursorType,
      })
    }
    return true;
  }

  // Check that the "next" property is optional
  if(nextProperty.optional === false) {
    reportDiagnostic(context.program, {
      code: 'paginated-response-cursor-next-not-optional',
      target: nextProperty,
    });

    return true;
  }

  // Check that the "next" property is a string
  const nextType = nextProperty.type;
  if(isStringType(context.program, nextType) === false){
    reportDiagnostic(context.program, {
      code: 'paginated-response-cursor-next-not-string',
      target: nextProperty,
    });

    return true;
  }

  // Check that the "data" property is an array
  const dataType = dataProperty.type;
  if(!(dataType.kind === 'Model' && isArrayModelType(context.program, dataType))) {
    reportDiagnostic(context.program, {
      code: 'paginated-response-cursor-data-not-array',
      target: dataProperty,
    });

    return true;
  }

  return true;
}

export function $paginated(context: DecoratorContext, target: Operation) {

  validateQueryParameter(context, target); 
  if(!validateResponseType(context, target.returnType)) {
    reportDiagnostic(context.program, {
      code: 'paginated-response-no-cursor',
      target: target.returnType,
    });
    return;
  }

  setExtension(context.program, target, "x-speakeasy-pagination", {
    type: "cursor",
    inputs: [{
      name: "cursor",
      in: "parameters",
      type: "cursor",
    }],
    outputs:{
      nextCursor: "$.cursor.next",
      results: "$.cursor.data"
    }
  })
}
