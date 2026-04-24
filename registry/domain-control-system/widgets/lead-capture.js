(function(){
  const form = document.createElement('form');
  form.innerHTML = `
    <div style="margin-top:16px;padding:12px;border:1px solid #1e293b;border-radius:12px;">
      <strong>Get full audit</strong><br/>
      <input placeholder="Email" name="email" style="margin-top:8px;padding:6px;width:60%" required />
      <button style="margin-left:8px;padding:6px 10px;">Send</button>
    </div>
  `;

  form.onsubmit = async (e)=>{
    e.preventDefault();
    const email = new FormData(form).get('email');
    await fetch('/api/lead-capture',{
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({email,source:'domain-control-system'})
    });
    alert('Audit link sent');
  };

  document.getElementById('domain-control-system')?.appendChild(form);
})();
