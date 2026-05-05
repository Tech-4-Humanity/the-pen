const express = require("express");
const fs = require("fs");
const path = require("path");

const app = express();
app.use(express.json());

const CONTRACT_DIR = path.join(__dirname, "contracts");
if (!fs.existsSync(CONTRACT_DIR)) {
  fs.mkdirSync(CONTRACT_DIR);
}

app.post("/deploy", (req, res) => {
  const contract = req.body;

  const id = Date.now();
  const filePath = path.join(CONTRACT_DIR, `contract_${id}.json`);

  fs.writeFileSync(filePath, JSON.stringify(contract, null, 2));

  console.log("DEPLOY RECEIPT:");
  console.log(filePath);

  res.json({
    status: "PARTIAL",
    result: "Contract stored",
    evidence: filePath,
    next_action: "Connect Supabase + execution engine"
  });
});

app.listen(3000, () => {
  console.log("T4H Companion backend running on http://localhost:3000");
});
