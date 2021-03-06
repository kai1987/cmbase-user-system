// Generated by CoffeeScript 1.8.0
(function() {
  var bodyParser, cookieParser, express, flash, helpers, methodOverride, mongoStore, path, session;

  express = require('express');

  flash = require('connect-flash');

  helpers = require('view-helpers');

  path = require("path");

  bodyParser = require('body-parser');

  methodOverride = require('method-override');

  cookieParser = require('cookie-parser');

  session = require('express-session');

  mongoStore = require('connect-mongo')(session);

  module.exports = function(app, config, passport) {
    var pathToView;
    app.set('showStackError', true);
    app.use(express["static"](config.root + '/public'));
    app.use(require('morgan')('tiny'));
    app.use(require('response-time')());
    pathToView = path.join(config.root, '/views');
    console.log("[express::main] pathToView:" + pathToView);
    app.set('views', config.root + '/views');
    app.set('view engine', 'jade');
    app.use(cookieParser());
    app.use(bodyParser.urlencoded({
      extended: false
    }));
    app.use(bodyParser.json());
    app.use(methodOverride());
    app.use(session({
      secret: 'noobjs',
      resave: false,
      saveUninitialized: true
    }));
    app.use(flash());
    app.use(helpers(config.app.name));
    app.use(passport.initialize());
    return app.use(passport.session());
  };

}).call(this);
