<?php

use Illuminate\Support\Facades\Artisan;

Artisan::command('about-portfolio', function () {
    $this->info('Ven Andrew B. Mirasol portfolio powered by Laravel, React, and Vite.');
});
