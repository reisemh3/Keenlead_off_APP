// Setup type definitions for built-in Supabase Runtime APIs
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";
import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const PRESIGNED_URL_TTL_SECONDS = 300;

function r2Client() {
  return new S3Client({
    region: "auto",
    endpoint: `https://${Deno.env.get("R2_ACCOUNT_ID")}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: Deno.env.get("R2_ACCESS_KEY_ID")!,
      secretAccessKey: Deno.env.get("R2_SECRET_ACCESS_KEY")!,
    },
  });
}

/**
 * Mobile counterpart of web/app/api/upload-url/route.ts: issues a
 * short-lived presigned PUT URL so the Flutter app can upload track
 * audio/covers directly to Cloudflare R2 without ever holding R2
 * secret keys on-device. Requires a logged-in Supabase user (`auth:
 * 'user'`) — admin-only restriction lands with the real auth/roles
 * work in Étape 4/5.
 */
export default {
  fetch: withSupabase({ auth: "user" }, async (req) => {
    const { path, contentType } = await req.json();

    if (!path || !contentType) {
      return Response.json(
        { message: "path and contentType are required", code: "bad_request" },
        { status: 400 },
      );
    }

    const bucket = Deno.env.get("R2_BUCKET_NAME")!;
    const command = new PutObjectCommand({
      Bucket: bucket,
      Key: path,
      ContentType: contentType,
    });

    const uploadUrl = await getSignedUrl(r2Client(), command, {
      expiresIn: PRESIGNED_URL_TTL_SECONDS,
    });
    const publicUrl = `${Deno.env.get("R2_PUBLIC_BASE_URL")}/${path}`;

    return Response.json({ uploadUrl, publicUrl });
  }),
};

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Log in from the app so you have a user JWT, then:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/get-upload-url' \
    --header 'Authorization: Bearer <user-jwt>' \
    --header 'Content-Type: application/json' \
    --data '{"path":"tracks/test.mp3","contentType":"audio/mpeg"}'

*/
