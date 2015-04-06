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

#TODO
#See if it would be better to use the username in the session here
router.get '/user/repos', util.requiresLogin, (req,res) ->
	user_repos = []
	client = github.client req.session.user_github_token
	ghme = client.me()
	ghme.repos (err, repos, headers) ->
		for repo in repos
			user_repos.push repo.name
			log.debug repo.name
		res.json user_repos

#TODO use the current user instead of the hard coded iwozzy
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
		log.debug "headers #{headers}"
		log.debug "err #{err}"
		log.debug "commits #{commits}"
		#for commit  in commits
		#	log.info commit.sha
		#res.json commits

router.get '/user/repos/:repo/commits/:sha', util.requiresLogin,(req,res) ->
	client = github.client req.session.user_github_token
	repo = client.repo "iwozzy/#{req.params.repo}"
	repo.commit "#{req.params.sha}", (err, commit, headers) ->
		res.json commit

#Months for Dates are 0 based - I think this is solved with moment.js
#TODO
#Break this up into smaller units
#Promises?

router.get '/stats/:repo', util.requiresLogin, (req,res) ->
	stats =
		labels: []
		datasets: []

	linesAdded =
			label: "Lines Added"
			data: []

	client = github.client req.session.user_github_token

	#REPLACE THIS WITH A VARIABLE
	log.debug "#{req.session.username}/#{req.params.repo}"
	repo = client.repo "#{req.session.username}/#{req.params.repo}"
	repo.commits (err, commits, headers) ->
		log.debug commits
		log.error err
		log.debug headers
		today = moment new Date()
		firstCommitDate = moment new Date commits[commits.length-1].commit.author.date

		#TODO
		#Include the Day of Week
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

# Pick the right repository
# For a repository
# Get every commit
# For every commit check what day it was made on
# For all commits in a particular day add up all of the added lines of code
# Return an JSON object, like this:
# { days: {01/01/2015, 01/02/2015}, linesAdded: {50, 70}}


module.exports = router