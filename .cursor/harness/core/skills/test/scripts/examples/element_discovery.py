# Example: element discovery (anthropics/skills/webapp-testing)
# Requires: pip install playwright && playwright install chromium

from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    page.goto("http://localhost:5173")
    page.wait_for_load_state("networkidle")

    buttons = page.locator("button").all()
    print(f"Found {len(buttons)} buttons:")
    for i, button in enumerate(buttons):
        text = button.inner_text() if button.is_visible() else "[hidden]"
        print(f"  [{i}] {text}")

    links = page.locator("a[href]").all()
    print(f"\nFound {len(links)} links:")
    for link in links[:5]:
        text = link.inner_text().strip()
        href = link.get_attribute("href")
        print(f"  - {text} -> {href}")

    inputs = page.locator("input, textarea, select").all()
    print(f"\nFound {len(inputs)} input fields:")
    for input_elem in inputs:
        name = input_elem.get_attribute("name") or input_elem.get_attribute("id") or "[unnamed]"
        input_type = input_elem.get_attribute("type") or "text"
        print(f"  - {name} ({input_type})")

    page.screenshot(path="page_discovery.png", full_page=True)
    print("\nScreenshot saved to page_discovery.png")

    browser.close()
