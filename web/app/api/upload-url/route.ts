import { NextRequest, NextResponse } from "next/server";

import { createPresignedUploadUrl } from "@/lib/r2";
import { createClient } from "@/lib/supabase/server";

/**
 * Issues a short-lived presigned PUT URL for uploading a file (track
 * audio, cover) to Cloudflare R2. Used by the web admin UI; the mobile
 * app calls the equivalent Supabase Edge Function instead (see
 * supabase/functions/get-upload-url) since it has no Next.js server.
 *
 * Auth is only wired here (any logged-in Supabase user); admin-only
 * restriction lands with the real auth/roles work in Étape 4/5.
 */
export async function POST(request: NextRequest) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { path, contentType } = await request.json();

  if (!path || !contentType) {
    return NextResponse.json(
      { error: "path and contentType are required" },
      { status: 400 },
    );
  }

  const presigned = await createPresignedUploadUrl({ path, contentType });
  return NextResponse.json(presigned);
}
