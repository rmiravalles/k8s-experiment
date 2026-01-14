from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI(title="MyApp")

HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>MyApp – Local HTTPS</title>
  <style>
    body {
      font-family: system-ui, sans-serif;
      background: #0f172a;
      color: #e5e7eb;
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
    }
    .card {
      background: #020617;
      padding: 2rem 3rem;
      border-radius: 12px;
      box-shadow: 0 10px 40px rgba(0,0,0,0.5);
      text-align: center;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 MyApp is running</h1>
    <p>Served via <code>FastAPI</code></p>
    <p>🔒 HTTPS via NGINX Ingress</p>
  </div>
</body>
</html>
"""

@app.get("/", response_class=HTMLResponse)
def root():
    return HTML

@app.get("/healthz")
def health():
    return {"status": "ok"}