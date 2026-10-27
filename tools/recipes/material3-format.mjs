// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

import { requiredValue, resolveValue, tokenKey } from './token-value-utils.mjs';

const SLIDER_FIELDS = [
  'trackThickness',
  'handleExtent',
  'handleLength',
  'handleWidth',
  'activeHandleWidth',
  'trackGap',
  'trackInnerRadius',
  'focusExpansion',
  'focusWidth',
  'valueMinimum',
  'valueGap',
  'stopDiameter',
  'maxVisibleStops',
];

const RADIO_FIELDS = ['indicatorDiameter', 'outlineWidth', 'dotDiameter', 'stateLayerDiameter', 'focusWidth'];

const TAB_FIELDS = ['indicatorThickness', 'minimumIndicatorWidth'];
const SWITCH_FIELDS = ['trackWidth', 'trackHeight', 'thumbUncheckedDiameter',
  'thumbCheckedDiameter', 'thumbPressedDiameter', 'edgeInset'];

const NAVIGATION_FIELDS = ['collapsedWidth', 'indicatorWidth', 'indicatorHeight', 'expandedHeight', 'scrimOpacity', 'collapsedLabelFadeEnd', 'expandedLabelFadeStart', 'fabHeight'];

const FAB_FIELDS = ['smallHeight', 'height', 'largeHeight', 'minimumExpandedWidth', 'iconSize', 'largeIconSize', 'trailingInset', 'leadingInset', 'spacing'];

const BUTTON_SIZES = ['extraSmall', 'small', 'medium', 'large', 'extraLarge'];
const BUTTON_FIELDS = [...BUTTON_SIZES.flatMap(name => [`${name}Height`, `${name}IconSize`]), 'minimumWidth'];

const SPLIT_METRICS = ["containerHeight", "leadingIconSize", "leadingPadding", "trailingPadding", "trailingIconSize", "trailingIconPadding", "idleRadius", "hoverRadius", "pressedRadius", "opticalOffset"];
const SPLIT_FIELDS = BUTTON_SIZES.flatMap(size => SPLIT_METRICS.map(field => `${size}.${field}`));

const SEGMENTED_FIELDS = BUTTON_SIZES.flatMap(size => ['containerHeight', 'iconSize'].map(field => `${size}.${field}`));

const BADGE_FIELDS = ['dotDiameter', 'labelHeight', 'labelMinimumWidth', 'labelHorizontalPadding', 'offsetX', 'offsetY'];

const ICON_BUTTON_METRICS = ['containerHeight', 'defaultWidth', 'narrowWidth', 'wideWidth', 'iconSize'];
const ICON_BUTTON_FIELDS = BUTTON_SIZES.flatMap(size => ICON_BUTTON_METRICS.map(field => `${size}.${field}`));

function recipeTokens(dictionary) {
  const values = new Map(dictionary.allTokens.map((token) => [tokenKey(token), resolveValue(token)]));
  const expected = new Set([
    ...SLIDER_FIELDS.map((name) => `style.material3.slider.${name}`),
    ...TAB_FIELDS.map((name) => `style.material3.tabs.${name}`),
    ...RADIO_FIELDS.map((name) => `style.material3.radioButton.${name}`),
    ...SWITCH_FIELDS.map((name) => `style.material3.switch.${name}`),
    ...NAVIGATION_FIELDS.map((name) => `style.material3.navigation.${name}`),
    ...FAB_FIELDS.map((name) => `style.material3.fab.${name}`),
    ...BUTTON_FIELDS.map((name) => `style.material3.button.${name}`),
    ...ICON_BUTTON_FIELDS.map((name) => `style.material3.iconButton.${name}`),
    ...SPLIT_FIELDS.map(name => `style.material3.splitButton.${name}`),
    ...SEGMENTED_FIELDS.map(name => `style.material3.segmentedButton.${name}`),
    ...BADGE_FIELDS.map((name) => `style.material3.badge.${name}`),
    "style.material3.joined.spacing",
    "style.material3.joined.opticalBias",
  ]);
  const unexpected = [...values.keys()].filter((name) => !expected.has(name));
  if (unexpected.length > 0)
    throw new Error(`Unsupported Material3 recipe tokens: ${unexpected.join(', ')}`);
  return values;
}

export function formatMaterial3SliderRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(SLIDER_FIELDS.map((name) => {
    const tokenPath = `style.material3.slider.${name}`;
    const value = requiredValue(values, tokenPath);
    const token = dictionary.tokens.style?.material3?.slider?.[name];
    const type = name === 'maxVisibleStops' ? 'number' : 'dimension';
    if (token?.$type !== type) {
      throw new Error(`${tokenPath} must declare $type '${type}'`);
    }
    if (name === 'maxVisibleStops') {
      if (!Number.isSafeInteger(value) || value < 2)
        throw new Error(`${tokenPath} must be a safe integer at least 2`);
    } else if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0) {
      throw new Error(`${tokenPath} must be a finite positive dimension`);
    }
    return [name, value];
  }));
  if (recipe.activeHandleWidth > recipe.handleWidth
      || recipe.handleWidth > recipe.handleExtent) {
    throw new Error('Material3 slider activeHandleWidth must not exceed handleWidth, and handleWidth must not exceed handleExtent');
  }
  if (recipe.trackThickness >= recipe.handleLength) {
    throw new Error('Material3 slider trackThickness must be less than handleLength');
  }
  if (recipe.trackInnerRadius > recipe.trackThickness / 2) {
    throw new Error('Material3 slider trackInnerRadius must not exceed half of trackThickness');
  }
  if (recipe.stopDiameter > recipe.trackThickness) {
    throw new Error('Material3 slider stopDiameter must not exceed trackThickness');
  }
  const constants = SLIDER_FIELDS.map((name) => `const ${name} = ${recipe[name]};`);
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${constants.join('\n')}
`;
}

export function formatMaterial3RadioButtonRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(RADIO_FIELDS.map((name) => {
    const tokenPath = `style.material3.radioButton.${name}`;
    const value = requiredValue(values, tokenPath);
    if (dictionary.tokens.style?.material3?.radioButton?.[name]?.$type !== 'dimension')
      throw new Error(`${tokenPath} must declare $type 'dimension'`);
    if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0)
      throw new Error(`${tokenPath} must be a finite positive dimension`);
    return [name, value];
  }));
  if (recipe.dotDiameter + 2 * recipe.outlineWidth > recipe.indicatorDiameter)
    throw new Error('Material3 radio dot and outline must fit inside indicatorDiameter');
  if (recipe.stateLayerDiameter < recipe.indicatorDiameter + 4 * recipe.focusWidth)
    throw new Error('Material3 radio focus circle must fit inside stateLayerDiameter');
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${RADIO_FIELDS.map((name) => `const ${name} = ${recipe[name]};`).join('\n')}
`;
}

export function formatMaterial3TabRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(TAB_FIELDS.map((name) => {
    const tokenPath = `style.material3.tabs.${name}`;
    const value = requiredValue(values, tokenPath);
    if (dictionary.tokens.style?.material3?.tabs?.[name]?.$type !== 'dimension')
      throw new Error(`${tokenPath} must declare $type 'dimension'`);
    if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0)
      throw new Error(`${tokenPath} must be a finite positive dimension`);
    return [name, value];
  }));
  if (recipe.indicatorThickness > recipe.minimumIndicatorWidth / 2)
    throw new Error('Material3 tabs indicatorThickness must not exceed half of minimumIndicatorWidth');
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${TAB_FIELDS.map((name) => `const ${name} = ${recipe[name]};`).join('\n')}
`;
}

export function formatMaterial3SwitchRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(SWITCH_FIELDS.map((name) => {
    const tokenPath = `style.material3.switch.${name}`;
    const value = requiredValue(values, tokenPath);
    if (dictionary.tokens.style?.material3?.switch?.[name]?.$type !== 'dimension')
      throw new Error(`${tokenPath} must declare $type 'dimension'`);
    if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0)
      throw new Error(`${tokenPath} must be a finite positive dimension`);
    return [name, value];
  }));
  if (recipe.trackWidth < recipe.trackHeight)
    throw new Error('Material3 switch trackWidth must not be less than trackHeight');
  if (recipe.thumbUncheckedDiameter > recipe.thumbCheckedDiameter
      || recipe.thumbCheckedDiameter > recipe.thumbPressedDiameter)
    throw new Error('Material3 switch thumb diameters must be ordered unchecked <= checked <= pressed');
  if (recipe.thumbPressedDiameter + 2 * recipe.edgeInset > recipe.trackHeight)
    throw new Error('Material3 switch pressed thumb and edge insets must fit the track height');
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${SWITCH_FIELDS.map((name) => `const ${name} = ${recipe[name]};`).join('\n')}
`;
}

export function formatMaterial3NavigationRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(NAVIGATION_FIELDS.map((name) => {
    const tokenPath = `style.material3.navigation.${name}`;
    const value = requiredValue(values, tokenPath);
    const opacity = ['scrimOpacity', 'collapsedLabelFadeEnd', 'expandedLabelFadeStart'].includes(name);
    const type = opacity ? 'number' : 'dimension';
    if (dictionary.tokens.style?.material3?.navigation?.[name]?.$type !== type)
      throw new Error(`${tokenPath} must declare $type '${type}'`);
    if (typeof value !== 'number' || !Number.isFinite(value)
        || (opacity ? value < 0 || value > 1 : value <= 0))
      throw new Error(`${tokenPath} must be ${opacity ? 'an opacity from 0 to 1' : 'a finite positive dimension'}`);
    return [name, value];
  }));
  if (recipe.collapsedLabelFadeEnd <= 0 || recipe.expandedLabelFadeStart >= 1)
    throw new Error('Navigation label fade phases must have non-zero spans');
  if (recipe.indicatorHeight > recipe.indicatorWidth || recipe.indicatorWidth > recipe.collapsedWidth)
    throw new Error('Material3 navigation requires indicatorHeight <= indicatorWidth <= collapsedWidth');
  if (recipe.fabHeight > recipe.collapsedWidth)
    throw new Error('Material3 navigation fabHeight must fit collapsedWidth');
  if (recipe.expandedHeight < recipe.indicatorHeight)
    throw new Error('Material3 navigation expandedHeight must not be less than indicatorHeight');
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${NAVIGATION_FIELDS.map((name) => `const ${name} = ${recipe[name]};`).join('\n')}
`;
}

export function formatMaterial3FabRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(FAB_FIELDS.map((name) => {
    const tokenPath = `style.material3.fab.${name}`;
    const value = requiredValue(values, tokenPath);
    if (dictionary.tokens.style?.material3?.fab?.[name]?.$type !== 'dimension')
      throw new Error(`${tokenPath} must declare $type 'dimension'`);
    if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0)
      throw new Error(`${tokenPath} must be a finite positive dimension`);
    return [name, value];
  }));
  if (recipe.smallHeight > recipe.height || recipe.height > recipe.largeHeight)
    throw new Error('Material3 FAB heights must be ordered small <= normal <= large');
  if (recipe.minimumExpandedWidth < recipe.height || recipe.iconSize > recipe.smallHeight
      || recipe.largeIconSize > recipe.largeHeight || recipe.trailingInset * 2 > recipe.minimumExpandedWidth
      || recipe.leadingInset + recipe.iconSize + recipe.spacing + recipe.trailingInset > recipe.minimumExpandedWidth)
    throw new Error('Material3 FAB icon/insets must fit their minimum container');
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${FAB_FIELDS.map((name) => `const ${name} = ${recipe[name]};`).join('\n')}
`;
}

export function formatMaterial3JoinedRecipe(dictionary) {
  const values=recipeTokens(dictionary);
  const tokenPath='style.material3.joined.spacing';
  const spacing=requiredValue(values,tokenPath);
  if (dictionary.tokens.style?.material3?.joined?.spacing?.$type!=='dimension')
    throw new Error(`${tokenPath} must declare $type 'dimension'`);
  if (typeof spacing!=='number' || !Number.isFinite(spacing) || spacing<=0)
    throw new Error(`${tokenPath} must be a finite positive dimension`);
  const biasPath='style.material3.joined.opticalBias';
  const opticalBias=requiredValue(values,biasPath);
  if (dictionary.tokens.style?.material3?.joined?.opticalBias?.$type!=='number')
    throw new Error(`${biasPath} must declare $type 'number'`);
  if (typeof opticalBias!=='number' || !Number.isFinite(opticalBias) || opticalBias<=0 || opticalBias>=0.5)
    throw new Error(`${biasPath} must be finite and between 0 and 0.5`);
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

const spacing = ${spacing};
const opticalBias = ${opticalBias};
`;
}

export function formatMaterial3ButtonRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(BUTTON_FIELDS.map((name) => {
    const tokenPath = `style.material3.button.${name}`;
    const value = requiredValue(values, tokenPath);
    if (dictionary.tokens.style?.material3?.button?.[name]?.$type !== 'dimension')
      throw new Error(`${tokenPath} must declare $type 'dimension'`);
    if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0)
      throw new Error(`${tokenPath} must be a finite positive dimension`);
    return [name, value];
  }));
  if (BUTTON_SIZES.some((name, index) => index > 0 && recipe[`${name}Height`] <= recipe[`${BUTTON_SIZES[index - 1]}Height`]))
    throw new Error('Material3 button heights must be strictly increasing XS < S < M < L < XL');
  if (BUTTON_SIZES.some(name => recipe[`${name}IconSize`] > recipe[`${name}Height`]))
    throw new Error('Material3 button icon must fit its paint height');
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${BUTTON_FIELDS.map((name) => `const ${name} = ${recipe[name]};`).join('\n')}
`;
}

export function formatMaterial3IconButtonRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(BUTTON_SIZES.map(size => {
    const fields = Object.fromEntries(ICON_BUTTON_METRICS.map(field => {
      const tokenPath = `style.material3.iconButton.${size}.${field}`;
      const value = requiredValue(values, tokenPath);
      if (dictionary.tokens.style?.material3?.iconButton?.[size]?.[field]?.$type !== 'dimension')
        throw new Error(`${tokenPath} must declare $type 'dimension'`);
      const automatic = size === 'extraSmall' && field !== 'iconSize';
      if (typeof value !== 'number' || !Number.isFinite(value) || value < 0 || (!automatic && value === 0))
        throw new Error(`${tokenPath} must be a finite ${automatic ? 'nonnegative' : 'positive'} dimension`);
      return [field, value];
    }));
    if (size === 'extraSmall') {
      if (ICON_BUTTON_METRICS.some(field => field !== 'iconSize' && fields[field] !== 0))
        throw new Error('Material3 extra-small icon geometry must remain automatic');
    } else if (fields.iconSize > fields.containerHeight || fields.iconSize > fields.narrowWidth) {
      throw new Error('Material3 icon button glyph must fit every container');
    }
    if (fields.narrowWidth > fields.defaultWidth || fields.defaultWidth > fields.wideWidth)
      throw new Error('Material3 icon button widths must be ordered narrow/default/wide');
    return [size, fields];
  }));
  for (let index = 1; index < BUTTON_SIZES.length; ++index) {
    const previous = recipe[BUTTON_SIZES[index - 1]];
    const current = recipe[BUTTON_SIZES[index]];
    if (current.containerHeight <= previous.containerHeight || current.iconSize < previous.iconSize)
      throw new Error('Material3 icon button sizes must increase without shrinking glyphs');
  }
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${BUTTON_SIZES.map(size => `const ${size} = ${JSON.stringify(recipe[size])};`).join('\n')}
`;
}

export function formatMaterial3BadgeRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(BADGE_FIELDS.map(field => {
    const tokenPath = `style.material3.badge.${field}`;
    const value = requiredValue(values, tokenPath);
    if (dictionary.tokens.style?.material3?.badge?.[field]?.$type !== 'dimension')
      throw new Error(`${tokenPath} must declare $type 'dimension'`);
    const signed = field === 'offsetX' || field === 'offsetY';
    const zero = field === 'labelHorizontalPadding';
    if (typeof value !== 'number' || !Number.isFinite(value) || (!signed && (value < 0 || (!zero && value === 0))))
      throw new Error(`${tokenPath} must be a finite ${signed ? 'signed' : zero ? 'nonnegative' : 'positive'} dimension`);
    return [field, value];
  }));
  if (recipe.dotDiameter >= recipe.labelHeight)
    throw new Error('Material3 notification dot must be smaller than the label');
  if (recipe.labelMinimumWidth < recipe.labelHeight || recipe.labelMinimumWidth < recipe.labelHorizontalPadding * 2)
    throw new Error('Material3 notification label minimum must fit its height and padding');
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${BADGE_FIELDS.map(field => `const ${field} = ${recipe[field]};`).join('\n')}
`;
}

export function formatMaterial3SegmentedButtonRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(BUTTON_SIZES.map(size => {
    const fields = Object.fromEntries(['containerHeight', 'iconSize'].map(field => {
      const tokenPath = `style.material3.segmentedButton.${size}.${field}`;
      const value = requiredValue(values, tokenPath);
      if (dictionary.tokens.style?.material3?.segmentedButton?.[size]?.[field]?.$type !== 'dimension')
        throw new Error(`${tokenPath} must declare $type 'dimension'`);
      if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0)
        throw new Error(`${tokenPath} must be a finite positive dimension`);
      return [field, value];
    }));
    if (fields.iconSize > fields.containerHeight)
      throw new Error('Material3 segmented glyph must fit its container');
    return [size, fields];
  }));
  for (let index = 1; index < BUTTON_SIZES.length; ++index) {
    const previous = recipe[BUTTON_SIZES[index - 1]];
    const current = recipe[BUTTON_SIZES[index]];
    if (current.containerHeight <= previous.containerHeight || current.iconSize < previous.iconSize)
      throw new Error('Material3 segmented sizes must increase without shrinking glyphs');
  }
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${BUTTON_SIZES.map(size => `const ${size} = ${JSON.stringify(recipe[size])};`).join('\n')}
`;
}

export function formatMaterial3SplitButtonRecipe(dictionary) {
  const values = recipeTokens(dictionary);
  const recipe = Object.fromEntries(BUTTON_SIZES.map(size => {
    const fields = Object.fromEntries(SPLIT_METRICS.map(field => {
      const tokenPath = `style.material3.splitButton.${size}.${field}`;
      const value = requiredValue(values, tokenPath);
      if (dictionary.tokens.style?.material3?.splitButton?.[size]?.[field]?.$type !== 'dimension')
        throw new Error(`${tokenPath} must declare $type 'dimension'`);
      if (typeof value !== 'number' || !Number.isFinite(value) || value <= 0)
        throw new Error(`${tokenPath} must be a finite positive dimension`);
      return [field,value];
    }));
    if (Math.max(fields.leadingIconSize,fields.trailingIconSize) > fields.containerHeight
        || Math.max(fields.idleRadius,fields.hoverRadius,fields.pressedRadius) > fields.containerHeight / 2
        || fields.idleRadius > Math.min(fields.hoverRadius,fields.pressedRadius)
        || fields.opticalOffset * 2 >= fields.trailingIconSize)
      throw new Error('Material3 split glyph, radii and optical offset must fit their container');
    return [size,fields];
  }));
  for (let index=1; index<BUTTON_SIZES.length; ++index) {
    const previous=recipe[BUTTON_SIZES[index-1]], current=recipe[BUTTON_SIZES[index]];
    if (current.containerHeight<=previous.containerHeight || current.trailingIconSize<previous.trailingIconSize)
      throw new Error('Material3 split sizes must increase without shrinking glyphs');
  }
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${BUTTON_SIZES.map(size => `const ${size} = ${JSON.stringify(recipe[size])};`).join('\n')}
`;
}

export function formatMaterial3ConnectedButtonRecipe(dictionary) {
  formatMaterial3ButtonRecipe(dictionary);
  formatMaterial3IconButtonRecipe(dictionary);
  const values=recipeTokens(dictionary);
  const recipe=Object.fromEntries(BUTTON_SIZES.map(size=>[size,{
    buttonHeight:requiredValue(values,`style.material3.button.${size}Height`),
    buttonIconSize:requiredValue(values,`style.material3.button.${size}IconSize`),
    buttonMinimumWidth:requiredValue(values,'style.material3.button.minimumWidth'),
    iconHeight:requiredValue(values,`style.material3.iconButton.${size}.containerHeight`),
    iconWidth:requiredValue(values,`style.material3.iconButton.${size}.defaultWidth`),
    iconSize:requiredValue(values,`style.material3.iconButton.${size}.iconSize`),
  }]));
  return `// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Generated by tools/recipes/generate.mjs from tokens/material3.json; do not edit.
.pragma library

${BUTTON_SIZES.map(size=>`const ${size} = ${JSON.stringify(recipe[size])};`).join('\n')}
`;
}
