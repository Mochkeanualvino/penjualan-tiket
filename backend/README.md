# Penjualan Tiket Bioskop - Backend Laravel API

Backend REST API untuk aplikasi Flutter Penjualan Tiket Bioskop.

## Prasyarat
- PHP >= 8.1
- Composer
- MySQL dari XAMPP

## Instalasi

```bash
cd backend

# Install dependencies
composer install

# Copy file environment
copy .env.example .env

# Generate app key
php artisan key:generate

# Buat database `tiket_bioskop` melalui phpMyAdmin terlebih dahulu

# Jalankan migrasi & seeder
php artisan migrate --seed

# Jalankan server lokal
php artisan serve
```

Server akan berjalan di `http://localhost:8000`

## API Endpoints

### Authentication
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/v1/auth/login` | Login user |
| POST | `/api/v1/auth/register` | Register user baru |
| GET | `/api/v1/auth/me` | Get current user |

### Auto-Save Draft (Simpan Otomatis Input)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/v1/drafts/auto-save` | Simpan draft input otomatis |
| GET | `/api/v1/drafts/{formKey}` | Ambil draft tersimpan |
| DELETE | `/api/v1/drafts/{formKey}` | Hapus draft |

### Film
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/films` | Daftar semua film |
| POST | `/api/v1/films` | Tambah film baru |
| GET | `/api/v1/films/{id}` | Detail film |
| PUT | `/api/v1/films/{id}` | Update film |
| DELETE | `/api/v1/films/{id}` | Hapus film |

### Studio
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/studios` | Daftar semua studio |
| POST | `/api/v1/studios` | Tambah studio |
| PUT | `/api/v1/studios/{id}` | Update studio |
| DELETE | `/api/v1/studios/{id}` | Hapus studio |

### Jadwal
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/jadwal` | Daftar semua jadwal |
| POST | `/api/v1/jadwal` | Tambah jadwal |
| PUT | `/api/v1/jadwal/{id}` | Update jadwal |
| DELETE | `/api/v1/jadwal/{id}` | Hapus jadwal |

### Transaksi
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/transaksi` | Daftar semua transaksi |
| POST | `/api/v1/transaksi` | Buat transaksi baru |
| PUT | `/api/v1/transaksi/{id}/status` | Update status transaksi |

## Default Credentials (Seeder)
- **Admin**: admin@cinema.com / 12345
- **Pelanggan**: pelanggan@bioskop.com / user123
