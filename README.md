# npm-dep-check

A Fish shell utility to inspect your npm dependency tree and quickly check whether specific packages (and versions) are present.

It traverses the full dependency graph (including transitive dependencies) and highlights matching versions directly in the output.

---

## ✨ Features

* 🔍 Search for packages across the entire dependency tree (not just top-level)
* 📦 Supports exact and partial version matching
* 🎯 Highlights matching versions for quick visibility
* 🌐 Wildcard support for package name searches (e.g. `@angular/*`)
* ⚡ Uses caching for fast repeated lookups
* 🐚 Built specifically for Fish shell

---

## 📦 Requirements

Make sure the following tools are installed:

* [`npm`](https://www.npmjs.com/) — used to retrieve the dependency tree
* [`jq`](https://stedolan.github.io/jq/) — used to process JSON output

---

## 🚀 Usage

```fish
npm-dep-check [OPTIONS] [PACKAGE...]
```

If no package is provided, all dependencies are listed.

---

## 🔎 Examples

### Check if a package exists

```fish
npm-dep-check typescript

typescript@5.4.5
```

### Check for a specific version

```fish
npm-dep-check typescript@5                                                                                                                                              trunk ✱

typescript@5.4.5 (MATCH)
```

### Match multiple version patterns

```fish
npm-dep-check typescript@5.2,5.4                                                                                                                                    ✘ 4 trunk ✱

typescript@5.4.5 (MATCH)
```

### Search with wildcard

```fish
npm-dep-check '@angular/*'

@angular/animations@18.0.0
@angular/build@18.0.1
@angular/cli@18.0.1
@angular/common@18.0.0
@angular/compiler@18.0.0
@angular/compiler-cli@18.0.0
@angular/core@18.0.0
@angular/forms@18.0.0
@angular/platform-browser@18.0.0
@angular/platform-browser-dynamic@18.0.0
@angular/router@18.0.0
```

### Combine wildcard and version

```fish
npm-dep-check "@angular/*@18"                                                                                                                                       ✘ 4 trunk ✱

@angular/animations@18.0.0 (MATCH)
@angular/build@18.0.1 (MATCH)
@angular/cli@18.0.1 (MATCH)
@angular/common@18.0.0 (MATCH)
@angular/compiler@18.0.0 (MATCH)
@angular/compiler-cli@18.0.0 (MATCH)
@angular/core@18.0.0 (MATCH)
@angular/forms@18.0.0 (MATCH)
@angular/platform-browser@18.0.0 (MATCH)
@angular/platform-browser-dynamic@18.0.0 (MATCH)
@angular/router@18.0.0 (MATCH)
```

---

## ⚙️ Options

| Option                 | Description                               |
| ---------------------- | ----------------------------------------- |
| `-h`, `--help`         | Show help message                         |
| `-v`, `--verbose`      | Enable debug output                       |
| `-f`, `--found`        | Show only found packages                  |
| `-o`, `--only-matches` | Show only packages with matching versions |

---

## 🧠 How it works

* Runs `npm ls --all --json` to retrieve the full dependency tree
* Uses `jq` to extract all package names and versions
* Caches the result for fast querying within a single run
* Applies regex-based matching for flexible searches

---

## ⚠️ Notes

* The script relies on a valid npm project. If `npm ls` fails, results may be incomplete.
* Wildcards (`*`) are only supported for package names, not versions.
* Version matching supports prefix patterns (e.g. `1` matches `1.x.x`).

---

## 📁 Installation

```fish
fisher install jarlucmat/npm-dep-check
```
