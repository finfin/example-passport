fs 				= require 'fs'
mongoose		= require 'mongoose' 
{print} 		= require 'util'
{spawn, exec} 	= require 'child_process'
async 			= require 'async'
require './src/web/models/user'
User = mongoose.model('User')
init 			= require './config/init'
env 			= process.env.NODE_ENV || 'development'
config 			= require('./config/config')[env]

bold = `'\033[0;1m'`
green = `'\033[0;32m'`
reset = `'\033[0m'`
red = `'\033[0;31m'`

log = (message, color, explanation) -> console.log color + message + reset + ' ' + (explanation or '')

launch = (cmd, options=[], callback) ->
	app = spawn cmd, options
	app.stdout.pipe(process.stdout)
	app.stderr.pipe(process.stderr)
	app.on 'exit', (status) -> callback?() if status is 0

build = (watch, callback) ->
	if typeof watch is 'function'
		callback = watch
		watch = false
	log "Compiling coffeescript files...", green
	options = ['-c', '-b', '-o', 'lib', 'src']
	options.unshift '-w' if watch
	launch 'coffee', options, callback

createUser = (user, callback) ->
#createUser = (parentobj, user, emailaddress, pass, adm) ->
	userModel = new User(
		username: user.username
		email: user.email
		password: user.password
		admin: user.admin
		)
	userModel.save (err) ->
		if err
			callback err
		else
			log "Saved user: #{user.username}", green
			callback null

seed = () ->
	db_connect()
	log "Initialize mongodb data from config/init", green
	async.each init.users, createUser, db_callback
		

drop = () ->
	db_connect()
	
	mongoose.connection.db.dropDatabase db_callback
	
db_connect = () ->
	db = config.DB
	uristring = process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://#{db.HOST}/#{db.NAME}"
	mongoOptions = { db: { safe: true }}
	mongoose.connect uristring, mongoOptions, (err, res) ->
		if err 
			log "ERROR connecting to: #{uristring}. #{err}", red
		else
			log "Successfully connected to: #{uristring}", green

db_callback = (err) ->
	if err
		log err, red
	else
		log "Database operation successfully finished, closing connection.", green
	mongoose.connection.close()
	
task 'build', 'compile source', -> build  -> log "Build completed.", green
task 'watch', 'compile and watch', -> build true,  -> log "Build completed. Watch flag on...", green
task 'seed', 'Seed MongoDB with initial user data', -> build -> seed()
task 'drop', 'Drop all MongoDB data', -> build -> drop()

option '-n', '--name [USERNAME]', 'username for newly created user'
option '-p', '--pass [PASSWORD]', 'password for newly created user'
option '-e', '--email [EAIL]', 'email for newly created user'
task 'adduser', 'Create user', (options) ->
	
	if options.name? && options.pass?
		name = options.name
		pass = options.pass
	else
		console.log "Username/password must be provided(-n, -p), task aborted."
		return

	adm = options.adm or false
	email = options.email or ""
	async.parallel
		create: (callback) ->
			createUser callback, name, email, pass, adm
	, (err, results) ->
		if err
			log err, red
		else
			log "Successfully created user #{name}", green
		finish()



