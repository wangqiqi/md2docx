import js from "@eslint/js";
import pluginVue from "eslint-plugin-vue";
import globals from "globals";
import tseslint from "typescript-eslint";

export default tseslint.config(
  { ignores: ["dist"] },
  {
    extends: [
      js.configs.recommended,
      ...tseslint.configs.recommended,
      ...pluginVue.configs["flat/recommended"],
    ],
    files: ["src/**/*.{ts,vue}", "tests/**/*.ts"],
    languageOptions: {
      ecmaVersion: 2022,
      globals: globals.browser,
      // vue 的 flat/recommended 会把 languageOptions.parser 设为 vue-eslint-parser，
      // 且覆盖到 .ts —— 不指定内层 parser 时源码里的 module 语法直接 parse error
      parserOptions: { parser: tseslint.parser },
    },
  },
);
