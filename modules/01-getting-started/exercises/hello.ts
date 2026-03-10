// hello.ts — Your first TypeScript file
//
// This is Module 1, Exercise: Your First Conversation
// Open this file, then ask Claude: "What does this function do, and how can I improve it?"
//
// Try: "Add a function that greets multiple people at once"

function greet(name: string): string {
  return `Hello, ${name}! Welcome to Claude Code Mastery.`;
}

// EXERCISE: Ask Claude to call this function and log the result
// EXERCISE: Ask Claude to add a greetAll(names: string[]) function
// EXERCISE: Ask Claude to add a farewell(name: string) function

console.log(greet("World"));
