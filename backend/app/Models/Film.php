<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Film extends Model
{
    use HasFactory;

    protected $fillable = [
        'id',
        'judul',
        'genre',
        'durasi',
        'rating_usia',
        'poster_url',
        'is_segera_tayang',
    ];

    public $incrementing = false;
    protected $keyType = 'string';
}
