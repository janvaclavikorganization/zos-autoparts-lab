# Setup

## Run it locally

[GnuCOBOL](https://gnucobol.sourceforge.io/) compiles and runs the COBOL on
macOS / Linux — no mainframe needed:

```sh
brew install gnucobol     # once
make test                 # unit tests for the pricing logic
make run                  # whole pipeline: price -> report -> invoice extract
```

## Editing (optional)

The COBOL / JCL is edited in **VS Code** with the **IBM Z Open Editor** extension
(syntax highlighting, column rulers for fixed-format COBOL). Its language server
needs a 64-bit **JDK 21+**:

```sh
brew install openjdk@21
```
