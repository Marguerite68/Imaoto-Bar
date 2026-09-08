const fs = require("fs");

const [iconPath] = process.argv.slice(2);
if (!iconPath) {
  throw new Error("Usage: VerifyAppIconPackage.js <icon.icns>");
}

const contents = fs.readFileSync(iconPath);
const expectedTypes = ["ic07", "ic08", "ic09", "ic10"];
const types = [];

for (let offset = 8; offset + 8 <= contents.length;) {
  const type = contents.toString("ascii", offset, offset + 4);
  const length = contents.readUInt32BE(offset + 4);
  if (length < 8 || offset + length > contents.length) {
    throw new Error("FAIL: app icon has an invalid ICNS resource length");
  }
  types.push(type);
  offset += length;
}

if (types.length !== expectedTypes.length || types.some((type, index) => type !== expectedTypes[index])) {
  throw new Error(`FAIL: app icon must contain only safe PNG resource types (${expectedTypes.join(", ")}); found ${types.join(", ")}`);
}

console.log("PASS: app icon package contains only safe PNG resource types");
