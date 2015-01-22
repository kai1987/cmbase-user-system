# Module dependencies.

express = require('express')
flash = require('connect-flash')
helpers = require('view-helpers')
path = require "path"

bodyParser = require('body-parser')
methodOverride = require('method-override')
cookieParser = require('cookie-parser')
session = require 'express-session'

mongoStore = require('connect-mongo')(session)

module.exports = (app, config, passport)->

  app.set('showStackError', true)
  # should be placed before express.static
  #app.use(express.compress({
  #  filter: (req, res)-> return /json|text|javascript|css/.test(res.getHeader('Content-Type'))
  #  level: 9
  #}))
  #app.use(require('express-favicon')())
  app.use(express.static(config.root + '/public'))
  app.use(require('morgan')('tiny'))
  app.use(require('response-time')())

  # don't use logger for test env
  #if (process.env.NODE_ENV isnt 'test')
  #  app.use(express.logger('dev'))

  # set views path, template engine and default layout
  pathToView = path.join config.root, '/views'
  console.log "[express::main] pathToView:#{pathToView}"

  app.set('views', config.root + '/views')
  app.set('view engine', 'jade')


  # cookieParser should be above session
  app.use(cookieParser())

  # parse application/x-www-form-urlencoded
  app.use(bodyParser.urlencoded({ extended: false }))

  #// parse application/json
  app.use(bodyParser.json())

  app.use(methodOverride())

  # express/mongo session storage
  app.use(session({
    secret: 'noobjs',
    #store: new mongoStore({
    #  url: config.db,
    #  collection : 'sessions'
    #})
    resave: false,
    saveUninitialized: true
  }))

  # connect flash for flash messages
  app.use(flash())
  # dynamic helpers
  app.use(helpers(config.app.name))

  # use passport session
  app.use(passport.initialize())
  app.use(passport.session())

