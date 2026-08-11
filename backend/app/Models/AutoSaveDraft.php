<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AutoSaveDraft extends Model
{
    use HasFactory;

    protected $fillable = [
        'form_key',
        'draft_data',
        'timestamp',
    ];

    protected $casts = [
        'draft_data' => 'array',
    ];
}
