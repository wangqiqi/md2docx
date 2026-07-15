# Example: static HTML via file:// (anthropics/skills/webapp-testing)
# Requires: pip install playwright && playwright install chromium

import os

from playwright.sync_api import sync_playwright

html_file_path = os.path.abspath("path/to/your/file.html")
file_url = f"file://{html_file_path}"

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1920, "height": 1080})

    page.goto(file_url)
    page.screenshot(path="static_page.png", full_page=True)

    page.click("text=Click Me")
    page.fill("#name", "John Doe")
    page.fill("#email", "john@example.com")
    page.click('button[type="submit"]')
    page.wait_for_timeout(500)

    page.screenshot(path="after_submit.png", full_page=True)
    browser.close()

print("Static HTML automation completed!")
