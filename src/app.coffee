
util				= require 'util'
fs 					= require 'fs'
express				= require 'express'

path				= require 'path'


passport			= require 'passport'
env					= process.env.NODE_ENV || 'development'
config				= require('../config/config')[env]
mongoose 			= require 'mongoose' 


# Database connect
db = config.DB
dbName = db.NAME
uristring = process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://localhost/#{dbName}"
mongoOptions = { db: { safe: true }}
mongoose.connect uristring, mongoOptions, (err, res) ->
  if err 
    console.log "ERROR connecting to: #{uristring}. #{err}"
  else
    console.log "Successfully connected to: #{uristring}"

#cleanup before exit
process.on 'exit', ->
	util.log "Closing DB..."
	mongoose.connection.close()

# Bootstrap models
models_path = "#{__dirname}/web/models"
fs.readdirSync(models_path).forEach (file) ->
  require "#{models_path}/#{file}"

#require passport config
pass				= require './web/util/pass'

# require controllers
views				= require './web/controllers/views'
user			= require './web/controllers/users'


process.on 'uncaughtException', (err) ->
	util.log err
	console.log err.stack

app					= express()

#WEB Server
app.set('views', "#{__dirname}/../views")
app.set('view engine', 'jade')
app.use(express.favicon())
app.use(express.logger())
app.use(express.cookieParser())
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.session({ secret: 'doveserver dev' }))
app.use(passport.initialize());
app.use(passport.session());
app.use(app.router)
app.use(express.static(path.join(__dirname, '..', 'public')))


#WEB Route
app.get('/', pass.ensureAuthenticated, views.index)
app.get('/login', user.getlogin)
app.post('/login', user.postlogin)
app.get('/logout', user.logout)
app.get('/admin/users', pass.ensureAuthenticated, pass.ensureAdmin(), user.listUser)
#app.post('/admin/users', user_routes.createUser)
app.get('/admin/users/:id', pass.ensureAuthenticated, pass.ensureAdmin(), user.editUser)

app.listen(config.WEB_PORT)