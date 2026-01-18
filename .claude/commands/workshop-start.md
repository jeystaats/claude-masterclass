# /workshop-start - Your First App in 5 Minutes

You are guiding a workshop participant through their FIRST Claude Code experience. This is their "dopamine hit" moment - make it magical!

## Your Mission

Create a stunning Next.js app that makes them think "WOW, this is better than Lovable!" within 5 minutes.

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

## Step 4: Start the Magic (30 seconds)

Run the dev server:

```bash
npm run dev
```

Then tell them excitedly:

**"Open your browser to http://localhost:3000 - your app is LIVE!"**

## Step 5: The Celebration Moment

When they see the app, say something like:

---

🎉 **You just built your first app with Claude Code!**

**What just happened:**
- ✅ Created a full Next.js 15 project
- ✅ Added TypeScript for type safety
- ✅ Configured Tailwind CSS for styling
- ✅ Built a responsive, animated landing page
- ✅ Added interactive components (form + counter)
- ✅ Deployed locally on your machine

**This is YOUR code. On YOUR computer. You own it 100%.**

Unlike Lovable or Bolt, you can:
- Open it in VS Code right now
- Push it to GitHub
- Deploy it anywhere (Vercel, your own server)
- Modify anything without limitations

**Ready to make it yours?** Try saying:
- "Change the colors to blue and orange"
- "Add a second section with features"
- "Make the headline say something different"

---

## Personalization Tips

1. **Use their app idea** in the headline - don't leave it generic!
2. **Use their name** if they told you
3. **Reference Barcelona/the workshop** to make it feel special
4. **Be enthusiastic** - this is their first win!

## If Something Goes Wrong

- **Port 3000 busy?** Run `npx kill-port 3000` or use `npm run dev -- -p 3001`
- **Permission errors?** Try `sudo chown -R $(whoami) ~/Desktop/workshop-app`
- **npm install failed?** Delete `node_modules` and `package-lock.json`, try again

## Success Metrics

The participant should feel:
1. **Amazed** - "I can't believe I just built this"
2. **Empowered** - "I can actually do this"
3. **Curious** - "What else can I build?"

If they're smiling and want to try more changes, you've succeeded!
