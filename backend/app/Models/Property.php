<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Property extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'title',
        'description',
        'price',
        'area',
        'bedrooms',
        'bathrooms',
        'city',
        'address',
        'latitude',
        'longitude',
        'status',
        'is_featured',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'area' => 'decimal:2',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'is_featured' => 'boolean',
        ];
    }

    public function images(): HasMany
    {
        return $this->hasMany(PropertyImage::class);
    }

    public function coverImage(): HasOne
    {
        return $this->hasOne(PropertyImage::class)->where('is_cover', true);
    }

    public function favourites(): HasMany
    {
        return $this->hasMany(Favourite::class);
    }

    public function favouritedByUsers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'favourites')
            ->withTimestamps();
    }
}
