express = require 'express'
cookieParser = require 'cookie-parser'
session = require 'express-session'
FirebaseStore = require('connect-firebase')(session)

main = require './routes/main.coffee'
login = require './routes/login.coffee'
github = require './routes/github.coffee'

config = require './config.coffee'


#---------------------------------------
#				APP
#---------------------------------------


app = express()
app.set 'view engine', 'jade'
app.set 'json spaces', 2

#TODO find out what the secret is

app.use express cookieParser()

app.use session
	store: new FirebaseStore
		host: config.firebase.host
		token: config.firebase.secret
	secret: '1234567890QWERTY'


#---------------------------------------
#				ROUTES
#---------------------------------------


app.use '/', main
app.use '/login', login
app.use '/github', github


#---------------------------------------
#				SERVER
#---------------------------------------


server = app.listen config.expressPort, ->
	host = server.address().address
	port = server.address().port
	console.log "#{config.env}: app listening at http://#{host}:#{port}"


#---------------------------------------
#				REF
#---------------------------------------

#http://blog.modulus.io/nodejs-and-express-sessions
#https://www.npmjs.com/package/connect-firebase