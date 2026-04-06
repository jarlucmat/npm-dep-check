
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
```

### Check for a specific version

```fish
npm-dep-check typescript@5.0.0
```

### Match multiple version patterns

```fish
npm-dep-check typescript@5,4.9
```

### Search with wildcard

```fish
npm-dep-check '@angular/*'
```

### Combine wildcard and version

```fish
npm-dep-check '@angular/*@18'
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

---

## 💡 Example Output

```text
typescript@5.4.2
@angular/core@18.0.0 (MATCH)
rxjs@7.8.1
```

* `(MATCH)` indicates that the version matches your query
* Colored output highlights matches and versions (if your terminal supports ANSI colors)

---
