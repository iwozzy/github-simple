express = require 'express'
github = require 'octonode'
Firebase = require 'firebase'

config = require '../config.coffee'

router = express.Router()


#---------------------------------------
#				FIREBASE
#---------------------------------------


firebase = new Firebase "https://blazing-fire-93.firebaseio.com"
.authWithCustomToken config.firebase.secret, (error, authData) ->
	if error?
		console.log error
	else
		console.log "Authenticated with payload: ", authData


#---------------------------------------
#				GITHUB
#---------------------------------------


auth_url = github.auth.config(
	id: config.github.id
	secret: config.github.secret)
.login [
	'user'
	'repo'
]


#---------------------------------------
#				OAUTH FLOW
#
#		routes have the /login base
#---------------------------------------


#Store info to verify against CSRF
state = auth_url.match /&state=([0-9a-z]{32})/i

router.get '/', (req,res) ->
	console.log '----------------------------at /login'
	#console.log req.session
	#console.log req.session.user_name
	if typeof req.session.user_name isnt "undefined"
		console.log '----------------------------at /login user_name is present...redirecting to dashboard'
		res.redirect '/dashboard'
	else
		console.log '----------------------------at /login user_name is NOT present...redirecting to auth_url'
		res.redirect auth_url

router.get '/auth', (req,res) ->
	console.log '----------------------------at /login/auth'
	values = req.query

	#Check against CSRF attacks
	if !state || state[1] != values.state
		console.log state[1]
		console.log values.state

		res.status 403
		.end()
	else
		github.auth.login values.code, (err,token) ->

			# github_token = token
			# req.session.user = github_token

			client = github.client token
			ghme = client.me()
			ghme.info (err, data, headers) ->
				#console.log data
				req.session.user_github_token = token
				req.session.user_name = data.name
				console.log '----------------------------at /login/auth the value of token: ' + req.session.user_github_token
				console.log '----------------------------at /login/auth the value of user name' + req.session.user_name
				#console.log req.session.user_name
				res.redirect '/login'

			# firebaseUsers = firebase.child('users')

			# client = github.client token
			# ghme = client.me()
			# ghme.info (err, data, headers) ->
			# 	firebaseUsers.child "#{data.login}"
			# 	.set
			# 		github:
			# 			token: token
			# 		name: data.name


module.exports = router