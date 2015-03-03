log = require 'winston'

log.remove log.transports.Console
log.add log.transports.Console,
	colorize: true,
	level: 'debug'

module.exports = log
