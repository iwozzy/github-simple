express = require 'express'
github = require 'octonode'
log = require '../util/log.coffee'
util = require '../util/util.coffee'

router = express.Router()

#---------------------------------------
#				GITHUB
#
#		routes have the /github base
#---------------------------------------

#TODO read up on this https://developer.github.com/guides/managing-deploy-keys/

router.get '/user', util.requiresLogin, (req,res) ->
	client = github.client req.session.user_github_token
	ghme = client.me()
	ghme.info (err, data, headers) ->
		res.json data

router.get '/user/repos', util.requiresLogin, (req,res) ->
	client = github.client req.session.user_github_token
	ghme = client.me()
	ghme.repos (err, repos, headers) ->
		for repo in repos
			console.log repo.name
		res.json repos

#TODO get user stats
#TODO submit pull request to octonode
#https://developer.github.com/v3/repos/statistics/

router.get '/user/repos/:repo', util.requiresLogin,(req,res) ->
	client = github.client req.session.user_github_token
	repo = client.repo "iwozzy/#{req.params.repo}"
	repo.info (err, repo, headers) ->
		res.json repo

#TODO
#Return an array of SHAs for consumption
# shas = (commit.sha for commit in commits)

router.get '/user/repos/:repo/commits', util.requiresLogin,(req,res) ->
	client = github.client req.session.user_github_token
	repo = client.repo "iwozzy/#{req.params.repo}"
	repo.commits (err, commits, headers) ->
		for commit  in commits
			log.info commit.sha
		res.json commits

router.get '/user/repos/:repo/commits/:sha', util.requiresLogin,(req,res) ->
	client = github.client req.session.user_github_token
	repo = client.repo "iwozzy/#{req.params.repo}"
	repo.commit "#{req.params.sha}", (err, commit, headers) ->
		res.json commit

router.get '/stats', util.requiresLogin, (req,res) ->
	stats =
		labels: []
		datasets:
			label: "Lines Added"
			data: []
	client = github.client req.session.user_github_token
	repo = client.repo "iwozzy/github-simple"
	repo.commits (err, commits, headers) ->
		for commit in commits
			commitDate = new Date commit.commit.author.date
			log.debug "The day is: #{commitDate.getDate()}"
			date = "#{commitDate.getMonth()}/#{commitDate.getDate()}"
			if stats.labels.indexOf(date) is -1
				log.debug "adding date"
				stats.labels.push date
				stats.datasets.data.push 0
			repo.commit "#{commit.sha}", (err, commit, headers) ->
				commitDate = new Date commit.commit.author.date
				date = "#{commitDate.getMonth()}/#{commitDate.getDate()}"
				index = stats.labels.indexOf(date)
<<<<<<< HEAD
				log.debug "adding: #{commit.stats.additions} lines at index: #{index}"
=======
				log.debug "adding value at index: #{index}"
>>>>>>> 7b3fcc203179ac9f20deb2f7f986da3d6423e714
				stats.datasets.data[index] += commit.stats.additions

				if commit.parents.length is 0 then res.json stats
		return

# For a repository
# Get every commit
# For every commit check what day it was made on
# For all commits in a particular day add up all of the added lines of code
# Return an JSON object, like this:
# { days: {01/01/2015, 01/02/2015}, linesAdded: {50, 70}}


module.exports = router