<?php

namespace Database\Factories;

use App\Models\Property;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Carbon;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Property>
 */
class PropertyFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var class-string<\App\Models\Property>
     */
    protected $model = Property::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $locations = [
            ['city' => 'New York', 'state' => 'NY', 'latitude' => 40.7128, 'longitude' => -74.0060],
            ['city' => 'Los Angeles', 'state' => 'CA', 'latitude' => 34.0522, 'longitude' => -118.2437],
            ['city' => 'Chicago', 'state' => 'IL', 'latitude' => 41.8781, 'longitude' => -87.6298],
            ['city' => 'Houston', 'state' => 'TX', 'latitude' => 29.7604, 'longitude' => -95.3698],
            ['city' => 'Phoenix', 'state' => 'AZ', 'latitude' => 33.4484, 'longitude' => -112.0740],
            ['city' => 'Miami', 'state' => 'FL', 'latitude' => 25.7617, 'longitude' => -80.1918],
            ['city' => 'Seattle', 'state' => 'WA', 'latitude' => 47.6062, 'longitude' => -122.3321],
            ['city' => 'Denver', 'state' => 'CO', 'latitude' => 39.7392, 'longitude' => -104.9903],
            ['city' => 'Atlanta', 'state' => 'GA', 'latitude' => 33.7490, 'longitude' => -84.3880],
            ['city' => 'Boston', 'state' => 'MA', 'latitude' => 42.3601, 'longitude' => -71.0589],
        ];

        $location = fake()->randomElement($locations);
        $bedrooms = fake()->numberBetween(1, 6);
        $price = fake()->numberBetween(50000, 2000000);

        return [
            'title' => fake()->randomElement([
                'Modern Family Home',
                'Spacious Urban Apartment',
                'Luxury Suburban Villa',
                'Contemporary Downtown Condo',
                'Elegant Garden House',
                'Bright Corner Townhouse',
                'Quiet Residential Retreat',
                'Premium City Residence',
            ]),
            'description' => fake()->paragraph(3),
            'price' => $price,
            'area' => fake()->randomFloat(2, 550, 6500),
            'bedrooms' => $bedrooms,
            'bathrooms' => min($bedrooms + fake()->numberBetween(0, 2), 6),
            'city' => $location['city'],
            'address' => fake()->streetAddress() . ', ' . $location['city'] . ', ' . $location['state'],
            'latitude' => fake()->randomFloat(7, $location['latitude'] - 0.05, $location['latitude'] + 0.05),
            'longitude' => fake()->randomFloat(7, $location['longitude'] - 0.05, $location['longitude'] + 0.05),
            'status' => 'available',
            'is_featured' => fake()->boolean(20),
            'created_at' => Carbon::now()->subDays(fake()->numberBetween(1, 180)),
            'updated_at' => Carbon::now(),
        ];
    }
}
