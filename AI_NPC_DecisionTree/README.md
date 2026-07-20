# AI NPC – Decision Tree (Godot 4)

## Cara menjalankan
1. Install Godot 4.x dari https://godotengine.org/download (versi terbaru, gratis).
2. Buka Godot → **Import** → pilih folder project ini (file `project.godot`).
3. Klik tombol **Run** (F5). Scene utama `Main.tscn` akan otomatis dijalankan.
4. Gerakkan **kotak biru** (Player) pakai tombol panah (Arrow Keys).
5. Perhatikan **kotak merah** (NPC) — label di atasnya menunjukkan state yang sedang
   dipilih NPC (PATROL / CHASE / ATTACK / FLEE) hasil dari Decision Tree.

## Cara menguji setiap cabang keputusan
- **PATROL**: jauhkan player dari NPC → NPC akan bolak-balik mengikuti 4 titik patroli.
- **CHASE**: dekatkan player hingga masuk radius ± 260 px → NPC mengejar.
- **ATTACK**: dekatkan player hingga jarak ± 45 px → NPC berhenti dan "menyerang"
  (mengurangi HP player tiap 1 detik).
- **FLEE**: untuk memicu ini secara manual saat testing, buka `NPC.gd`, ubah nilai
  `health` awal jadi di bawah `flee_health_threshold` (30), lalu jalankan lagi —
  NPC akan lari menjauhi player walau sedekat apa pun.

## Struktur file
- `Player.gd` / `Player.tscn` — karakter yang dikendalikan pemain.
- `NPC.gd` / `NPC.tscn` — musuh dengan AI Decision Tree (inti tugas).
- `Main.tscn` — scene yang menggabungkan semuanya + titik-titik patroli.
- `project.godot` — konfigurasi project Godot.

## Logika Decision Tree (inti AI)
Dievaluasi ulang setiap frame di `NPC.gd`, fungsi `decide_state()`:

```
Root: Apakah HP NPC <= 30 (flee_health_threshold)?
├── YA  → FLEE (menjauh dari player, prioritas bertahan hidup)
└── TIDAK → Apakah player terdeteksi?
    ├── TIDAK ADA PLAYER → PATROL
    └── ADA → Berapa jarak ke player?
        ├── jarak <= 45   (attack_range)     → ATTACK
        ├── jarak <= 260  (detection_range)  → CHASE
        └── selebihnya                        → PATROL
```

Decision tree ini berbeda dari FSM murni karena **tidak ada tabel transisi eksplisit
antar state** — setiap frame NPC mengevaluasi ulang seluruh pohon kondisi dari akar,
lalu langsung memutuskan state yang paling sesuai kondisi saat itu (data-driven,
bukan event-driven).
