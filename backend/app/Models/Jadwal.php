<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Jadwal extends Model
{
    use HasFactory;

    protected $table = 'jadwals';

    protected $fillable = [
        'id',
        'film_id',
        'studio_id',
        'tanggal',
        'jam_tayang',
        'harga',
    ];

    public $incrementing = false;
    protected $keyType = 'string';

    public function film()
    {
        return $this->belongsTo(Film::class, 'film_id');
    }

    public function studio()
    {
        return $this->belongsTo(Studio::class, 'studio_id');
    }
}
