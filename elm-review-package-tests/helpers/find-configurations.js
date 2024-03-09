import * as glob from "glob";
import * as path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const root = path
  .resolve(__dirname, "../../")
  .replace(/.:/, "")
  .replace(/\\/g, "/");

export function findPreviewConfigurations() {
  return glob
    .sync(`${root}/preview*/**/elm.json`, {
      ignore: ["**/elm-stuff/**"],
      nodir: true,
    })
    .map(path.dirname);
}
