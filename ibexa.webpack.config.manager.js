/**
 * Shim: re-export the config manager from @ibexa/frontend-config so that
 * vendor bundle encore configs (e.g. ibexa/fieldtype-richtext) can load it
 * via path.resolve('./ibexa.webpack.config.manager.js') from the project root.
 *
 * Background: the richtext encore config uses:
 *   require(path.resolve('./ibexa.webpack.config.manager.js'))
 * which is an absolute-path require to the project root. The actual
 * implementation is exported via the package exports map as:
 *   @ibexa/frontend-config/webpack-config/manager
 * but an absolute require bypasses the exports map lookup entirely.
 * This shim bridges the two.
 */
module.exports = require('@ibexa/frontend-config/webpack-config/manager');
