# Setup

## Run it locally

[GnuCOBOL](https://gnucobol.sourceforge.io/) compiles and runs the COBOL on
macOS / Linux — no mainframe needed:

```sh
brew install gnucobol     # the compiler
brew install openjdk@21   # for the IBM Z Open Editor extension in VS Code
make test                 # unit tests for the pricing logic
make run                  # whole pipeline: price -> report -> invoice extract
```
