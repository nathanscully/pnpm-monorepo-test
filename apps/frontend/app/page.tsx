import add from 'adder';
export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center p-24">
      <h1 className="text-xl">PNPM Monorepo Example</h1>
      <p>Adding 1+2 via the shared adder package: <span className="font-mono">{add(1,2)}</span></p>
    </main>
  )
}
