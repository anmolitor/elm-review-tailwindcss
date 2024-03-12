import fs from "fs-extra";
import { createRequire } from "module";
import * as path from "path";
import * as url from "url";
import { findPreviewConfigurations } from "../elm-review-package-tests/helpers/find-configurations.js";

const localRequire = createRequire(url.fileURLToPath(import.meta.url));
const __dirname = path.dirname(url.fileURLToPath(import.meta.url));

const root = path.resolve(__dirname, "..");
const packageElmJson = localRequire(`${root}/elm.json`);

export function copyPreviewsToExamples() {
  const previewFolders = findPreviewConfigurations();
  previewFolders.forEach(copyPreviewToExample);
}

function copyPreviewToExample(pathToPreviewFolder) {
  const pathToExampleFolder = `${pathToPreviewFolder}/`.replace(
    /preview/g,
    "example"
  );
  fs.removeSync(pathToExampleFolder);
  fs.copySync(pathToPreviewFolder, pathToExampleFolder, { overwrite: true });

  const pathToElmJson = path.resolve(pathToExampleFolder, "elm.json");
  const elmJson = fs.readJsonSync(pathToElmJson);

  // Remove the source directory pointing to the package's src/
  elmJson["source-directories"] = elmJson["source-directories"].filter(
    (sourceDirectory) =>
      path.resolve(pathToExampleFolder, sourceDirectory) !==
      path.resolve(root, "src")
  );
  elmJson.dependencies.direct[packageElmJson.name] = packageElmJson.version;
  fs.writeJsonSync(pathToElmJson, elmJson, { spaces: 4 });
}
