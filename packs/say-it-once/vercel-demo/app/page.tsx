export default function Home() {
  return (
    <main style={{padding:40,fontFamily:'sans-serif'}}>
      <h1>Say It Once — Live Demo</h1>
      <p>Enter a decision and watch your business respond.</p>

      <textarea style={{width:'100%',height:120}} defaultValue={"We are starting Project Atlas on 30 March. Keep it lean. No new hires unless critical."} />

      <h2>Blast Radius</h2>
      <ul>
        <li>Functions impacted: 7</li>
        <li>Roles impacted: 63</li>
        <li>Systems touched: 14</li>
        <li>Miss rate: 41%</li>
        <li>Drift Risk: HIGH</li>
      </ul>

      <h2>What They Heard</h2>
      <div style={{display:'flex',gap:20}}>
        <div><b>HR</b><p>No hiring, redeploy staff</p></div>
        <div><b>Finance</b><p>Budget cap required</p></div>
        <div><b>IT</b><p>Create Kanban board</p></div>
      </div>

      <h2>Outputs</h2>
      <ul>
        <li>Excel Budget Created</li>
        <li>Kanban Board Created</li>
        <li>Email Draft Generated</li>
      </ul>

      <button style={{marginTop:20,padding:10}}>Run Decision Drift Scan</button>
    </main>
  )
}