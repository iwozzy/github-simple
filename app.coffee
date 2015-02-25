express = require 'express'
github = require 'octonode'
cookieParser = require 'cookie-parser'
session = require 'express-session'
config = require './config.coffee'
FirebaseStore = require('connect-firebase')(session)

app = express()

#TODO set up authentication in Firebase

options =
	host: config.firebase.host

#TODO find out what the secret is

app.use session {
	store: new FirebaseStore options
	secret: '1234567890QWERTY'}

auth_url = github.auth.config(
	id: config.github.id
	secret: config.github.secret)
.login [
	'user'
	'repo'
]

#Store info to verify against CSRF

state = auth_url.match /&state=([0-9a-z]{32})/i

app.get '/', (req,res) ->
	res.send 'Hello World!'

#TODO clean up the routes for github oauth
#Put them in a separate routes file and use it for /auth/github routes
app.get '/login', (req,res) ->
	if req.session.github_token?
		res.redirect '/'
	else
		res.redirect auth_url

app.get '/auth', (req,res) ->
	values = req.query

	#Check against CSRF attacks
	if !state || state[1] != values.state
		console.log state[1]
		console.log values.state

		res.status 403
		.end()
	else
		github.auth.login values.code, (err,token) ->
			req.session.github_token = token
			res.status 200
			res.set 'Content-Type', 'text/plain'
			res.end token

server = app.listen config.expressPort, ->
	host = server.address().address
	port = server.address().port
	console.log "#{config.env}: app listening at http://#{host}:#{port}"

#References:
#http://blog.modulus.io/nodejs-and-express-sessions
#https://www.npmjs.com/package/connect-firebase