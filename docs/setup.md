# Setup

Two ways to work with the lab: run it locally on a laptop, or connect to a real
z/OS for the full integration.

## A. Run it locally (quick start, no mainframe)

[GnuCOBOL](https://gnucobol.sourceforge.io/) compiles and runs the COBOL on
macOS / Linux:

```sh
brew install gnucobol     # once
make test                 # unit tests for the pricing logic
make run                  # whole pipeline: price -> report -> SAP extract
```

Everything runs except the DB2 load, which needs a real DB2 runtime (see B).

## B. Full environment — real z/OS

Edited from VS Code, run on IBM z/OS.

1. **z/OS** — sign up for **IBM Z Xplore** (https://ibm.com/z/xplore), a free
   learning platform on real z/OS. Note the host, user id and connection details.
2. **VS Code extensions**
   - **IBM Z Open Editor** — COBOL / PL/I / JCL language support.
   - **Zowe Explorer** — browse datasets, submit JCL, view job output.
3. **Java 21+** — the IBM Z Open Editor language server needs a 64-bit JDK 21 or
   newer on the path:
   ```sh
   brew install openjdk@21
   java -version
   ```
4. **Zowe profile** — point a Zowe Explorer connection at the Z Xplore host
   (z/OSMF or FTP endpoint as Xplore specifies); datasets and job output then
   appear in the Zowe side panel.

## C. Local offline z/OS sandbox (optional)

For a fully offline z/OS-style sandbox: **Hercules** emulator + **TK5** (turnkey
MVS 3.8j) — COBOL / JCL / VSAM fundamentals on the Mac with no cloud account.
