#!/usr/bin/env node
import { existsSync } from 'fs';
import { execSync } from 'child_process';
import { join } from 'path';

// Check if node_modules exists and has the critical dependency
const nodeModulesExists = existsSync('node_modules');
const concurrentlyExists = existsSync(join('node_modules', '.bin', 'concurrently'));

if (!nodeModulesExists || !concurrentlyExists) {
  console.log('📦 Dependencies not found. Installing...');
  try {
    execSync('npm install', { stdio: 'inherit' });
  } catch (error) {
    console.error('❌ Failed to install dependencies.');
    console.error('Please run "npm install" manually to resolve the issue.');
    process.exit(1);
  }
}
