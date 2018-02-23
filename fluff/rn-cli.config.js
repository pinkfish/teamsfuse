const blacklist = require('metro-bundler').createBlacklist;

module.exports = {
  getBlacklistRE: function() {
    return blacklist([/dist\/.*/]);
  }
};
