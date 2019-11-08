#!/usr/bin/env node

// Node.js v8+ only

'use strict';

Error.stackTraceLimit = Infinity;
process.on('unhandledRejection', error => {
  throw error;
});

const path = require('path');
const spawn = require('child-process-ext/spawn');
const BbPromise = require('bluebird');
const fse = require('fs-extra');

BbPromise.promisifyAll(fse);

const serverlessPath = path.join(__dirname, '../..');
const spawnOptions = { cwd: serverlessPath, stdio: 'inherit' };

(async () => {
  // Ensure instance has means to recognize self as executable
  const pkgJsonPath = path.join(serverlessPath, 'package.json');
  const pkgJsonContent = await fse.readFileAsync(pkgJsonPath);
  const pkgJsonData = JSON.parse(pkgJsonContent);
  pkgJsonData.isExecutable = true;
  await fse.writeFileAsync(pkgJsonPath, JSON.stringify(pkgJsonData, null, 2));

  try {
    // To bundle npm with a binary we need to install it
    process.stdout.write('Install npm\n');
    // Hard code npm version to one that comes with lastest Node.js
    // It's due to fact that npm tends to issue buggy releases
    // Node.js confirms on given version before including it within its bundle
    // Version mappings reference: https://nodejs.org/en/download/releases/
    await spawn('npm', ['install', '--no-save', 'npm@6.12.0'], spawnOptions);

    process.stdout.write('Build binaries\n');
    await spawn(
      'node',
      [
        './node_modules/.bin/pkg',
        '-c',
        'scripts/pkg/config.js',
        '--targets',
        'node12-linux-x64,node12-mac-x64,node12-win-x64',
        '--out-path',
        'dist',
        'bin/serverless.js',
      ],
      spawnOptions
    );
  } finally {
    await BbPromise.all([
      fse.removeAsync(path.join(serverlessPath, 'node_modules/npm')),
      fse.writeFileAsync(pkgJsonPath, pkgJsonContent),
    ]);
  }
})();
