<?php

use App\Http\Controllers\API\AdminController;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\ConversationController;
use App\Http\Controllers\API\FavouriteController;
use App\Http\Controllers\API\MessageController;
use App\Http\Controllers\API\PropertyController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Property routes
Route::get('/properties', [PropertyController::class, 'index']);
Route::get('/properties/search', [PropertyController::class, 'search']);
Route::get('/properties/{property}', [PropertyController::class, 'show']);

// Admin-only property routes
Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::post('/properties', [PropertyController::class, 'store']);
    Route::put('/properties/{property}', [PropertyController::class, 'update']);
    Route::delete('/properties/{property}', [PropertyController::class, 'destroy']);
});

// Favourite routes (authenticated users only)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/favourites/{property}', [FavouriteController::class, 'toggle']);
    Route::get('/favourites', [FavouriteController::class, 'index']);
});

// Conversation routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/conversations', [ConversationController::class, 'index']);
    Route::get('/conversations/{conversation}/messages', [MessageController::class, 'index']);
    Route::post('/conversations/{conversation}/messages', [MessageController::class, 'store']);
});

// Admin-only routes
Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard']);
    Route::get('/admin/conversations', [ConversationController::class, 'adminIndex']);
    Route::get('/admin/users', [AdminController::class, 'users']);
    Route::post('/admin/users/{user}/block', [AdminController::class, 'toggleBlock']);
});

// Pusher broadcasting authentication
Broadcast::routes(['middleware' => ['auth:sanctum']]);
