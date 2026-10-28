// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

import assert from 'node:assert/strict';
import { mkdtemp, readFile, readdir, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { generateRecipes, sourceFile } from './generate.mjs';
import { formatMaterial3ChipRecipe } from './material3-format.mjs';
import { resolveDictionary } from './token-value-utils.mjs';

const temporary = await mkdtemp(path.join(os.tmpdir(), 'qavsi-material3-recipes-'));
try {
  const source = path.join(temporary, 'material3.json');
  const directory = path.join(temporary, 'recipes');
  const tokens = JSON.parse(await readFile(sourceFile, 'utf8'));
  await writeFile(source, JSON.stringify(tokens));
  await assert.rejects(generateRecipes({ source, directory, check: true }), /Missing generated/);
  assert.equal(await generateRecipes({ source, directory }), 17);
  assert.equal(await generateRecipes({ source, directory, check: true }), 17);
  assert.equal(await readFile(path.join(directory, 'Material3ChipRecipe.js'), 'utf8'),
    formatMaterial3ChipRecipe(resolveDictionary(tokens)));

  const button = path.join(directory, 'Material3ButtonRecipe.js');
  const expected = await readFile(button, 'utf8');
  await writeFile(button, `${expected}// stale fixture\n`);
  await assert.rejects(generateRecipes({ source, directory, check: true }), /missing or stale/);
  assert.match(await readFile(button, 'utf8'), /stale fixture/);
  await generateRecipes({ source, directory });
  assert.equal(await readFile(button, 'utf8'), expected);

  await rm(button);
  await assert.rejects(generateRecipes({ source, directory, check: true }), /missing or stale/);
  await generateRecipes({ source, directory });
  const extra = path.join(directory, 'Unexpected.js');
  await writeFile(extra, '// fixture');
  await assert.rejects(generateRecipes({ source, directory, check: true }), /Unsupported generated/);
  await assert.rejects(generateRecipes({ source, directory }), /Unsupported generated/);
  await rm(extra);

  const originalOutputs = new Map(await Promise.all((await readdir(directory)).map(async (name) =>
    [name, await readFile(path.join(directory, name), 'utf8')])));
  for (const invalidValue of [0, -1, '40', null]) {
    const invalid = structuredClone(tokens);
    invalid.style.material3.button.smallHeight.$value = invalidValue;
    await writeFile(source, JSON.stringify(invalid));
    await assert.rejects(generateRecipes({ source, directory }), /finite positive dimension/);
    for (const [name, contents] of originalOutputs)
      assert.equal(await readFile(path.join(directory, name), 'utf8'), contents);
  }
  const invalidRadio = structuredClone(tokens);
  invalidRadio.style.material3.radioButton.dotDiameter.$value = 24;
  await writeFile(source, JSON.stringify(invalidRadio));
  await assert.rejects(generateRecipes({ source, directory }), /must fit inside/);
  for (const [name, contents] of originalOutputs)
    assert.equal(await readFile(path.join(directory, name), 'utf8'), contents);
  for (const [field, value] of [['radius', 17], ['iconSize', 33]]) {
    const invalidChip = structuredClone(tokens);
    invalidChip.style.material3.chip[field].$value = value;
    assert.throws(() => formatMaterial3ChipRecipe(resolveDictionary(invalidChip)), /must fit/);
    await writeFile(source, JSON.stringify(invalidChip));
    await assert.rejects(generateRecipes({ source, directory }), /must fit/);
    for (const [name, contents] of originalOutputs)
      assert.equal(await readFile(path.join(directory, name), 'utf8'), contents);
  }
  const cycle = structuredClone(tokens);
  cycle.style.material3.button.smallHeight.$value = '{style.material3.button.mediumHeight}';
  cycle.style.material3.button.mediumHeight.$value = '{style.material3.button.smallHeight}';
  await writeFile(source, JSON.stringify(cycle));
  await assert.rejects(generateRecipes({ source, directory }), /Circular token reference/);
  const unresolved = structuredClone(tokens);
  unresolved.style.material3.button.smallHeight.$value = '{style.material3.missing}';
  await writeFile(source, JSON.stringify(unresolved));
  await assert.rejects(generateRecipes({ source, directory }), /Unresolved token reference/);
  console.log('Material3 generation, stale-output, invalid-source and alias checks passed.');
} finally {
  await rm(temporary, { recursive: true, force: true });
}
