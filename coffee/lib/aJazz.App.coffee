###
JavaScript Document, by 梁达俊
	aJazz.App
	hash format is like a query string: #page:id=123&a=csd
version 1.0
###
util = aJazz.util

###
App class, global view and hash router
###
class aJazz.App extends aJazz.View
	@extend: util.extendClass

	constructor: (options) ->
		super
		@_ignoreHashChangeOnce = false

		#the latest route
		@currRouteKey = null
		@pendingRouteKey = null
		util.moveTo @, @options, "viewport"
	###
	@type {Object<Route>}	router settings
	###
	routes: {}
	###
	start listening to hash change and go to current hash
	@return
	###
	startHistory: ->
		if !("onhashchange" of window)
			@_currHash = window.location.hash
			setInterval =>
				hash = window.location.hash
				if hash != @_currHash
					@_hashChange()
					@_currHash = hash
				return
			, 250
		($ window).on "hashchange.aJazz_" + @_listenerId, ($.proxy @_hashChange, @)
		@_toRoute()
	###
	remove the app
	###
	remove: ->
		($ window).off ".aJazz_" + @_listenerId
		super
	###
	go to a hash
	@param  {String|Object<route:String,query:Object>} 	hash    hash string:#... or object
	@param  {Boolean} 		trigger		trigger router enter and exit or not
	@return
	###
	goTo: (hash, trigger = true) ->
		toHash = hash
		typeof hash == "object" && toHash = hash.route + if hash.query? then ":" + $.param hash.query else ""

		if (toHash.replace "#", "") != window.location.hash.replace "#", ""
			@_ignoreHashChangeOnce = true
			window.location.hash = toHash
			trigger && @_toRoute toHash

		return
	###
	go back in history
	@param  {Number} step how many step of history to go back
	@return
	###
	goBack: (step) ->
		typeof step == "undefined" && step = 1
		history.go -step
	#privates
	_hashChange: (e) ->
		!@_ignoreHashChangeOnce && @_toRoute()
	_toRoute: (hash = window.location.hash.replace "#","") ->
		hashArr = hash.split ":"
		routeKey = hashArr[0]
		query = util.deparam hashArr[1] || ""
		route = @routes[routeKey]

		@_ignoreHashChangeOnce = false
		@pendingRouteKey = routeKey

		#get a route module and execute
		if typeof route == "string"
			require.async route, (route) =>
				@routes[routeKey] = route
				@_switchRoute routeKey, query
		else @_switchRoute routeKey, query
		return
	_switchRoute: (routeKey, query) ->
		route = @routes[routeKey]
		currRoute = @routes[@currRouteKey]
		forward = if route? then (route.compareTo currRoute) >= 0 else true

		if @pendingRouteKey == routeKey
			@trigger "routeExit", [@currRouteKey, query, forward]
			currRoute && currRoute.exit && currRoute.exit @, forward
			@currRouteKey = @pendingRouteKey
			@trigger "routeEnter", [routeKey, query, forward]
			route && route.enter && route.enter @, query, forward
			@pendingRouteKey = null
		return
###
Route class
enter: route enter function
exit: route exit function
level: the level of route, app will go forward if new level>current level
@param {Object} options {enter:Function,exit:Function,level:Number}
###
aJazz.Route = class Route
	@extend: util.extendClass
	level: 0
	constructor: (options) ->
		$.extend @, options
		#storage for history state
		@_state = null
		@init()
	###
	get history state store in ths route object
	@return {Object}
	###
	getState: ->
		@_state
	###
	set history state to ths route object
	@return {Object}
	###
	setState: (state) ->
		@_state = state
	###
	compare which route has the higher level to determine if history is going forward
	@param  {Route} 	route another route to compare
	@return {Number}
	###
	compareTo: (route) ->
		if route?
			@level - route.level
		else 0
	init: (options) ->