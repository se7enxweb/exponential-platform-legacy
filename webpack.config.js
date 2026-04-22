const Encore = require('@symfony/webpack-encore');
const path = require('path');
const getEzConfig = require('./ez.webpack.config.js');
const eZConfigManager = require('./ez.webpack.config.manager.js');

Encore.configureRuntimeEnvironment(process.env.NODE_ENV || 'dev')

const eZConfig = getEzConfig(Encore);
const customConfigs = require('./ez.webpack.custom.configs.js');

Encore.reset();
Encore
    .setOutputPath('web/assets/app')
    .setPublicPath('/assets/app')
    .enableSassLoader()
    .enableReactPreset()
    .enableSingleRuntimeChunk()
    .enableVersioning()
    .configureCssLoader(function(config) {
        config.url = false;
    })
    .addStyleEntry('index', './assets/scss/index.scss');

const projectConfig = Encore.getWebpackConfig();
projectConfig.name = 'app';

module.exports = [ eZConfig, ...customConfigs, projectConfig ];
