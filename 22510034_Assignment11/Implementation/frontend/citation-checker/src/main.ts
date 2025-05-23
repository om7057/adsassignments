import { bootstrapApplication } from '@angular/platform-browser';
import { enableProdMode } from '@angular/core';
import { AppComponent } from './app/app.component';
import { environment } from './environments/environment'; // <-- Add this import

if (environment.production) {
  enableProdMode();
}

bootstrapApplication(AppComponent)
  .catch((err) => console.error(err));
