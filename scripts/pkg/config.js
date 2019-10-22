'use strict';

module.exports = {
  files: [
    // Service templates
    '../../lib/plugins/create/templates',
    // Ensure npm is bundled as a dependency
    '../../node_modules/npm/bin/npm-cli.js',
    // Below module is not automatically traced by pkg, we need to point it manually
    // See: https://github.com/npm/npm-lifecycle/pull/41
    '../../node_modules/node-gyp/bin/node-gyp.js',
    '../../node_modules/npm/node_modules/node-gyp/bin/node-gyp.js',
    '../../node_modules/npm/node_modules/npm-lifecycle/node_modules/node-gyp/bin/node-gyp.js',
  ],
};
