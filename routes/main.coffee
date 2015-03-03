express = require 'express'

router = express.Router()

requiresLogin = (req,res,next) ->
	console.log '----------------------------checking requiresLogin'
	if !req.session.user_name?
		console.log '----------------------------checking requiresLogin: user name not present'
		res.redirect '/'
	else
		console.log '----------------------------checking requiresLogin: user name found'
		next()

router.get '/', (req,res) ->
	res.render 'index',
		message: "This is the landing page."

router.get '/dashboard', requiresLogin, (req,res) ->
	console.log '----------------------------at /dashboard'
	console.log '----------------------------at /dashboard the value of user name: ' + req.session.user_name

	res.render 'dashboard',
		name: req.session.user_name

router.get '/logout', (req,res) ->
	console.log '----------------------------at /logout'
	req.session.destroy()
	res.redirect '/'

module.exports = router