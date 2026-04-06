# npm-dep-check

A Fish shell tool to query your npm dependency tree for packages and versions. Unlike `npm ls`, it provides concise, one-line results, supports wildcard searches, and highlights matching versions—making it easy to see which versions of a package are used across your entire project (including transitive dependencies).

---

## ✨ Features

* 🔍 Search across the entire dependency tree (including transitive dependencies)
* 📦 Supports exact and partial version matching
* 🌐 Wildcard support for package name searches (e.g. `@angular/*`)
* 📄 Concise one-line output per package
* 🎯 Highlights matching versions for quick visibility
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
npm-dep-check typescript@5

typescript@5.4.5 (MATCH)
```

### Match multiple version patterns

```fish
npm-dep-check typescript@5.2,5.4

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
npm-dep-check "@angular/*@18"

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

* The script requires a valid npm project. If `npm ls` fails, results may be incomplete.
* Wildcards (`*`) are only supported for package names, not versions.
* Version matching supports prefix patterns (e.g. `1` matches `1.x.x`).

---

## 📁 Installation

```fish
fisher install jarlucmat/npm-dep-check
```

---

## 🔄 Compared to npm ls

| Feature                  | npm ls | npm-dep-check |
|--------------------------|--------|----------------|
| Full dependency tree     | ✅     | ✅             |
| Concise output           | ❌     | ✅             |
| Wildcard search          | ❌     | ✅             |
| Version pattern matching | ❌     | ✅             |
| Highlighted matches      | ❌     | ✅             |

