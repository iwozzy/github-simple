log = require './log.coffee'

requiresLogin = (req,res,next) ->
	log.debug 'checking requiresLogin'
	if !req.session.user_name?
		log.debug 'checking requiresLogin: user_name not present'
		res.redirect '/'
	else
		log.debug "checking requiresLogin: user_name: #{req.session.user_name}"
		next()

module.exports.requiresLogin = requiresLogin