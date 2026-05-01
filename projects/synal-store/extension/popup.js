document.getElementById('snap').addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({active:true,currentWindow:true});
  const intent = document.getElementById('intent').value || '';
  const payload = {
    url: tab.url,
    title: tab.title,
    intent
  };
  document.getElementById('status').textContent = JSON.stringify(payload, null, 2);
  // TODO: POST to Supabase endpoint
});
