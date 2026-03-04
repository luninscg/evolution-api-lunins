#!/usr/bin/env node
/**
 * Build com env vars para Hostinger (MySQL).
 * Se DATABASE_PROVIDER não estiver definido, usa 'mysql' por padrão.
 */
require('dotenv').config();

if (!process.env.DATABASE_PROVIDER) {
  process.env.DATABASE_PROVIDER = 'mysql';
  console.log('DATABASE_PROVIDER não definido, usando: mysql (Hostinger)');
}

const { execSync } = require('child_process');

const steps = [
  'npm run db:generate',
  'npx tsc --noEmit',
  'npx tsup',
];

for (const cmd of steps) {
  execSync(cmd, { stdio: 'inherit', env: process.env });
}
