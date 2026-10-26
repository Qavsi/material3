// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

export function requiredValue(values, tokenPath) {
  if (!values.has(tokenPath)) {
    throw new Error(`Missing token '${tokenPath}' required by the Material3 recipe format`);
  }

  return values.get(tokenPath);
}

export function tokenKey(token) {
  if (Array.isArray(token.path)) {
    return token.path.join('.');
  }

  if (typeof token.key === 'string') {
    return token.key.replace(/^\{|\}$/g, '');
  }

  throw new Error(`Token has no path metadata: ${JSON.stringify(token)}`);
}

export function resolveValue(token) {
  return token.$value ?? token.value;
}

export function resolveDictionary(tokens) {
  const raw = new Map();
  collectTokens(tokens, [], raw);

  const resolved = new Map();
  const resolving = new Set();
  const resolveToken = (name) => {
    if (resolved.has(name)) {
      return resolved.get(name);
    }
    if (!raw.has(name)) {
      throw new Error(`Unresolved token reference '{${name}}'`);
    }
    if (resolving.has(name)) {
      throw new Error(`Circular token reference '{${name}}'`);
    }

    resolving.add(name);
    const value = resolveReferences(raw.get(name), resolveToken);
    resolving.delete(name);
    resolved.set(name, value);
    return value;
  };

  return {
    allTokens: [...raw.keys()].map((name) => ({
      path: name.split('.'),
      $value: resolveToken(name),
    })),
    tokens,
  };
}

function collectTokens(value, pathSegments, target) {
  if (!isObject(value)) {
    return;
  }
  if (Object.prototype.hasOwnProperty.call(value, '$value')
      || Object.prototype.hasOwnProperty.call(value, 'value')) {
    target.set(pathSegments.join('.'), value.$value ?? value.value);
    return;
  }
  for (const [key, child] of Object.entries(value)) {
    collectTokens(child, [...pathSegments, key], target);
  }
}

function resolveReferences(value, resolveToken) {
  if (typeof value === 'string') {
    const match = value.match(/^\{([^{}]+)\}$/);
    return match ? resolveToken(match[1]) : value;
  }
  if (Array.isArray(value)) {
    return value.map((child) => resolveReferences(child, resolveToken));
  }
  if (isObject(value)) {
    return Object.fromEntries(
      Object.entries(value).map(([key, child]) => [key, resolveReferences(child, resolveToken)]),
    );
  }
  return value;
}

function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}
