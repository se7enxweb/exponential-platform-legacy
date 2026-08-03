const fs = require('fs');
const path = require('path');
const Encore = require('@symfony/webpack-encore');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const getWebpackConfigs = require('@ibexa/frontend-config/webpack-config/get-configs');
const getIbexaConfig = require('@ibexa/frontend-config/webpack-config/ibexa');
const customConfigsPaths = require('./var/encore/ibexa.webpack.custom.config.js');

/**
 * Dart Sass 1.x modern API with loadPaths lets us resolve
 * `@import './public/bundles/...'` paths relative to the project root while
 * avoiding the legacy JS API deprecation warning. We also silence the
 * `slash-div` deprecation that comes from upstream vendor SCSS, because
 * `netgen/ibexa-fieldtype-enhanced-link` still uses `/` for division.
 */
function patchSassLoaderForModernBuild(configs) {
    const projectRoot = __dirname;

    function patchLoaderList(useArray) {
        if (!Array.isArray(useArray)) return;
        useArray.forEach((loaderEntry) => {
            if (!loaderEntry || typeof loaderEntry !== 'object') return;
            const loaderName = loaderEntry.loader || '';
            if (!loaderName.includes('sass-loader')) return;
            loaderEntry.options = loaderEntry.options || {};
            loaderEntry.options.api = 'modern';
            loaderEntry.options.sassOptions = Object.assign(
                {},
                loaderEntry.options.sassOptions || {},
                {
                    loadPaths: [projectRoot],
                    silenceDeprecations: ['slash-div'],
                }
            );
        });
    }

    function patchRule(rule) {
        if (!rule) return;
        // Direct use array
        patchLoaderList(rule.use);
        // oneOf sub-rules
        if (Array.isArray(rule.oneOf)) {
            rule.oneOf.forEach(patchRule);
        }
    }

    configs.forEach((config) => {
        if (!config || !config.module || !Array.isArray(config.module.rules)) return;
        config.module.rules.forEach(patchRule);
    });
    return configs;
}

/**
 * The default cssnano/svgo minimizer chokes on URL-encoded inline SVG data
 * URLs (e.g. `%3csvg ...`) and prints `SvgoParserError` warnings. We disable
 * the svgo optimisation in the CSS minimiser for every build config.
 */
function patchCssMinimizer(configs) {
    configs.forEach((config) => {
        if (!config || !config.optimization || !Array.isArray(config.optimization.minimizer)) return;
        config.optimization.minimizer = config.optimization.minimizer.map((plugin) => {
            if (plugin && plugin.constructor && plugin.constructor.name === 'CssMinimizerPlugin') {
                return new CssMinimizerPlugin({
                    minimizerOptions: {
                        preset: ['default', { svgo: false }],
                    },
                });
            }
            return plugin;
        });
    });
    return configs;
}

const customConfigs = patchCssMinimizer(
    patchSassLoaderForModernBuild(
        getWebpackConfigs(Encore, customConfigsPaths)
    )
);

/**
 * ibexa/fieldtype-richtext's encore config sets the webpack alias:
 *   '@ibexa-admin-ui' -> './vendor/ibexa/admin-ui'
 * but this project uses se7enxweb/admin-ui which replaces ibexa/admin-ui.
 * Override the alias on every custom config so richtext JS sources resolve.
 */
customConfigs.forEach((config) => {
    if (config && config.resolve && config.resolve.alias) {
        config.resolve.alias['@ibexa-admin-ui'] = path.resolve(__dirname, 'vendor/se7enxweb/admin-ui');
    }
});

const isReactBlockPathCreated = fs.existsSync('./assets/page-builder/react/blocks');

Encore.reset();
Encore
    .setOutputPath('public/build/')
    .setPublicPath('/build')
    .enableSassLoader()
    .enableStimulusBridge('./assets/controllers.json')
    .enableReactPreset((options) => {
        options.runtime = 'classic';
    })
    .enableSingleRuntimeChunk()
    .copyFiles({
        from: './assets/images',
        to: 'images/[path][name].[ext]',
        pattern: /\.(png|svg)$/,
    })
    .configureBabelPresetEnv((config) => {
        config.useBuiltIns = 'usage';
        config.corejs = 3;
    });

// Welcome page stylesheets
Encore.addEntry('welcome-page-css', [
    path.resolve(__dirname, './assets/scss/welcome-page.scss'),
]);

// Welcome page javascripts
Encore.addEntry('welcome-page-js', [
    path.resolve(__dirname, './assets/js/welcome.page.js'),
]);

if (isReactBlockPathCreated) {
    // React Blocks javascript
    Encore.addEntry('react-blocks-js', './assets/js/react.blocks.js');
}

Encore.addEntry('app', './assets/app.js');

const projectConfig = Encore.getWebpackConfig();

projectConfig.name = 'app';

/**
 * The admin UI layout.html.twig uses encore_entry_script_tags(..., null, 'ibexa')
 * which requires public/assets/ibexa/build/entrypoints.json.
 * getIbexaConfig() reads var/encore/ibexa.config.js (populated by assets:install)
 * and outputs to public/assets/ibexa/build/. We apply the alias fix inside the
 * modifyEncoreConfig callback so richtext-style @ibexa-admin-ui imports resolve
 * to our se7enxweb/admin-ui fork instead of the missing ibexa/admin-ui path.
 */
Encore.reset();
const ibexaConfig = getIbexaConfig((Encore) => {
    Encore.addAliases({
        '@ibexa-admin-ui': path.resolve(__dirname, 'vendor/se7enxweb/admin-ui'),
        '@ibexa-admin-ui-modules': path.resolve(__dirname, 'vendor/se7enxweb/admin-ui/src/bundle/ui-dev/src/modules'),
    });
});
patchCssMinimizer(patchSassLoaderForModernBuild([ibexaConfig]));

const libsConfigsPaths = require('./var/encore/ibexa.webpack.libs.config.js');
const libsConfigs = getWebpackConfigs(Encore, libsConfigsPaths);

const richtextConfigsPaths = require('./var/encore/ibexa.webpack.richtext.config.js');
const richtextConfigs = getWebpackConfigs(Encore, richtextConfigsPaths);
richtextConfigs.forEach((config) => {
    if (config && config.resolve && config.resolve.alias) {
        config.resolve.alias['@ibexa-admin-ui'] = path.resolve(__dirname, 'vendor/se7enxweb/admin-ui');
    }
});

const allConfigs = [ibexaConfig, ...libsConfigs, ...richtextConfigs, ...customConfigs, projectConfig];
patchCssMinimizer(patchSassLoaderForModernBuild(allConfigs));

module.exports = allConfigs;
