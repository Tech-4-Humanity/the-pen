'use client'
import { useState } from 'react'

export default function Home() {
  const [input, setInput] = useState('We are starting Project Atlas on 30 March. Keep it lean. No new hires unless critical.')
  const [data, setData] = useState<any>(null)

  const runScan = async () => {
    const res = await fetch('/api/scan', { method: 'POST', body: JSON.stringify({ input }) })
    const json = await res.json()
    setData(json)
  }

  return (
    <main style={{ padding: 40, fontFamily: 'sans-serif' }}>
      <h1>Say It Once — Live Demo</h1>
      <textarea value={input} onChange={e => setInput(e.target.value)} style={{ width: '100%', height: 120 }} />
      <button onClick={runScan} style={{ marginTop: 10, padding: 10 }}>Run Decision Drift Scan</button>

      {data && (
        <div>
          <h2>Blast Radius</h2>
          <pre>{JSON.stringify(data.blast_radius, null, 2)}</pre>

          <h2>Role Outputs</h2>
          {data.role_outputs.map((r:any, i:number) => (
            <div key={i}><b>{r.role}</b>: {r.interpretation}</div>
          ))}

          <h2>Simulation</h2>
          <div style={{ display: 'flex', gap: 20 }}>
            <ul>{data.simulation.without.map((x:string,i:number)=>(<li key={i}>{x}</li>))}</ul>
            <ul>{data.simulation.with.map((x:string,i:number)=>(<li key={i}>{x}</li>))}</ul>
          </div>
        </div>
      )}
    </main>
  )
}
