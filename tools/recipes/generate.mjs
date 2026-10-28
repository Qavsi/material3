// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as format from './material3-format.mjs';
import { resolveDictionary } from './token-value-utils.mjs';

export const sourceFile = fileURLToPath(new URL('../../tokens/material3.json', import.meta.url));
export const outputDirectory = fileURLToPath(new URL(
  '../../src/Qavsi/Material3/Style/internal/recipes/', import.meta.url));

const families = ['Progress', 'Slider', 'Tab', 'Switch', 'CheckBox', 'RadioButton', 'Chip', 'Navigation', 'Fab', 'Joined',
  'Button', 'IconButton', 'Badge', 'SegmentedButton', 'SplitButton', 'ConnectedButton'];

export function recipeOutputs(tokens) {
  const dictionary = resolveDictionary(tokens);
  return new Map(families.map((family) => [
    `Material3${family}Recipe.js`, format[`formatMaterial3${family}Recipe`](dictionary),
  ]));
}

export async function generateRecipes({ source = sourceFile, directory = outputDirectory,
  check = false } = {}) {
  // Resolve and validate every family before writing any output.
  const outputs = recipeOutputs(JSON.parse(await readFile(source, 'utf8')));
  let entries;
  try {
    entries = await readdir(directory);
  } catch (error) {
    if (error.code !== 'ENOENT')
      throw error;
    if (check)
      throw new Error(`Missing generated Material3 recipe directory: ${directory}`);
    entries = [];
  }
  const unexpected = entries.filter((name) => !outputs.has(name));
  if (unexpected.length > 0)
    throw new Error(`Unsupported generated Material3 outputs: ${unexpected.join(', ')}`);
  if (!check)
    await mkdir(directory, { recursive: true });
  for (const [name, contents] of outputs) {
    const destination = path.join(directory, name);
    if (check) {
      let actual;
      try {
        actual = await readFile(destination, 'utf8');
      } catch (error) {
        if (error.code !== 'ENOENT')
          throw error;
      }
      if (actual !== contents)
        throw new Error(`${destination}: generated Material3 recipe is missing or stale; run node tools/recipes/generate.mjs`);
    } else {
      await writeFile(destination, contents);
    }
  }
  return outputs.size;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    const args = process.argv.slice(2);
    if (args.length === 1 && args[0] === '--help') {
      console.log('Usage: node tools/recipes/generate.mjs [--check]');
    } else {
      if (args.some((argument) => argument !== '--check') || args.length > 1)
        throw new Error('Usage: node tools/recipes/generate.mjs [--check]');
      const check = args[0] === '--check';
      const count = await generateRecipes({ check });
      console.log(`${check ? 'Checked' : 'Generated'} ${count} Material3 recipes.`);
    }
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
