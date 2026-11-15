# Setup

The lab targets a **real z/OS** environment, edited from VS Code on macOS.

## 1. z/OS environment — IBM Z Xplore (free)

1. Sign up at **https://ibm.com/z/xplore** (IBM Z Xplore — free learning platform on real z/OS).
2. Complete the first login; note the z/OS host, user id and the connection
   details Xplore provides.

## 2. VS Code extensions

- **IBM Z Open Editor** — COBOL / PL/I / JCL language support (needs a Java 8+ runtime).
- **Zowe Explorer** — browse datasets, submit JCL, view job output.

## 3. Java runtime (for IBM Z Open Editor)

A JDK 8+ must be on the path for the language server. Verify:

```
java -version
```

## 4. Zowe profile

Create a Zowe Explorer connection profile pointing at the Z Xplore host (z/OSMF
or FTP endpoint as Xplore specifies), then connect — datasets and job output
appear in the Zowe side panel.

## 5. Local alternative (optional, later)

For a fully local, offline z/OS-style sandbox: **Hercules** emulator + **TK5**
(turnkey MVS 3.8j). A lighter path for practising COBOL / JCL / VSAM fundamentals
on the Mac with no cloud account. Added later if wanted.
