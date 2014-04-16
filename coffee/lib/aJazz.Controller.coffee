###
JavaScript Document, by 梁达俊
	aJazz.Controller
	aJazz.LocalController
	aJazz.ControllerDebugger
version 1.0
###
util = aJazz.util

###
WebService Api Controller class
###
class aJazz.Controller extends aJazz.EventDispatcher
	###
	console.log ie fix
	###
	console = window.console || log: -> return

	@extend: util.extendClass

	constructor: (options) ->
		super

		util.moveTo @, @options, "app"
		#store the last request and response data
		@_requestArgs = null
		@response = @defaults

		#current pending xhr queue
		@$queue = $ {}

		@debugger && @debugger.add @

		@init options
	###
	ajax function, overwrite if needed
	@type {Function}
	###
	ajax: $.ajax
	###
	url to the webService
	@type {String|Function}
	###
	url: ""
	###
	ajax request type, get or post
	@type {String}
	###
	type: "post"
	###
	ajax data type
	@type {String}
	###
	dataType: "json"
	###
	base url to the server, prepend to url
	@type {String}
	###
	apiRoot: ""
	###
	dummy data url
	@type {String}
	###
	dummyUrl: ""
	###
	base url to the dummy data, prepend to dummyUrl
	@type {String}
	###
	dummyRoot: ""
	###
	use dummy data or true webservice
	@type {Boolean}
	###
	dummyEnabled: false
	###
	use ajax error text or status code for error status
	@type {Boolean}
	###
	useStatusCodeForError: false
	###
	catch errors and trigger error event
	@type {Boolean}
	###
	catchErrors: true
	###
	ajax timeout
	@type {Number}
	###
	timeout: 0
	###
	the unique controller debugger for debugging
	@type {aJazz.ControllerDebugger}
	###
	debugger: null
	###
	default value of response before send is call
	@type {Object}
	###
	defaults: null
	###
	headers for request
	@type {Object|Function}
	###
	headers: null
	###
	send a request
	@event  send
	@event  error
	@event  error:requestValidation
	@param  {Object} 	data 	data send to server
	@param  {String} 	type 	request type such as get post put delete
	@param  {String} 	eventAffix 	request success event affix triggers success:{eventAffix} if given
	@return {XMLHttpRequest}    	XMLHttpRequest Object for the request
	###
	send: (data, type = @type, eventAffix) ->
		args = arguments
		#fall back to an unknow error if proccess or validate throws uncaught error
		@_try ->
			request = @process data
			validateResult = @validateRequest request

			if validateResult == true
				@_requestArgs = args
				@trigger "send", request
				@$queue.queue "ajax", (next)=>
					@ajax
						url: if @dummyEnabled then @dummyRoot + @dummyUrl else @apiRoot + util.getFuncOrValue @url, [request], @
						type: if @dummyEnabled then "get" else type
						headers: util.getFuncOrValue @headers, [request], @
						data: request
						dataType: @dataType
						timeout: timeout
					.done (response)=>
						@_success response, eventAffix
						return
					.fail (xhr, status)=>
						@_error xhr, status, eventAffix
						return
					.always (xhr, status)=>
						@_complete xhr, status, eventAffix
						next()
						return
					return
				if (@$queue.queue "ajax").length == 1
					@$queue.dequeue "ajax"
			else
				eventObj = status: "requestValidation"
				@trigger "error:requestValidation,error", validateResult, eventObj
			return
		@
	###
	retry the last request
	@return
	###
	retry: ->
		@_requestArgs && @send.apply @, @_requestArgs
		@
	init: (options) ->
	###
	process data before send
	@param  {Object} data the unprocess request data
	@return {Object}      processed data
	###
	process: (data) -> data
	###
	parse data after response
	@param  {Object} data the unparsed response data
	@return {Object}      parseed data
	###
	parse: (data) -> data
	###
	validate the processed request data
	@return {Boolean|Object} return true if validate passed, else return an custom error object
	###
	validateRequest: -> true
	###
	validate the parsed response data
	@return {Boolean|Object} return true if validate passed, else return an custom error object
	###
	validateResponse: -> true
	#privates
	_try: (func) ->
		if @catchErrors
			try
				func.call @
			catch e
				console.log e.stack
				#fallback to an unknown error if get uncaught error
				@trigger "error"
		else
			func.call @
	###
	ajax success callbacks
	@param  {Object} response ajax response data
	@param  {String} 	eventAffix 	request success event affix triggers success:{eventAffix} if given
	@return
	###
	_success: (response, eventAffix) ->
		@_try ->
			data = @parse response 
			validateResult = @validateResponse data

			if validateResult == true
				@response = data
				@trigger "success", [data]
				if eventAffix?
					@trigger "success:#{eventAffix}", [data]
			else
				eventObj = status: "responseValidation"
				@trigger "error:responseValidation,error", validateResult, eventObj
			return
		return
	###
	ajax error callback
	@param  {XMLHttpRequest} xhr
	@param  {String} 		errorType	ajax error type
	@return
	###
	_error: (xhr, status, eventAffix) ->
		response = xhr.response
		eventObj = status: xhr.status
		resultStatus = if @useStatusCodeForError then xhr.status else status

		#try parsing error resonse into json
		if @dataType == "json"
			try
				response = $.parseJSON response
			catch e
				console.log e

		@trigger "error:" + resultStatus + ",error", [response], eventObj
		if eventAffix?
			@trigger "error:#{eventAffix}", [response], eventObj
		return
	###
	ajax complete callback
	@return
	###
	_complete: ->
		@trigger "complete"
		return

###
localStorage Controller
###
class aJazz.LocalController extends aJazz.EventDispatcher
	@extend: util.extendClass

	constructor: (options) ->
		super

		@response = @_read()
		@debugger && @debugger.add @
		@init options
	###
	set @unique key to read and write localStorage data
	@type {String}
	###
	url: ""
	###
	the unique controller debugger for debugging
	@type {aJazz.ControllerDebugger}
	###
	debugger: null
	###
	catch errors and trigger error event
	@type {Boolean}
	###
	catchErrors: true
	###
	default value of response before send is call
	@type {Object|Function}
	###
	defaults: null
	###
	save data to local
	@event success
	@return
	###
	send: (data) ->
		@_try ->
			localData = {}
			url = util.getFuncOrValue @url, [data], @
			localData.data = @process data
			validateResult = @validateRequest localData.data

			if validateResult == true
				localStorage.setItem url, JSON.stringify localData
				@response = data
				@trigger "send,success", data
			else
				@trigger "error:requestValidation,error", validateResult
			return
		@
	###
	process data before send
	@param  {Object} data the unprocess request data
	@return {Object}      processed data
	###
	process: (data) -> data
	###
	remove the controller
	@return
	remove: ->
		@app? && @app.off @
		super
	###
	###
	initialize
	@param  {Object} options
	@return
	###
	init: (options) ->
	###
	validate the data being save
	@param  {Object} data
	@return {Boolean}
	###
	validateRequest: -> true
	#privates
	_try: aJazz.Controller::_try
	###
	read data from local into memory, only once before init
	@return {Object}
	###
	_read: ->
		localData =	data: util.getFuncOrValue @defaults, [], @
		url = util.getFuncOrValue @url
		dataStr = localStorage.getItem url
		if dataStr?
			@_try ->
				localData = $.parseJSON dataStr
		localData.data

###
Controller Debugger
###
class aJazz.ControllerDebugger extends aJazz.EventDispatcher
	###
	json or string, string will log the stringify result of json
	@type {String}
	###
	debugType: "json"
	###
	assign a controller to the debugger
	@param  {Controller} controller the controller to debug
	@return
	###
	add: (controller) ->
		controller.on "send,success,error", @_debug, @
		@
	_debug: (e) ->
		args = [e.type].concat Array::slice.call arguments, 1
		switch @debugType
			#can use for adb debugging, which can only log strings
			when "string"
				args = [JSON.stringify args]
		console.log.apply console, args
		return

#controller configs
aJazz.config.set
	###
	set up apiRoot for all controllers
	@param  {String} apiRoot
	@return
	###
	"apiRoot": (apiRoot) ->
		aJazz.Controller::apiRoot = apiRoot
	###
	set up dummyRoot for all controllers
	@param  {String} dummyRoot
	@return
	###
	"dummyRoot": (dummyRoot) ->
		aJazz.Controller::dummyRoot = dummyRoot
	###
	set up dummyEnabled for all controllers
	@param  {String} dummyEnabled
	@return
	###
	"dummyEnabled": (dummyEnabled) ->
		aJazz.Controller::dummyEnabled = dummyEnabled
	###
	timeout for all ajax requests
	@param  {Number} timeout
	@return
	###
	"timeout": (timeout) ->
		aJazz.Controller::timeout = timeout
	###
	set up useStatusCodeForError for all controllers
	@param  {Boolean} useStatusCodeForError
	@return
	###
	"useStatusCodeForError": (useStatusCodeForError) ->
		aJazz.Controller::useStatusCodeForError = useStatusCodeForError
	###
	whether console debugging for all controllers is enabled
	@param  {Boolean} debug
	@return
	###
	"debug": (debug) ->
		##create the unique controller debugger for debugging
		aJazz.Controller::debugger = aJazz.LocalController::debugger = if debug then new aJazz.ControllerDebugger() else null
	###
	debugType for console debugging
	@param  {String} debugType
	@return
	###
	"debugType": (debugType) ->
		aJazz.ControllerDebugger::debugType = debugType
	###
	catch errors and trigger error event instead of throwing error to top
	@param  {String} catchErrors
	@return
	###
	"catchErrors": (catchErrors) ->
		aJazz.Controller::catchErrors = aJazz.LocalController::catchErrors = catchErrors