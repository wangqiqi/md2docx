import { mount } from "@vue/test-utils";
import { describe, expect, it } from "vitest";
import App from "../src/App.vue";

describe("App", () => {
  it("renders heading", () => {
    const wrapper = mount(App);
    expect(wrapper.get("h1").text()).toBe("Vue 3 + Vite + TypeScript");
  });
});
