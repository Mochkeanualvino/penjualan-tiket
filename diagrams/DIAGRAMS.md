# Dokumentasi Diagram UML & ERD - Sistem Penjualan Tiket Bioskop

Dokumen ini berisi kumpulan diagram perancangan sistem (*UML*) dan basis data (*ERD*) untuk aplikasi **Sistem Penjualan Tiket Bioskop** (Frontend: Flutter, Backend: Laravel REST API).

Semua diagram di bawah ini dapat dilihat langsung di markdown preview dan juga telah diekspor ke dalam file `.drawio` di folder ini yang dapat dibuka langsung menggunakan **Draw.io / diagrams.net** atau ekstensi Draw.io di VS Code.

---

## Daftar File Diagram Draw.io
1. [`penjualan_tiket_diagrams.drawio`](./penjualan_tiket_diagrams.drawio) - Semua diagram dalam 1 file multi-halaman/tabs (Use Case, Activity, Sequence, ERD).
2. [`use_case_diagram.drawio`](./use_case_diagram.drawio) - Diagram Use Case
3. [`activity_diagram.drawio`](./activity_diagram.drawio) - Diagram Activity
4. [`sequence_diagram.drawio`](./sequence_diagram.drawio) - Diagram Sequence
5. [`erd_diagram.drawio`](./erd_diagram.drawio) - Diagram ERD (Entity Relationship)

---

## 1. Use Case Diagram

Diagram ini memetakan interaksi fungsional antara aktor (**Pelanggan** dan **Admin**) dengan sistem.

```mermaid
graph TD
    classDef actor fill:#f9f,stroke:#333,stroke-width:2px;
    classDef usecase fill:#e1f5fe,stroke:#0288d1,stroke-width:2px;

    Pelanggan((fa:fa-user Pelanggan))
    Admin((fa:fa-user-tie Admin))

    subgraph "Sistem Penjualan Tiket Bioskop"
        UC_Auth([Registrasi & Login])
        UC_Browse([Lihat Daftar & Cari Film])
        UC_DetailFilm([Lihat Detail Film & Jadwal])
        UC_PilihKursi([Pilih Kursi Bioskop])
        UC_MFood([Pesan Makanan / M-Food])
        UC_Promo([Klaim Promo / Voucher])
        UC_Bayar([Pembayaran Tiket])
        UC_Riwayat([Lihat Riwayat & E-Ticket])
        UC_AutoSave([Auto-Save Draft Input])

        UC_KelolaFilm([Kelola Data Film CRUD])
        UC_KelolaStudio([Kelola Data Studio CRUD])
        UC_KelolaJadwal([Kelola Jadwal Tayang CRUD])
        UC_KelolaKursi([Kelola Denah & Kapasitas Kursi])
        UC_KelolaMakanan([Kelola Menu Makanan M-Food])
        UC_Monitoring([Monitoring & Status Transaksi])
    end

    Pelanggan --> UC_Auth
    Pelanggan --> UC_Browse
    Pelanggan --> UC_DetailFilm
    Pelanggan --> UC_PilihKursi
    Pelanggan --> UC_MFood
    Pelanggan --> UC_Promo
    Pelanggan --> UC_Bayar
    Pelanggan --> UC_Riwayat

    Admin --> UC_Auth
    Admin --> UC_KelolaFilm
    Admin --> UC_KelolaStudio
    Admin --> UC_KelolaJadwal
    Admin --> UC_KelolaKursi
    Admin --> UC_KelolaMakanan
    Admin --> UC_Monitoring

    UC_PilihKursi -.->|<<include>>| UC_DetailFilm
    UC_Bayar -.->|<<include>>| UC_PilihKursi
    UC_KelolaFilm -.->|<<include>>| UC_AutoSave
```

---

## 2. Activity Diagram (Alur Pemesanan Tiket Pelanggan)

Diagram aktivitas alur pemesanan tiket bioskop dari pemilihan film hingga mendapatkan E-Ticket.

```mermaid
flowchart TD
    startNode([Mulai]) --> A1[Pelanggan Buka Aplikasi]
    A1 --> A2{Sudah Login?}
    A2 -- Belum --> A3[Input Email & Password]
    A3 --> A4[Validasi Kredensial via Sanctum API]
    A4 --> A5[Tampil Dashboard Home]
    A2 -- Sudah --> A5

    A5 --> A6[Pilih Film & Lihat Detail Sinopsis]
    A6 --> A7[Pilih Bioskop, Studio, dan Jadwal Jam Tayang]
    A7 --> A8[Pilih Nomor Kursi yang Masih Kosong]
    A8 --> A9{Ingin Tambah M-Food / Promo?}
    
    A9 -- Ya --> A10[Pilih Menu Snack / Masukkan Kode Voucher]
    A10 --> A11[Kalkulasi Total Pembayaran]
    A9 -- Tidak --> A11

    A11 --> A12[Pilih Metode Pembayaran Transfer/E-Wallet/QRIS]
    A12 --> A13[Konfirmasi & Submit Transaksi]
    
    A13 --> B1[Backend API Laravel Memproses Booking]
    B1 --> B2{Validasi Kursi Tersedia?}
    B2 -- Konflik/Terisi --> B3[Notifikasi Kursi Sudah Dipesan]
    B3 --> A8
    
    B2 -- Sukses --> B4[Simpan Transaksi ke Database]
    B4 --> B5[Generate E-Ticket & Update Status Lunas]
    B5 --> A14[Tampilkan Bukti E-Ticket & QR Code di Aplikasi]
    A14 --> endNode([Selesai])
```

---

## 3. Sequence Diagram (Proses Booking & Pembayaran Tiket)

Diagram urutan pemanggilan pesan dan eksekusi antar modul Frontend dan Backend API.

```mermaid
sequenceDiagram
    autonumber
    actor User as Pelanggan
    participant UI as Flutter Screen (PilihKursi / Bayar)
    participant Prov as TransaksiProvider
    participant API as ApiService (HTTP Client)
    participant Laravel as TransaksiController (Laravel API)
    participant DB as SQLite / MySQL Database

    User->>UI: Pilih Kursi (misal: A1, A2) & Klik Checkout
    UI->>Prov: setSelectedKursi(['A1', 'A2']) & setJadwal(jadwalId)
    User->>UI: Pilih Metode Pembayaran & Klik Konfirmasi Bayar
    UI->>Prov: submitTransaksi(userId, jadwalId, kursiList, total)
    
    Prov->>API: POST /api/v1/transaksi (payload JSON)
    API->>Laravel: HTTP POST request with Bearer Token
    
    Laravel->>DB: Query Cek Ketersediaan Kursi pada Jadwal
    DB-->>Laravel: Status Kursi Kosong
    
    Laravel->>DB: INSERT INTO transaksis (id, user_id, jadwal_id, total, status)
    DB-->>Laravel: Berhasil Disimpan
    
    Laravel-->>API: 201 Created { status: 'success', data: transaksi }
    API-->>Prov: Return response Map data
    Prov-->>UI: Update State Transaksi & Notifikasi Sukses
    UI-->>User: Tampilkan Layar E-Ticket (QR Code & Detail Kursi)
```

---

## 4. Entity Relationship Diagram (ERD)

Diagram struktur basis data dan relasi antar tabel (Database SQLite / MySQL Laravel).

```mermaid
erDiagram
    USERS ||--o{ TRANSAKSIS : "melakukan"
    USERS ||--o{ AUTO_SAVE_DRAFTS : "memiliki"
    FILMS ||--o{ JADWALS : "ditayangkan_dalam"
    STUDIOS ||--o{ JADWALS : "digunakan_pada"
    JADWALS ||--o{ TRANSAKSIS : "dipesan_dalam"

    USERS {
        string id PK
        string name
        string email UK
        string password
        string role "Admin | Pelanggan"
        timestamp created_at
        timestamp updated_at
    }

    FILMS {
        string id PK
        string judul
        string genre
        int durasi
        string rating_usia
        text poster_url
        boolean is_segera_tayang
        timestamp created_at
        timestamp updated_at
    }

    STUDIOS {
        string id PK
        string nama
        int kapasitas
        string tipe_studio "Regular | VIP | IMAX"
        timestamp created_at
        timestamp updated_at
    }

    JADWALS {
        string id PK
        string film_id FK
        string studio_id FK
        string tanggal
        string jam_tayang
        decimal harga
        timestamp created_at
        timestamp updated_at
    }

    TRANSAKSIS {
        string id PK
        string user_id FK
        string jadwal_id FK
        json kursi_list "['A1', 'A2', ...]"
        decimal total_harga
        string metode_pembayaran
        string status "Lunas | Pending | Batal"
        string tanggal_transaksi
        timestamp created_at
        timestamp updated_at
    }

    AUTO_SAVE_DRAFTS {
        string id PK
        string user_id FK
        string form_key "misal: form_film"
        text form_data "JSON input data"
        timestamp created_at
        timestamp updated_at
    }
```
