express = require 'express'
github = require 'octonode'

router = express.Router()

#TODO read up on this https://developer.github.com/guides/managing-deploy-keys/

router.get '/user', (req,res) ->
	client = github.client req.session.github_token
	ghme = client.me()
	ghme.info (err, data, headers) ->
		res.json data

router.get '/user/repos', (req,res) ->
	client = github.client req.session.github_token
	ghme = client.me()
	ghme.repos (err, repos, headers) ->
		for repo in repos
			console.log repo.name
		res.json repos

#TODO get user stats
#TODO submit pull request to octonode
#https://developer.github.com/v3/repos/statistics/

router.get '/user/:repo', (req,res) ->
	client = github.client req.session.github_token
	client.get "/repos/iwozzy/#{req.params.repo}/stats/participation", (err, status, repo, headers) ->
		res.json repo

module.exports = router