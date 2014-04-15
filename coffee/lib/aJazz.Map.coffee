###
JavaScript Document, by 梁达俊
	aJazz.Map
	aJazz.CacheMap
version 1.0
###
util = aJazz.util

###
Map class, basic Map
###
class aJazz.Map
	constructor: (@objects = {}) ->
	###
	get the item of the specified id(key) from objects,
	if no id specified return all objects
	@param  {String} id id(key) in objects
	@return {}
	###
	get: (id) ->
		if id? 
			@objects[id]
		else @objects
	###
	get items by the specified key=value in objects
	if no value specified return an objects grouped by each key
	@param  {String} byKey key
	@param  {} 		value value
	@return {Object}
	###
	getBy: (byKey, value) ->
		result = {};
		for key,item in @objects
			itemValue = item[byKey]
			if value?
				result[key] = item
			else if (itemValue == if typeof dataItem is "function"
				value.call @, key, item
			else value)
				if !(result of itemValue)
					result[itemValue] = {}
				result[itemValue][key] = item
		result
	###
	set a value or values to objects with key
	@param {String} 	key 	key
	@param {} 		value 	value
	or
	@param {Object} 	values 	key:value pairs
	@return
	###
	set: (key, value) ->
		if typeof key is "object"
			for id,value of key
				@set id, value
		else
			@objects[key] = value
		@
	###
	remove a item from map, if no idObj is specified remove all data from the map
	@param  {[type]} idObj [description]
	@return {[type]}       [description]
	###
	remove: (idObj) ->
		type = typeof idObj
		switch type
			when "undefined"
				#delete all
				@objects = {}
			when "string", "number"
				#delete by id
				delete @objects[idObj]
			else
				#delete by value
				@foreach (id, obj) ->
					if idObj == obj
						delete @objects[id]
		@
	###
	httpiterate throughout the map
	http@param  {Function(key,value)}	func	function call for each iteration
	http@return
	###
	foreach: (func) ->
		objects = @objects
		func.call @, id, item for id, item of objects
		@

###
httpCacheMap class
###
class aJazz.CacheMap extends aJazz.Map
	get: (id, fallback, create) ->
		obj = super id
		if create && !(obj?)
			obj = util.getFuncOrValue fallback, null, @
			@set id, obj
		obj