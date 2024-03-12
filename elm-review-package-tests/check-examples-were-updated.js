#!/usr/bin/env node

import { execSync } from "child_process";
import { copyPreviewsToExamples } from "../maintenance/copy-preview-to-examples.js";
import { red, yellow } from "./helpers/ansi.js";

const preCheckGitStatus = execSync("git status --porcelain").toString().trim();
if (preCheckGitStatus !== "") {
  console.error(
    `${red("✖")} Check aborted: There are uncommitted changes in the project.`
  );
  process.exit(1);
}

copyPreviewsToExamples();

const postCheckGitStatus = execSync("git status --porcelain").toString().trim();
if (postCheckGitStatus !== "") {
  console.error("\u001B[31m✖\u001B[39m Your examples were not up to date.");
  console.log(
    `Please commit the changes I made. If you see this message from GitHub Actions, then run
    ${yellow("node maintenance/update-examples-from-preview.js")}
to update your examples.`
  );
  process.exit(1);
}

process.exit(0);
