# Example: console log capture (anthropics/skills/webapp-testing)
# Requires: pip install playwright && playwright install chromium

from playwright.sync_api import sync_playwright

url = "http://localhost:5173"

console_logs = []

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1920, "height": 1080})

    def handle_console_message(msg):
        console_logs.append(f"[{msg.type}] {msg.text}")
        print(f"Console: [{msg.type}] {msg.text}")

    page.on("console", handle_console_message)

    page.goto(url)
    page.wait_for_load_state("networkidle")
    page.click("text=Dashboard")
    page.wait_for_timeout(1000)

    browser.close()

with open("console.log", "w", encoding="utf-8") as f:
    f.write("\n".join(console_logs))

print(f"\nCaptured {len(console_logs)} console messages")
print("Logs saved to: console.log")
