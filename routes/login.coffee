express = require 'express'
github = require 'octonode'
Firebase = require 'firebase'
log = require '../util/log.coffee'

config = require '../config.coffee'

router = express.Router()


#---------------------------------------
#				FIREBASE
#---------------------------------------


firebase = new Firebase "https://blazing-fire-93.firebaseio.com"
.authWithCustomToken config.firebase.secret, (error, authData) ->
	if error?
		log.error error
	else
		log.info "Authenticated with payload: ", authData


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
	log.debug 'at /login'
	if req.session.user_name?
		log.debug "at /login: user_name: #{req.session.user_name} -> redirecting to /dashboard"
		res.redirect '/dashboard'
	else
		log.debug 'at /login: user_name is not present -> redirecting to /auth_url'
		res.redirect auth_url

router.get '/auth', (req,res) ->
	log.debug 'at /login/auth'
	values = req.query

	#Check against CSRF attacks
	if !state || state[1] != values.state
		log.info state[1]
		log.info values.state

		res.status 403
		.end()
	else
		github.auth.login values.code, (err,token) ->

			# github_token = token
			# req.session.user = github_token

			client = github.client token
			ghme = client.me()
			ghme.info (err, data, headers) ->
				req.session.user_github_token = token
				req.session.user_name = data.name
				req.session.username = data.login

				log.debug "at /login/auth: token: #{req.session.user_github_token}"
				log.debug "at /login/auth: user name: #{req.session.user_name}"
				log.debug "redirecting to /dashboard"

				res.redirect '/dashboard'

module.exports = router