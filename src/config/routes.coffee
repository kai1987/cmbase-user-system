
async = require "async"
express = require 'express'
module.exports = (app, passport, auth)->

  # user routes
  users = require "../controllers/users"
  router = express.Router()
  router.get '/login', users.login
  router.get '/signup', users.signup
  router.get '/logout', users.logout
  router.post '/users', users.create
  router.post '/api/signup', ((req, res, next)-> (req.speak_as = "json") && next()), users.create

  router.post '/users/session', passport.authenticate('local', {failureRedirect: '/login', failureFlash: '无效的用户名或者密码.'}), users.session
  router.post '/api/login', passport.authenticate('local', { session: false }), (req, res)-> res.json({id:req.user.id, success:true})

  router.post '/api/change_password', passport.authenticate('local', { session: false }), ((req, res, next)-> (req.speak_as = "json") && next()), users.changePassword

  router.get '/users/:userId', users.show

  # this is home page
  home = require "../controllers/home"
  router.get '/', home.index

  app.use router


  # routes should be at the last
  # assume "not found" in the error msgs
  # is a 404. this is somewhat silly, but
  # valid, you can do whatever you like, set
  # properties, use instanceof etc.
  app.use (err, req, res, next)->
    # treat as 404
    return next() if (~err.message.indexOf('not found'))

    # log it
    console.error(err.stack)

    # treat eval error as a json format error output
    if err.name is 'EvalError'
      return res.json
        error : err.toString()
        success : false

    # error page
    res.status(500).render('500', { error: err.stack })

  # assume 404 since no middleware responded
  app.use (req, res, next)->
    res.status(404).render('404', { url: req.originalUrl, error: 'Not found' })

