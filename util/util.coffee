log = require './log.coffee'

requiresLogin = (req,res,next) ->
	log.debug 'checking requiresLogin'
	if !req.session.user_name? or !req.session.user_github_token? or !req.session.username?
		log.debug "checking requiresLogin: user_name: #{req.session.user_name}, user_github_token: #{req.session.user_github_token}, username: #{req.session.username}"
		res.redirect '/'
	else
		log.debug "checking requiresLogin: user_name: #{req.session.user_name}"
		next()

module.exports.requiresLogin = requiresLogin