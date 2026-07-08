import { NextResponse } from "next/server";

/**
 * Confirms the web app is correctly configured to reach Supabase, by
 * hitting its public auth health endpoint (no session/tables required).
 * Temporary check for the technical-setup step.
 */
export async function GET() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!supabaseUrl || !anonKey) {
    return NextResponse.json(
      { connected: false, error: "Missing Supabase env vars — see web/.env.example" },
      { status: 500 },
    );
  }

  try {
    const response = await fetch(`${supabaseUrl}/auth/v1/health`, {
      headers: { apikey: anonKey },
    });
    return NextResponse.json({ connected: response.ok });
  } catch (error) {
    return NextResponse.json(
      { connected: false, error: (error as Error).message },
      { status: 500 },
    );
  }
}
