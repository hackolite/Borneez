#!/usr/bin/env node
import { existsSync } from 'fs';
import { execSync } from 'child_process';

// Check if node_modules exists
if (!existsSync('node_modules')) {
  console.log('📦 Dependencies not found. Installing...');
  execSync('npm install', { stdio: 'inherit' });
}
