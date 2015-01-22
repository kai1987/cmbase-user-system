
# Module dependencies.

mongoose = require('mongoose')
Schema = mongoose.Schema
timestamps = require "mongoose-times"
crypto = require('crypto')
_ = require('underscore')
authTypes = ['github', 'twitter', 'facebook', 'google']
shortid = require 'shortid'
# User Schema

UserSchema = new Schema({
  username:
    type:String
  provider: String,
  hashed_password: String,
  salt: String,
  anonymous:
    type:Boolean
    default:false
})

# Virtuals

UserSchema
  .virtual('password')
  .set( (password)->
    #console.log "[user::set password] password:#{password}"

    @_password = password
    @salt = @makeSalt()
    @hashed_password = @encryptPassword(password)
  )
  .get( ()-> return this._password )

UserSchema.statics=
  findOrCreateByUdid:(udid,callback)->

    Device = mongoose.model 'Device'
    User= mongoose.model 'User'

    Device.findOne {udid:udid},(err,dvc)->
      return callback err if err
      if dvc?
        User.findById dvc.user_id,(err,user)->
          if user?
            user.device = dvc
          callback err,user
      else
        userObj =
          username:"anonymous_#{shortid.generate()}"
          anonymous:true
          password:shortid.generate()
          provider:'local'
        user = new User(userObj)
        user.save (err)->
          if err?
            console.error "[user:findOrCreateByUdid:save user error:#{err}"
            callback err
            return
          dvc = new Device
            udid:udid
            user_id:user.id
          dvc.save (err)->
            if err?
              console.error "[user:findOrCreateByUdid:save device error:#{err}"
              callback err
              return
            user.device = dvc
            callback null,user
    return


UserSchema.plugin timestamps,
  created: "created_at"
  lastUpdated: "updated_at"
# Validations

DeviceSchema = new Schema
  udid:
    type:String
    unique:true
    validate : [
      { validator: ((val) -> val.length >= 10),  msg: "{PATH} is too short."},
      { validator: ((val) -> val.length <= 64),  msg: "{PATH} is too long."}
    ]

  user_id:{type:String,ref:'User'}

DeviceSchema.plugin timestamps,
  created: "created_at"
  lastUpdated: "updated_at"

validatePresenceOf = (value)->
  return value && value.length

# the below 4 validations only apply if you are signing up traditionally

#UserSchema.path('name').validate (name)->
  ## if you are authenticating by any of the oauth strategies, don't validate
  #return true if authTypes.indexOf(this.provider) isnt -1
  #return name.length
#, 'Name cannot be blank'

#UserSchema.path('email').validate (email)->
  ## if you are authenticating by any of the oauth strategies, don't validate
  #return true if authTypes.indexOf(this.provider) isnt -1
  #return email.length
#, 'Email cannot be blank'

UserSchema.path('username').validate (username)->
  # if you are authenticating by any of the oauth strategies, don't validate
  return true if authTypes.indexOf(this.provider) isnt -1
  return username.length
, 'Username cannot be blank'

UserSchema.path('hashed_password').validate (hashed_password)->
  # if you are authenticating by any of the oauth strategies, don't validate
  return true if authTypes.indexOf(this.provider) isnt -1
  return hashed_password.length
, 'Password cannot be blank'


# Pre-save hook
UserSchema.pre 'save', (next)->
  console.log "[user::pre save] @isNew:#{@isNew}"

  return next() if (!@isNew)

  if not validatePresenceOf(@password) and authTypes.indexOf(this.provider) is -1
    return next(new Error('Invalid password'))

  User = mongoose.model('User')
  User.findOne {username:@username} ,(err,user)->
    return next(err) if err
    return next(new Error('用户名已存在')) if user?

  next()

# Methods

UserSchema.methods =

  # Authenticate - check if the passwords are the same
  #
  # @param {String} plainText
  # @return {Boolean}
  # @api public
  authenticate: (plainText)-> return @encryptPassword(plainText) is @hashed_password

  # Make salt
  #
  # @return {String}
  # @api public
  makeSalt: ()-> return Math.round((new Date().valueOf() * Math.random())) + ''

  # Encrypt password
  #
  # @param {String} password
  # @return {String}
  # @api public
  encryptPassword: (password)->
    return '' unless password
    return crypto.createHmac('sha1', @salt).update(password).digest('hex')


mongoose.model('User', UserSchema)
mongoose.model('Device', DeviceSchema)



