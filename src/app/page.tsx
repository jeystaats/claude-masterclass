export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-8 p-16">
      <div className="flex flex-col items-center gap-4 text-center">
        <p className="text-sm font-medium uppercase tracking-widest text-zinc-400">
          Claude Code Mastery
        </p>
        <h1 className="text-4xl font-semibold tracking-tight text-zinc-900">
          Your starter kit is ready.
        </h1>
        <p className="max-w-md text-lg text-zinc-500">
          Tell Claude what you want to build, or run{" "}
          <code className="rounded bg-zinc-100 px-1.5 py-0.5 text-sm font-mono text-zinc-700">
            bash start.sh
          </code>{" "}
          to pick a module exercise.
        </p>
      </div>

      <div className="flex flex-col items-center gap-2 text-sm text-zinc-400">
        <p>
          <span className="font-medium text-zinc-600">pnpm dev</span> — dev server on port 3000
        </p>
        <p>
          <span className="font-medium text-zinc-600">pnpm typecheck</span> — TypeScript check
        </p>
        <p>
          <span className="font-medium text-zinc-600">pnpm build</span> — production build
        </p>
      </div>
    </main>
  )
}
