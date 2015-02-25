npmInfo = require './package.json'

module.exports = do ->
	#to set the NODE_ENV variable e.g. export NODE_ENV=dev
	console.log "Node Env Variable: #{process.env.NODE_ENV}"

	switch process.env.NODE_ENV
		when undefined, "dev" then {
			env: 'dev'
			expressPort: 0 #express port
			github:
				id: 'x' #github app ID
				secret: 'x' #github app secret
			firebase:
				host: 'x' #firebase url
		}