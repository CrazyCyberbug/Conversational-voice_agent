import threading
import time
import requests
import uvicorn
from pyngrok import ngrok, exception as ngrok_exc
from server import app

HOST = "127.0.0.1"
PORT = 8000
HEALTH_URL = f"http://{HOST}:{PORT}/health"
NGROK_RETRY_DELAY = 30
ngrok.set_auth_token("2seBLOO68ga5M96NsZLeSgwUqxv_bFdshxegEjgwi88a9b2K")

def start_uvicorn():
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=PORT,
        log_level="info",
        reload=False,          # 🔴 NEVER enable in Colab
        access_log=False
    )


def wait_for_health(timeout=600):
    start = time.time()
    time.sleep(45)
    while time.time() - start < timeout:
        try:
            r = requests.get(HEALTH_URL, timeout=1)
            if r.status_code == 200:
                print("✅ Health check passed")
                return True
        except Exception:
            pass
        time.sleep(30)
    return False


def start_ngrok_with_retry(port):
    while True:
        try:
            tunnel = ngrok.connect(port, "http", bind_tls=True)
            print(f"\n🌍 Ngrok public URL: {tunnel.public_url}\n", flush=True)
            return tunnel
        except ngrok_exc.PyngrokError as e:
            print(f"⚠️ Ngrok failed: {e}")
            print(f"⏳ Retrying in {NGROK_RETRY_DELAY}s...")
            time.sleep(NGROK_RETRY_DELAY)


if __name__ == "__main__":
    # Start FastAPI
    threading.Thread(target=start_uvicorn, daemon=True).start()

    # Block until the app is ACTUALLY serving requests
    if not wait_for_health():
        raise RuntimeError("❌ Server started but health check never passed")

    # Only now expose it
    start_ngrok_with_retry(PORT)

    # Keep process alive
    while True:
        time.sleep(60)
