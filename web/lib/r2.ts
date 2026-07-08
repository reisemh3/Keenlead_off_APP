import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

/**
 * Cloudflare R2 is S3-compatible, so the AWS SDK works against its
 * S3 API endpoint. Credentials only ever live server-side (this
 * module must not be imported from client components) — browser and
 * mobile clients get a short-lived presigned PUT URL instead.
 */
function r2Client() {
  return new S3Client({
    region: "auto",
    endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: process.env.R2_ACCESS_KEY_ID!,
      secretAccessKey: process.env.R2_SECRET_ACCESS_KEY!,
    },
  });
}

const PRESIGNED_URL_TTL_SECONDS = 300;

export async function createPresignedUploadUrl(params: {
  path: string;
  contentType: string;
}) {
  const client = r2Client();
  const bucket = process.env.R2_BUCKET_NAME!;

  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: params.path,
    ContentType: params.contentType,
  });

  const uploadUrl = await getSignedUrl(client, command, {
    expiresIn: PRESIGNED_URL_TTL_SECONDS,
  });

  const publicUrl = `${process.env.R2_PUBLIC_BASE_URL}/${params.path}`;

  return { uploadUrl, publicUrl };
}
