passport	= require 'passport'
helper		= require '../util/helper'
mongoose	= require 'mongoose'
util		= require 'util'
User = mongoose.model('User')

exports.getlogin = (req, res) ->
	res.render "login", 
		title: "Login Page"
		user: req.user
		message: req.session.messages


exports.admin = (req, res) ->
	res.send "access granted admin!"


# POST /login
#   Use passport.authenticate() as route middleware to authenticate the
#   request.  If authentication fails, the user will be redirected back to the
#   login page.  Otherwise, the primary route function function will be called,
#   which, in this example, will redirect the user to the home page.
#
#   curl -v -d "username=bob&password=secret" http://127.0.0.1:3000/login
#   
###
This version has a problem with flash messages
app.post('/login',
passport.authenticate('local', { failureRedirect: '/login', failureFlash: true }),
function(req, res) {
res.redirect('/');
});
###

# POST /login
#   This is an alternative implementation that uses a custom callback to
#   acheive the same functionality.
exports.postlogin = (req, res, next) ->
	passport.authenticate("local", (err, user, info) ->
		return next(err)  if err
		unless user
			req.session.messages = [info.message]
			return res.redirect("/login")
		req.logIn user, (err) ->
			return next(err)  if err
			res.redirect "/"

	) req, res, next

exports.logout = (req, res) ->
	req.logout()
	res.redirect "/login"

exports.listUser = (req, res) ->
	util.log helper.parseProjection(req.query)
	User.find {}, null, helper.parseProjection(req.query), (err, items) ->
		res.render "user/list_user", 
			title: "User List"
			login_user: req.user
			users: items

exports.editUser = (req, res) ->
	userID = req.params.id
	User.findById userID, (err, user) ->
		res.render "user/edit_user", 
			title: "編輯使用者"
			login_user: req.user
			user: user