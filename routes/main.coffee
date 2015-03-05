express = require 'express'
log = require '../util/log.coffee'

router = express.Router()

router.get '/', (req,res) ->
	res.render 'index',
		message: "This is the landing page."

router.get '/logout', (req,res) ->
	log.debug 'at /logout -> redirecting to /'
	req.session.destroy()
	res.redirect '/'

module.exports = router