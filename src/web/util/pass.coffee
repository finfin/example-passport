passport = require("passport")
LocalStrategy = require("passport-local").Strategy
mongoose = require("mongoose")
User = mongoose.model('User')
passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  User.findById id, (err, user) ->
    done err, user


passport.use new LocalStrategy((username, password, done) ->
  User.findOne
    username: username
  , (err, user) ->
    return done(err)  if err
    unless user
      return done(null, false,
        message: "Invalid username or password"
      )
    user.comparePassword password, (err, isMatch) ->
      return done(err)  if err
      if isMatch
        done null, user
      else
        done null, false,
          message: "Invalid username or password"



)

# Simple route middleware to ensure user is authenticated.  Otherwise send to login page.
exports.ensureAuthenticated = ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  res.redirect "/logout"


# Check for admin middleware, this is unrelated to passport.js
# You can delete this if you use different method to check for admins or don't need admins
exports.ensureAdmin = ensureAdmin = (req, res, next) ->
  (req, res, next) ->
    console.log req.user
    if req.user and req.user.admin is true
      next()
    else
      res.send 403