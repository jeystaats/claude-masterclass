---
name: breakdown
description: >
  Explain code using a layered approach: analogy → diagram → line-by-line trace.
  Auto-invokes when the user says "how does this work", "explain this", "what
  does this do", or asks for a walkthrough of unfamiliar code.
---

<!-- WHY THIS SKILL EXISTS: Beginners learn faster when explanations layer from
familiar (analogy) to visual (diagram) to precise (code trace). This pattern
prevents the "wall of text" problem and builds genuine understanding. -->

# /lah-explain-code -- Explain code so it actually clicks

## Workflow

1. **Analogy first** -- Start with a one-sentence real-world analogy for what the code does. ("This function works like a bouncer at a club -- it checks every person in the queue and only lets in the ones on the list.")

2. **ASCII diagram** -- Draw a simple diagram showing the data flow or structure. Keep it under 10 lines. Label inputs, outputs, and transformations.

3. **Step-by-step trace** -- Walk through the code line by line (or block by block for longer code). Use a concrete example with real values so the reader can follow the state changing.

4. **One gotcha** -- End with the single most surprising or error-prone thing about this code. What trips people up?

## Example output

```
## Analogy
This `filter().map()` chain works like a factory assembly line -- first a
quality inspector removes defective items, then a painter recolors the rest.

## How it flows
  items[] --> filter(isValid) --> map(transform) --> result[]
  [a,b,c]    removes b          changes shape     [A', C']

## Trace with real values
Given items = [{id:1, active:true}, {id:2, active:false}, {id:3, active:true}]

1. filter(isValid) checks each item's .active property
   -> keeps {id:1} and {id:3}, drops {id:2}
2. map(transform) extracts just the id
   -> produces [1, 3]

## Gotcha
filter() runs BEFORE map() -- if you swap them, you'd be filtering on the
transformed shape, not the original. Order matters in chains.
```

## Tips

- If the code is longer than 30 lines, explain it in logical blocks rather than line-by-line.
- Ask the user what part confuses them most -- you might not need to explain everything.
- Match your analogy to something the user likely knows (cooking, mail delivery, assembly lines).
