<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Film;
use App\Models\Studio;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // === SEED USERS ===
        User::create([
            'id' => 'admin_1',
            'name' => 'Administrator Bioskop',
            'email' => 'admin@bioskop.com',
            'password' => Hash::make('admin123'),
            'role' => 'Admin',
        ]);

        User::create([
            'id' => 'user_1',
            'name' => 'John Doe',
            'email' => 'pelanggan@bioskop.com',
            'password' => Hash::make('user123'),
            'role' => 'Pelanggan',
        ]);

        // === SEED FILMS (SEDANG TAYANG) ===
        $films = [
            ['id' => 'film_1', 'judul' => 'Kado Untuk Ibu', 'genre' => 'Drama, Family', 'durasi' => 92, 'rating_usia' => 'SU', 'poster_url' => 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => false],
            ['id' => 'film_2', 'judul' => 'IP Man: Kungfu Legend', 'genre' => 'Action, Martial Arts', 'durasi' => 172, 'rating_usia' => '13+', 'poster_url' => 'https://images.unsplash.com/photo-1509347528160-9a9e33742cdb?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => false],
            ['id' => 'film_3', 'judul' => 'Thunderbolts*', 'genre' => 'Action, Superhero', 'durasi' => 127, 'rating_usia' => '13+', 'poster_url' => 'https://images.unsplash.com/photo-1635805737707-575885ab0820?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => false],
            ['id' => 'film_4', 'judul' => 'Mission: Impossible - The Final Reckoning', 'genre' => 'Action, Thriller', 'durasi' => 169, 'rating_usia' => '13+', 'poster_url' => 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => false],
            ['id' => 'film_5', 'judul' => 'Lilo & Stitch', 'genre' => 'Animation, Comedy, Family', 'durasi' => 108, 'rating_usia' => 'SU', 'poster_url' => 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => false],
            ['id' => 'film_6', 'judul' => 'Ballerina', 'genre' => 'Action, Thriller', 'durasi' => 114, 'rating_usia' => '17+', 'poster_url' => 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => false],
            ['id' => 'film_7', 'judul' => 'Ejen Ali The Movie 2', 'genre' => 'Animation, Action', 'durasi' => 110, 'rating_usia' => 'SU', 'poster_url' => 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => false],
            ['id' => 'film_8', 'judul' => 'Final Destination: Bloodlines', 'genre' => 'Horror, Thriller', 'durasi' => 110, 'rating_usia' => '17+', 'poster_url' => 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => false],
        ];

        foreach ($films as $film) {
            Film::create($film);
        }

        // === SEED FILMS (SEGERA TAYANG) ===
        $segeraTayang = [
            ['id' => 'film_cs_1', 'judul' => 'Superman', 'genre' => 'Action, Superhero', 'durasi' => 150, 'rating_usia' => '13+', 'poster_url' => 'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => true],
            ['id' => 'film_cs_2', 'judul' => 'Jurassic World Rebirth', 'genre' => 'Action, Sci-Fi', 'durasi' => 140, 'rating_usia' => '13+', 'poster_url' => 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => true],
            ['id' => 'film_cs_3', 'judul' => 'Avatar 3: Fire and Ash', 'genre' => 'Action, Sci-Fi, Fantasy', 'durasi' => 180, 'rating_usia' => '13+', 'poster_url' => 'https://images.unsplash.com/photo-1533613220915-609f661697d4?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => true],
            ['id' => 'film_cs_4', 'judul' => 'The Fantastic Four: First Steps', 'genre' => 'Action, Superhero', 'durasi' => 135, 'rating_usia' => '13+', 'poster_url' => 'https://images.unsplash.com/photo-1626278664285-f796b9ee7806?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => true],
            ['id' => 'film_cs_5', 'judul' => 'How to Train Your Dragon', 'genre' => 'Animation, Fantasy', 'durasi' => 120, 'rating_usia' => 'SU', 'poster_url' => 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?q=80&w=600&auto=format&fit=crop', 'is_segera_tayang' => true],
        ];

        foreach ($segeraTayang as $film) {
            Film::create($film);
        }

        // === SEED STUDIOS ===
        $studios = [
            ['id' => 'studio_1', 'nama' => 'Studio 1', 'kapasitas' => 50, 'tipe_studio' => 'Regular'],
            ['id' => 'studio_2', 'nama' => 'Studio 2', 'kapasitas' => 60, 'tipe_studio' => 'Regular'],
            ['id' => 'studio_3', 'nama' => 'Studio 3', 'kapasitas' => 40, 'tipe_studio' => 'VIP'],
            ['id' => 'studio_4', 'nama' => 'Studio IMAX', 'kapasitas' => 80, 'tipe_studio' => 'IMAX'],
        ];

        foreach ($studios as $studio) {
            Studio::create($studio);
        }
    }
}
