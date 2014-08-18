###
JavaScript Document, by 梁达俊
	aJazz.EventDispatcher
version 1.0
###
util = aJazz.util

###
EventDispatcher class
###
class aJazz.EventDispatcher
	###
	event listener id, +1 for each EventDispatcher object
	@type {Number}
	###
	@listenerId: 0

	constructor: (options) ->
		###
		custom options bind to the EventDispatcher
		@type {Object}
		###
		@options = $.extend {}, @defaultOptions, options
		@_events = {}

		@_listenerId = EventDispatcher.listenerId++
	###
	default value for options
	@type {Object}
	###
	defaultOptions: null
	###
	bind event to the EventDispatcher
	@param  {String} 			eventKey 	       	name of event
	@param  {Function} 			listner     	    event listner function
	@param  {EventDispatcher} 	callbackContext 	optional, "this" object in listner function
	@return
	###
	on: (eventKey, listner, callbackContext) ->
		@_bind eventKey, listner, callbackContext, false
		return
	###
	bind event to the EventDispatcher, trigger only once
	@param  {String} 			eventKey 	       	name of event
	@param  {Function} 			listner     	    event listner function
	@param  {EventDispatcher} 	callbackContext 	optional, "this" object in listner function
	@return
	###
	one: (eventKey, listner, callbackContext) ->
		@_bind eventKey, listner, callbackContext, true
		return
	###
	unbind event by eventKey,
	or eventKey and callbackContext,
	or ubind all events with no param passed
	@param  {String} 			eventKey       	 	optional, name of event
	@param  {EventDispatcher}	callbackContext 	optional, "this" object in listner function
	@return
	###
	off: (eventKey, callbackContext) ->
		events = @_events;
		switch arguments.length
			when 0
				#remove all events
				@_events = {};
			when 1
				#remove by callbackContext
				if eventKey instanceof EventDispatcher
					for key,eventArr of events
						events[key] = $.grep eventArr, (eventItem)->
							return eventItem.callbackContext != eventKey
				#by type string
				else
					for eventKey in eventKey.split ","
						delete events[eventKey]
			else
				#remove by type and callbackContext
				events[eventKey] = $.grep events[eventKey], (eventItem)->
					return eventItem.callbackContext != callbackContext
		return
	###
	trigger an event binded
	@param  {String} eventKey     name of event
	@param  {}		eventDataArr data pass to the event listener
	@param  {Object} eventOptions options for event
	@return
	###
	trigger: (eventKey, eventDataArr, eventOptions) ->
		for eventKey in eventKey.split ","
			#overwrite the event object if eventOptions is an EventObject
			eventObj = if eventOptions instanceof aJazz.EventObject then eventOptions else new aJazz.EventObject eventKey, @, eventOptions
			eventArr = [eventObj]
			triggerResult = true
			eventsByKey = @_events[eventKey]

			eventObj.setCurrentTarget @

			eventDataArr? && eventArr = eventArr.concat eventDataArr

			if eventsByKey?
				@_events[eventKey] = $.grep eventsByKey, (eventItem)=>
					callbackContext = eventItem.callbackContext

					#return false in the event listener to cancel bubble
					result = eventItem.listner.apply(callbackContext, eventArr) != false;
					if !result
						eventObj.cancelBubble()
						triggerResult = false
					eventObj.bubble && callbackContext != @ && callbackContext.trigger.call callbackContext, eventKey, eventDataArr, eventObj

					!eventItem.once
		triggerResult
	###*
	 * bubble an event to another eventDispatcher, the bubbleTo object will listern to the event with an empty listner function
	 * @param  {String} eventKey event type to bubble
	 * @param  {aJazz.EventDispatcher} bubbleTo [description]
	###
	bubble: (eventKey, bubbleTo)->
		@on eventKey, ->
			return
		, bubbleTo
		return
	###
	destroy the eventDispatcher, remove all events
	@return
	###
	remove: ->
		@off()
		return
	###
	get an option from the options object, or get the options object if no key is specified
	@param  {String}	key optional, key of the option
	@return {}
	###
	getOption: (key) ->
		if key?
			value = @options[key]
			if value?
				###clone the value to prevent modifying it as object outside###
				switch typeof value
					when "object"
						if value instanceof Array
							[].concat value
						else if value?
							$.extend {}, value
						else
							null
					else
						value
			else
				null
		else @options
	###
	set an option to the options object, or set the options if an object is passed
	@event optionChange:(optionKey)
	@event optionsChange event
	@param {String} key key of the option
	@param {} 		value	 	value for the option
	@param {Boolean} trigger 	trigger optionChange events or not, default:true
	@return
	or
	@param {Object} 	options 	key:value map of options to set
	@param {Boolean} trigger 	trigger optionChange events or not, default:true
	@return{Boolean}	options have changes or not
	###
	setOption: ->
		options = {}
		changedOptions = {}
		beforeChangeOptions = {}
		changed = false

		if typeof arguments[0] != "object"
			#set a single option
			options[arguments[0]] = arguments[1]
			trigger = arguments[2] != false
		else
			#set a set of options
			options = arguments[0]
			trigger = arguments[1] != false

		for key, value of options
			if @options[key] != value
				beforeChangeOption = @options[key]
				beforeChangeOptions[key] = beforeChangeOption
				changedOptions[key] = @options[key] = value
				trigger && @trigger "optionChange:" + key, [value, beforeChangeOption], bubble: false
				changed = true

		changed && trigger && @trigger "optionsChange", [changedOptions, beforeChangeOptions], bubble: false
		changed
	###
	remove any option from options
	@param  {String} key key for the option
	@return
	###
	removeOption: (key) ->
		delete @options[key]
		return
	_bind: (eventKey, listner, callbackContext, once) ->
		for eventKey in eventKey.split ","
			eventsByKey = @_events[eventKey]

			!(eventsByKey?) && eventsByKey = @_events[eventKey] = []
			callbackContext = callbackContext || @

			eventsByKey.push
				listner: listner,
				callbackContext: callbackContext,
				once: once
		return

###
event object class, carry params for events
@param  {String} 			eventKey
@param  {EventDispatcher} 	target
@param  {Boolean}			bubble
@return
###
class aJazz.EventObject
	constructor: (eventKey, target, options) ->
		$.extend @, options
		@type = eventKey
		@target = @currentTarget = target
		@bubble = @bubble != false
	###
	set currentTarget for the event object
	@param  {EventDispatcher} currentTarget
	@return
	###
	setCurrentTarget: (@currentTarget) ->
	###
	cancel event bubbling
	@return
	###
	cancelBubble: ->
		@bubble = false