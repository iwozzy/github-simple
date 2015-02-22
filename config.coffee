#Replace the null values with your own
#Run the 'git update-index --assume-unchanged config.coffee' command to prevent from accidentally commiting

npmInfo = require './package.json'

module.exports = do ->
	#to set the NODE_ENV variable e.g. export NODE_ENV=dev
	console.log "Node Env Variable: #{process.env.NODE_ENV}"

	switch process.env.NODE_ENV
		when "dev" then {
			env: 'dev'
			expressPort: null #express port
			github:
				id: null #github app ID
				secret: null #github app secret
		}