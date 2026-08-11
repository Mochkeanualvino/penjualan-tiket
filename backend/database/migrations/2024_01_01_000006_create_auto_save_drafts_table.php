<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('auto_save_drafts', function (Blueprint $table) {
            $table->id();
            $table->string('form_key')->unique();
            $table->json('draft_data');
            $table->string('timestamp')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('auto_save_drafts');
    }
};
