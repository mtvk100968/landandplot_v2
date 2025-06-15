module.exports = {
  env: {
    es6: true,
    node: true,
    es2020: true,
  },
  parserOptions: {
    "ecmaVersion": 2020,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "require-jsdoc": "off", // no need to write JSDoc for every function
    "max-len": ["error", { // increase maximum line length
      code: 120,
      ignoreStrings: true,
      ignoreComments: true,
      ignoreTemplateLiterals: true,
    }],
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
