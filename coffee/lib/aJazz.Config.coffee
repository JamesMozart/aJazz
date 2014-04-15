###
JavaScript Document, by 梁达俊
	aJazz.Config
version 1.0
###

###
Config class
###
class aJazz.Config extends aJazz.Map
	###
	pass arguments to the config function
	@param  	{String}	key		the key for the specified config function
	@param 	{}			value
	...						arguments for cofig function
	@return 	{}			resuilt returned by config function
	or
	@param 	{Object}	configs	key:argument pairs
	@return 	{}			key:result of configs
	###
	config: (key, value) ->
		if arguments.length == 1
			results = {}
			for key, item of arguments[0]
				results[key] = @config key, item
			results
		else
			(@get key) value

###
Global config object, all configs must be set to this
@type {Config}
###
aJazz.config = new aJazz.Config()