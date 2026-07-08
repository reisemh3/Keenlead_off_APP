"use client";

import { useEffect, useState } from "react";

/**
 * Temporary home page for the technical-setup step: proves the web
 * app can reach Supabase. Replaced by the real public home page
 * (Étape 6 — Web MVP).
 */
export default function Home() {
  const [connected, setConnected] = useState<boolean | null>(null);

  useEffect(() => {
    fetch("/api/health")
      .then((res) => res.json())
      .then((data) => setConnected(data.connected === true))
      .catch(() => setConnected(false));
  }, []);

  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-4 bg-background text-foreground">
      <h1 className="text-4xl font-bold tracking-tight">Keenlead</h1>
      {connected === null ? (
        <p>Vérification de la connexion Supabase…</p>
      ) : (
        <p className={connected ? "text-audio-green" : "text-warm-orange"}>
          {connected
            ? "Connexion Supabase OK"
            : "Connexion Supabase échouée — vérifie web/.env.local"}
        </p>
      )}
    </main>
  );
}
