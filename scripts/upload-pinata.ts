#!/usr/bin/env tsx

import "dotenv/config";
import { existsSync } from "node:fs";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { PinataSDK } from "pinata";

type Attribute = {
  trait_type: string;
  value: string;
};

type NftMetadata = {
  name: string;
  description: string;
  image: string;
  attributes?: Attribute[];
};

const MIME_TYPES = new Map<string, string>([
  [".gif", "image/gif"],
  [".jfif", "image/jpeg"],
  [".jpeg", "image/jpeg"],
  [".jpg", "image/jpeg"],
  [".png", "image/png"],
  [".svg", "image/svg+xml"],
  [".webp", "image/webp"],
]);

function argValue(name: string, fallback?: string): string | undefined {
  const index = process.argv.indexOf(name);
  if (index === -1) return fallback;

  const value = process.argv[index + 1];
  if (!value || value.startsWith("--")) {
    throw new Error(`Missing value for ${name}`);
  }

  return value;
}

function allArgValues(name: string): string[] {
  const values: string[] = [];

  for (let i = 0; i < process.argv.length; i++) {
    if (process.argv[i] === name) {
      const value = process.argv[i + 1];
      if (!value || value.startsWith("--")) {
        throw new Error(`Missing value for ${name}`);
      }
      values.push(value);
    }
  }

  return values;
}

function parseAttributes(rawAttributes: string[]): Attribute[] {
  return rawAttributes.map((rawAttribute) => {
    const separator = rawAttribute.indexOf("=");
    if (separator === -1) {
      throw new Error(`Invalid attribute "${rawAttribute}". Use Trait=Value.`);
    }

    return {
      trait_type: rawAttribute.slice(0, separator).trim(),
      value: rawAttribute.slice(separator + 1).trim(),
    };
  });
}

function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`${name} is required`);
  }
  return value;
}

function slugify(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

async function main(): Promise<void> {
  const pinataJwt = requireEnv("PINATA_JWT");
  const imagePath = argValue("--image", process.env.NFT_IMAGE_PATH);
  const nftName = argValue("--name", process.env.NFT_NAME ?? "CoolMonkey #0");
  const description = argValue(
    "--description",
    process.env.NFT_DESCRIPTION ?? "A CoolMonkey NFT."
  );
  const outputDir = argValue("--out-dir", process.env.NFT_METADATA_DIR ?? "metadata");

  if (!imagePath) throw new Error("Provide an image with --image or NFT_IMAGE_PATH.");
  if (!nftName) throw new Error("Provide a name with --name or NFT_NAME.");
  if (!description) throw new Error("Provide a description with --description or NFT_DESCRIPTION.");
  if (!outputDir) throw new Error("Provide an output directory with --out-dir or NFT_METADATA_DIR.");
  if (!existsSync(imagePath)) throw new Error(`Image not found: ${imagePath}`);

  const extension = path.extname(imagePath).toLowerCase();
  const mimeType = MIME_TYPES.get(extension);
  if (!mimeType) throw new Error(`Unsupported image extension: ${extension}`);

  const pinata = new PinataSDK({
    pinataJwt,
    pinataGateway: process.env.PINATA_GATEWAY || undefined,
  });

  const safeName = slugify(nftName) || "nft";
  const imageBytes = await readFile(imagePath);
  const imageFile = new File([new Uint8Array(imageBytes)], path.basename(imagePath), {
    type: mimeType,
  });

  const imageUpload = await pinata.upload.public
    .file(imageFile)
    .name(`${safeName}-image`);

  const metadata: NftMetadata = {
    name: nftName,
    description,
    image: `ipfs://${imageUpload.cid}`,
  };

  const attributes = parseAttributes(allArgValues("--attribute"));
  if (attributes.length > 0) metadata.attributes = attributes;

  await mkdir(outputDir, { recursive: true });

  const metadataPath = path.join(outputDir, `${safeName}.json`);
  await writeFile(metadataPath, `${JSON.stringify(metadata, null, 2)}\n`);

  const metadataUpload = await pinata.upload.public
    .json(metadata)
    .name(`${safeName}.json`);

  const result = {
    imageCid: imageUpload.cid,
    imageUri: metadata.image,
    metadataCid: metadataUpload.cid,
    metadataUri: `ipfs://${metadataUpload.cid}`,
    metadataPath,
  };

  const resultPath = path.join(outputDir, `${safeName}.upload.json`);
  await writeFile(resultPath, `${JSON.stringify(result, null, 2)}\n`);

  console.log(`Image URI: ${result.imageUri}`);
  console.log(`Metadata URI: ${result.metadataUri}`);
  console.log(`Metadata file: ${metadataPath}`);
  console.log(`Upload result: ${resultPath}`);
  console.log("");
  console.log(`NFT_TOKEN_URI=${result.metadataUri}`);
}

main().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error(message);
  process.exitCode = 1;
});
