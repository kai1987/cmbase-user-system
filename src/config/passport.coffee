
mongoose = require('mongoose')
LocalStrategy = require('passport-local').Strategy
PublicClientStrategy = require('passport-oauth2-public-client').Strategy

User = mongoose.model('User')


module.exports = (passport, config)->
  # require('./initializer')

  # serialize sessions
  passport.serializeUser (user, done)-> done(null, user.id)

  passport.deserializeUser (id, done)->
    User.findOne({ _id: id }, (err, user)-> done(err, user))

  # use local strategy
  localStrategyConfig =
    usernameField: 'username',
    passwordField: 'password'

  localStrategyCallback = (username, password, done)->
    #console.log "passport:localStrategyCallback:username:#{username},password:#{password}"
    User.findOne { username: username}, (err, user)->
      return done(err) if (err)
      return done(null, false, { message: 'Unknown user' }) unless user
      return done(null, false, { message: 'Invalid password' }) unless user.authenticate(password)
      return done(null, user)
    return

  passport.use new LocalStrategy localStrategyConfig, localStrategyCallback


  publicClientStrategyCallback = (udid,done)->
    #console.log "passport:publicClientStrategyCallback:udid:#{udid}"
    User.findOrCreateByUdid udid,(err,user)->
      return done(err) if err
      return done(null,false,{message:'Unknown user'}) unless user
      return done(null,user)
    return

  passport.use new PublicClientStrategy(publicClientStrategyCallback)


