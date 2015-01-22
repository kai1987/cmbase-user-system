
# Module dependencies.

mongoose = require('mongoose')
User = mongoose.model('User')
Device= mongoose.model('Device')

exports.signin = (req, res)->

# Auth callback
exports.authCallback = (req, res, next)->
  res.redirect('/')
  return

# Show login form
exports.login = (req, res)->
  res.render 'users/login',
    title: 'Login',
    message: req.flash('error')
  return

# Show sign up form
exports.signup = (req, res)->
  res.render 'users/signup',
    title: 'Sign up',
    user: new User()
  return

# Logout
exports.logout = (req, res)->
  req.logout()
  res.redirect('/login')
  return

# Session
exports.session = (req, res)->
  res.redirect('/')
  return

# Create user
exports.create = (req, res, next)->

  console.log "[users::create] req.speak_as:#{req.speak_as}"

  newUser = new User(req.body)
  newUser.provider = 'local'

  newUser.save (err)->
    if err?
      if req.speak_as is "json"
        next(new EvalError(String(err)))
        #res.json
          #error: String(err)
          #success: false
      else
        res.render 'users/signup',
          errors: err.errors
          user:newUser
      return

    req.logIn newUser, (err)->
      return next err if err?

      if req.speak_as is "json"
        res.json
          id : newUser.id
          success: true
      else
        return res.redirect('/')

    return
  return

exports.changePassword = (req, res, next)->

  return next(new EvalError("missing user")) unless req.user?

  newPassword = String(req.body.new_password || "").trim()

  unless newPassword
    return next(new EvalError("无效的新密码，请重新选择密码"))

  req.user.set('password', newPassword)
  #req.user.isNew = true

  req.user.save (err)->
    return next(err) if err?
    res.json
      id : req.user.id
      success: true
    return

  return


#  Show profile
exports.show = (req, res)->
  User.findOne({ _id : req.params['userId'] }).exec (err, user)->
    return next(err) if err?
    return next(new Error('Failed to load User ' + id)) unless user?

    res.render 'users/show',
      title: user.username,
      user: user
    return
  return

# Find user by id
exports.user = (req, res, next, id)->
  User.findOne({ _id : id }).exec (err, user)->
    return next(err) if err?
    return next(new Error('Failed to load User ' + id)) unless user?
    req.profile = user
    next()
    return
  return

##udid登录，如果是具名用户，返回客户端让客户端登录
exports.udidlogin=(req,res,next)->
  user = req.user
  unless user?
    res.json
      success:false
      errors:"Unknown error,why user is null"
    return
  unless user.anonymous
    res.json
      success:false
      errors:"unanonymous"
      username:user.username
    return
  res.json
    id:user.id
    success:true
  return

##udid将匿名用户注册
exports.udidbind = (req,res,next)->
  {username,password} = req.body
  user = req.user
  unless user?
    res.json
      success:false
      errors:"Unknown error,why user is null"
    return
  #已经绑定到用户了,返回使用账号登录
  unless user.anonymous
    res.json
      success:false
      errors:"unanonymous"
      username:user.username
    return

  user.username=username
  user.password=password
  user.anonymous=false
  user.save (err)->
    if err?
      res.json
        success:false
        errors:err
      return
    res.json
      success:true
  return

exports.passwordLogin=(req,res,next)->
  {client_id} = req.body
  user = req.user
  #茂名用户不能登录，以防万一。
  if user.anonymous
    res.json
      success:false
      errors:'this is anonymous user'
    return
  res.json({id:req.user.id, success:true})
  #device绑定不是必须的
  if client_id?
    Device.findOne {udid:client_id},(err,device)->
      return if err
      return if device and device.user_id is user.id
      if device?
        device.user_id = user.id
        device.save()
        return
      device = new Device({udid:client_id,user_id:user.id})
      device.save()
  return


