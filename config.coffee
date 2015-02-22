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