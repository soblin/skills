// Apply the configs bundled with the textlint-ja and textlint-en skills to this repository,
// without copying their contents.
const path = require("node:path");
const fs = require("node:fs");
const { createRequire } = require("node:module");

const requireYaml = () => {
  try {
    return require("js-yaml");
  } catch {
    return createRequire(fs.realpathSync(process.argv[1]))("js-yaml");
  }
};
const yaml = requireYaml();

const load = (lang) => {
  const dir = path.join(__dirname, "skills", `textlint-${lang}`, "config");
  const config = yaml.load(fs.readFileSync(path.join(dir, ".textlintrc.yaml"), "utf8"));
  // prh resolves rulePaths relative to this file, so make them absolute.
  if (config.rules.prh) {
    config.rules.prh.rulePaths = config.rules.prh.rulePaths.map((p) => path.join(dir, p));
  }
  return config;
};

const ja = load("ja");
const en = load("en");

module.exports = {
  filters: { ...ja.filters, ...en.filters },
  rules: {
    ...ja.rules,
    ...en.rules,
    // both configs use prh, so combine their dictionaries into one rule.
    prh: { rulePaths: [...ja.rules.prh.rulePaths, ...en.rules.prh.rulePaths] },
  },
};
