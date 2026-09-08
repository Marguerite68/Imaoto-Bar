const fs = require("fs");
const path = require("path");

const [iconsetDirectory, outputPath] = process.argv.slice(2);
if (!iconsetDirectory || !outputPath) {
  throw new Error("Usage: PackageAppIcon.js <iconset-directory> <output.icns>");
}

const representations = [
  ["icp4", "icon_16x16.png"],
  ["icp5", "icon_32x32.png"],
  ["icp6", "icon_32x32@2x.png"],
  ["ic07", "icon_128x128.png"],
  ["ic08", "icon_128x128@2x.png"],
  ["ic09", "icon_512x512.png"],
  ["ic10", "icon_512x512@2x.png"],
];

const blocks = representations.map(([type, filename]) => {
  const png = fs.readFileSync(path.join(iconsetDirectory, filename));
  const header = Buffer.alloc(8);
  header.write(type, 0, 4, "ascii");
  header.writeUInt32BE(header.length + png.length, 4);
  return Buffer.concat([header, png]);
});

const fileHeader = Buffer.alloc(8);
fileHeader.write("icns", 0, 4, "ascii");
fileHeader.writeUInt32BE(fileHeader.length + blocks.reduce((size, block) => size + block.length, 0), 4);
fs.writeFileSync(outputPath, Buffer.concat([fileHeader, ...blocks]));
