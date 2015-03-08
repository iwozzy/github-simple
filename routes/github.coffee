express = require 'express'
github = require 'octonode'
log = require '../util/log.coffee'
util = require '../util/util.coffee'
moment = require 'moment'

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

#Months for Dates are 0 based

router.get '/stats', util.requiresLogin, (req,res) ->
	stats =
		labels: []
		datasets: []

	linesAdded =
			label: "Lines Added"
			data: []

	client = github.client req.session.user_github_token

	repo = client.repo "iwozzy/github-simple"
	repo.commits (err, commits, headers) ->
		today = moment new Date()
		firstCommitDate = moment new Date commits[commits.length-1].commit.author.date

		log.debug today.format("MMM Do")
		log.debug firstCommitDate.format("MMM Do")

		projectDays = today.diff firstCommitDate, 'days'

		while stats.labels.length != projectDays+2
			linesAdded.data.push 0
			stats.labels.push firstCommitDate.format("MMM Do")
			firstCommitDate.add 1, 'days'
			console.log stats.labels
			console.log linesAdded.data

		for commit in commits

			repo.commit "#{commit.sha}", (err, commit, headers) ->

				commitDate = moment new Date commit.commit.author.date
				index = stats.labels.indexOf(commitDate.format("MMM Do"))
				log.debug "adding: #{commit.stats.additions} lines at index: #{index}"
				log.debug "adding value at index: #{index}"
				linesAdded.data[index] += commit.stats.additions

				if commit.parents.length is 0
					stats.datasets.push linesAdded
					res.json stats

# For a repository
# Get every commit
# For every commit check what day it was made on
# For all commits in a particular day add up all of the added lines of code
# Return an JSON object, like this:
# { days: {01/01/2015, 01/02/2015}, linesAdded: {50, 70}}


module.exports = router