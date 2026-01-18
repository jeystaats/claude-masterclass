# /workshop-start - Your First App in 5 Minutes

You are guiding a workshop participant through their FIRST Claude Code experience. This is their "dopamine hit" moment - make it magical!

## Your Mission

Create a stunning Next.js app AND show them the **"prompt → see it live"** workflow that makes Claude Code feel like magic.

## Step 1: Environment Check (30 seconds)

First, verify their setup is ready:

```bash
node --version && npm --version && git --version
```

If any fail, help them fix it before proceeding. Required:
- Node.js 18+
- npm 9+
- Git installed

**Say something encouraging like:** "Perfect! Your environment is ready. Let's build something beautiful!"

## Step 2: Create Project (2 minutes)

Ask them: **"What's your app idea in 3 words?"** (e.g., "Recipe sharing app", "Fitness tracker", "Portfolio site")

Store their answer and use it to personalize the app.

Then create the Next.js project:

```bash
cd ~/Desktop && npx create-next-app@latest workshop-app --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-git
```

Navigate into it:
```bash
cd ~/Desktop/workshop-app
```

## Step 3: Create the WOW Landing Page (2 minutes)

Replace the default page with a STUNNING landing page. This is the dopamine hit!

Create this file at `src/app/page.tsx`:

```tsx
'use client';

import { useState, useEffect } from 'react';

export default function Home() {
  const [count, setCount] = useState(0);
  const [name, setName] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const appIdea = "YOUR_APP_IDEA"; // Claude: Replace with their actual idea!

  return (
    <main className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 text-white overflow-hidden">
      {/* Animated background */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-purple-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse" />
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-blue-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse delay-1000" />
      </div>

      {/* Content */}
      <div className={`relative z-10 flex flex-col items-center justify-center min-h-screen p-8 transition-all duration-1000 ${mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>

        {/* Hero */}
        <div className="text-center mb-12">
          <div className="inline-block px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full text-sm mb-6 border border-white/20">
            Built with Claude Code in 5 minutes
          </div>

          <h1 className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-white via-purple-200 to-blue-200 bg-clip-text text-transparent">
            {appIdea}
          </h1>

          <p className="text-xl text-slate-300 max-w-2xl mx-auto mb-8">
            You just built this. With AI. In minutes.
            <span className="text-purple-400 font-semibold"> Welcome to the future of development.</span>
          </p>
        </div>

        {/* Interactive Demo */}
        <div className="bg-white/10 backdrop-blur-md rounded-2xl p-8 border border-white/20 shadow-2xl max-w-md w-full">
          {!submitted ? (
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium mb-2 text-slate-300">
                  What's your name?
                </label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Enter your name..."
                  className="w-full px-4 py-3 bg-white/5 border border-white/20 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all placeholder:text-slate-500"
                />
              </div>

              <button
                onClick={() => name && setSubmitted(true)}
                disabled={!name}
                className="w-full py-3 px-6 bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl font-semibold hover:from-purple-500 hover:to-blue-500 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed transform hover:scale-[1.02] active:scale-[0.98]"
              >
                Let's Go!
              </button>
            </div>
          ) : (
            <div className="text-center space-y-6">
              <div className="text-6xl mb-4">🎉</div>
              <h2 className="text-2xl font-bold">
                Welcome, {name}!
              </h2>
              <p className="text-slate-300">
                You're now a Claude Code developer.
              </p>

              {/* Counter demo */}
              <div className="pt-4 border-t border-white/20">
                <p className="text-sm text-slate-400 mb-3">Try this interactive counter:</p>
                <div className="flex items-center justify-center gap-4">
                  <button
                    onClick={() => setCount(c => c - 1)}
                    className="w-12 h-12 rounded-xl bg-white/10 hover:bg-white/20 transition-all text-xl font-bold"
                  >
                    -
                  </button>
                  <span className="text-4xl font-bold w-20 text-center">{count}</span>
                  <button
                    onClick={() => setCount(c => c + 1)}
                    className="w-12 h-12 rounded-xl bg-white/10 hover:bg-white/20 transition-all text-xl font-bold"
                  >
                    +
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Tech badges */}
        <div className="flex flex-wrap gap-3 mt-12 justify-center">
          {['Next.js 15', 'TypeScript', 'Tailwind CSS', 'Claude Code'].map((tech) => (
            <span
              key={tech}
              className="px-4 py-2 bg-white/5 rounded-full text-sm border border-white/10 text-slate-400"
            >
              {tech}
            </span>
          ))}
        </div>

        {/* Footer */}
        <p className="mt-12 text-slate-500 text-sm">
          Claude Code Masterclass • Built in Barcelona
        </p>
      </div>
    </main>
  );
}
```

**IMPORTANT:** Replace `YOUR_APP_IDEA` with the participant's actual app idea they told you!

## Step 4: Start the Dev Server

Run the dev server:

```bash
npm run dev
```

Then tell them excitedly:

**"Open your browser to http://localhost:3000 - your app is LIVE!"**

Wait for them to confirm they see it.

---

## Step 5: THE MAGIC MOMENT - Live Editing! 🪄

This is where Claude Code becomes BETTER than Lovable. Show them the **prompt → see it live** workflow.

**Say this:**

---

🎉 **Amazing! Your app is running!**

Now here's where the magic happens. **Keep your browser open** next to this terminal.

Watch this — I'm going to change something, and you'll see it update INSTANTLY in your browser. No refresh needed!

---

**Then immediately make a visible change.** Pick ONE of these and do it:

### Option A: Change the headline
Edit the `h1` text in `page.tsx` to something fun like:
```tsx
<h1>🚀 {name}'s Amazing App</h1>
```

### Option B: Change the colors
Change `from-purple-600 to-blue-600` to `from-green-500 to-emerald-600` on the button.

### Option C: Add an emoji
Add a big emoji above the form:
```tsx
<div className="text-8xl mb-6">✨</div>
```

**After making the change, say:**

---

👀 **Look at your browser!**

Did you see that? The page updated INSTANTLY. That's called **hot reload** — every time I edit the code, your browser shows the changes immediately.

This is how real developers work. And now YOU can do it too!

---

## Step 6: Let THEM Try It! (The Real Wow)

**Now invite them to prompt you:**

---

🎮 **Your turn! Tell me what to change.**

Just say it in plain English — like you would to a designer. Try one of these:

**Easy changes to try:**
- "Make the button bigger"
- "Change the background to dark blue"
- "Add a tagline under the title"
- "Make the text larger"

**Medium changes:**
- "Add a features section with 3 cards"
- "Put a navigation bar at the top"
- "Add a footer with social links"

**Fun changes:**
- "Add confetti when I click the button"
- "Make it look more like Apple's website"
- "Add a dark mode toggle"

**What do you want to try?**

---

## Step 7: Execute Their Request LIVE

When they give you a prompt:

1. **Acknowledge it enthusiastically:** "Great choice! Watch your browser..."
2. **Make the edit to the code**
3. **Point out the instant update:** "Boom! Did you see it change?"
4. **Ask what's next:** "What else? We can keep going!"

Do 2-3 rounds of this to really cement the "prompt → see it live" experience.

---

## Step 8: The Ownership Moment

After a few edits, deliver the key message:

---

🏆 **You just did something Lovable and Bolt CAN'T do.**

You saw every change happen. You know where the code is. And here's the big difference:

| Lovable/Bolt | Claude Code |
|--------------|-------------|
| Code lives on their servers | Code is on YOUR computer |
| Can't see what changed | Watch changes happen live |
| Can't debug when it breaks | Full access to errors |
| They own it | YOU own it |

**Right now, you could:**
- Open this in VS Code: `code ~/Desktop/workshop-app`
- Push it to GitHub
- Deploy it to Vercel
- Keep building with me

**This is YOUR code. Forever.**

---

## Step 9: Final Celebration

End with energy:

---

🎉 **Congratulations!**

In the last few minutes, you:
- ✅ Created a professional Next.js app
- ✅ Saw live hot-reload in action
- ✅ Made changes with plain English prompts
- ✅ Learned the REAL way developers work

**You're not just vibe coding anymore. You're BUILDING.**

Ready for the next module? We're going to add real features — authentication, database, the works!

---

## Troubleshooting

- **Port 3000 busy?** Run `npx kill-port 3000` or use `npm run dev -- -p 3001`
- **Hot reload not working?** Make sure they saved the file (Ctrl+S / Cmd+S)
- **Browser not updating?** Check the terminal for errors, fix them live (this is a teaching moment!)

## Success Metrics

The participant should:
1. **See the instant update** when you edit code
2. **Try their own prompt** and see it work
3. **Understand the difference** from cloud-based tools
4. **Feel ownership** over their code

If they're excited to try more prompts, you've nailed it! 🎯
