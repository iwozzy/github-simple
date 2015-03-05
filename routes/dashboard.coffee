express = require 'express'
log = require '../util/log.coffee'
util = require '../util/util.coffee'

router = express.Router()

#---------------------------------------
#				DASHBOARD
#
#		routes have the /dashboard base
#---------------------------------------

router.get '/', util.requiresLogin, (req,res) ->
	log.debug 'at /dashboard'
	log.debug "at /dashboard: user_name: #{req.session.user_name}"

	res.render 'dashboard',
		name: req.session.user_name

module.exports = router