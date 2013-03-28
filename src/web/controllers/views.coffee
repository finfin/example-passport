http				= require 'http'
xtend				= require 'xtend'
env					= process.env.NODE_ENV || 'development'
config				= require('../../../config/config')[env]

exports.index = (req, res) ->
	res.render "index", 
		title: "Home"
		user: req.user