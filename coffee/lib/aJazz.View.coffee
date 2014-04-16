###
JavaScript Document, by 梁达俊
	aJazz.View
	aJazz.TransView
version 1.0
###
util = aJazz.util

#view class
class aJazz.View extends aJazz.EventDispatcher
	###
	 * the css class for hiding elements
	 * @type {String}
	###
	@HIDDEN_CLS: "hidden"
	###
	 * extent this class into a child class
	 * @type {Function}
	###
	@extend: util.extendClass

	constructor: (options) ->
		super

		###
		 * @var {aJazz.View}	parent view of this view, set with the parent view set view method
		###
		@parent = null

		$ele = @$ele = if @id?
			$ document.getElementById @id
		else ($ document.createElement @tagName).addClass @className
		$ele.data "view", @

		util.moveTo @, @options, "app"
		util.moveTo @, @options, "route"

		CacheMap = aJazz.CacheMap
		@_viewMap = new CacheMap()
		@_controllerMap = new CacheMap(@options.controllers)
		delete @options.controllers
		@_inserted = false
		@_domEvents = {}

		delete @options.controllers

		@init()

		if @options.viewport?
			@appendTo @options.viewport
	###
	 * id for the view element
	 * if specified, find dom element by id as @$ele, and do not create a new element according to classname and tagname
	 * @type {String}
	###
	id: null
	###
	 * class name for the view element
	 * @type {String}
	###
	className: ""
	###
	 * tag name for the view element
	 * @type {String}
	###
	tagName: "div"
	###
	 * auto call render before init
	 * @type {Boolean}
	###
	autoRender: true
	###
	 * template function
	 * @type {Function}
	###
	template: -> ""
	###
	 * dom events, define as "event[|selector|elementSelector]"
	 * @type {Object<Function>}
	###
	events: {}
	###
	 * data render functions as func(data, $element)
	 * @type {Object<Function>}
	###
	binders: {}
	###
	 * public constructor, call after base view class _construct
	 * @param  {Object} options
	 * @return
	###
	init: (options) ->
	###
	 * append the view element to the viewport element
	 * @param  {Dom Object|aJazz.View} viewport the viewport element to append
	 * @return {View}		@view
	###
	appendTo: (div) ->
		@_insert("append", div)
		@
	beforeTo: (div) ->
		@_insert("before", div)
		@
	afterTo: (div) ->
		@_insert("after", div)
		@
	replaceTo: (div) ->
		@_insert("replaceWith", div)
		@
	###
	 * add event listener to dom
	 * @param  {String} 	eventKey
	 * @param  {Function} 	listener
	 * @return
	###
	addEvent: (eventKey, listener) ->
		eventObj = {}
		if typeof eventKey == "object"
			eventObj = eventKey
		else
			eventObj[eventKey] = listener
		@_bindEvents eventObj, true
		return
	###
	 * remove event listener from dom
	 * if no eventKey specified, remove all dom event in @view
	 * @param  {String} 	eventKey
	 * @return
	###
	removeEvent: (eventKey) ->
		eventObj = {}
		if eventKey?
			eventObj[eventKey] = @_domEvents[eventKey]
		else
			eventObj = @_domEvents
		@_bindEvents eventObj, false
		return
	###
	 * show the view element
	 * @return {View}		@view
	###
	show: ->
		@$ele.removeClass View.HIDDEN_CLS
		@
	###
	 * hide the view element
	 * @return {View}		@view
	###
	hide: ->
		@$ele.addClass View.HIDDEN_CLS
		@
	###
	 * switch from @view to the view specified
	 * @return {View}		@view
	###
	switch: (view) ->
		if view != @
			view.show()
			@hide()
		@
	###
	 * render the view, set the html to view element
	 * @return
	###
	render: ->
		# clear events and views if the view is rendered
		if @_inserted
			@removeEvent()
			@removeView()
		#generate template ,present the view as view in template
		@$ele.html @template view: @
		@addEvent @events
		@
	###
	 * render the apart of view, fill in html and className
	 * @param  {String} selector   	selector of the part to render
	 * @param  {Boolean} append   	use append instead of replacing html
	 * @return
	###
	render$: (selector, append) ->
		#generate template ,present the view as view in template
		$div = $ @template view: @
		$renderDivs = ($div.filter selector).add $div.find selector
		method = if append then "append" else "html"
		(@$ selector, true).each (i)->
			$renderDiv = $renderDivs.eq i
			@.className = $renderDiv[0].className
			($ @)[method] $renderDiv.html()
		@
	###
	 * remove the view element from Dom and unbind all events
	 * @return
	###
	remove: ->
		super
		#remove all events bind to @view
		@removeEvent()
		@removeView()
		@removeController()
		@app && @app.off @
		@parent && @parent._viewMap.remove @

		#remove dom element
		bindKey = @$ele.attr "_view"
		if bindKey?
			#replace an empty div if bindview is removed
			@$ele.after "<div _view='#{bindKey}'/>"
		(@$ele.removeData "view").remove()

		super
	###
	 * send data to a render in binders to update a part of the view
	 * @param  {String} key   	render key in binders
	 * @param  {} 		value 	the data to render
	 * @return
	 * or
	 * @param  {Object} dataMap key:value pairs to render
	 * @return
	###
	bindData: (key, value) ->
		data = arguments[0]
		if arguments.length > 1
			render = @binders[key]
			$bind = @$("[_bind='" + key + "']")
			textValue = if typeof render == "function"
				render.call(@, value, $bind)
			else value
			@_setValue $bind, textValue
		else
			#update all fields
			for key,value of data
				@bindData key, value
	###
	 * dom selection inside the view
	 * @param  {[type]}		selector 	css selector
	 * @return {$Object}
	###
	$: (selector) ->
		@$ele.find selector
	###
	 * get a child view
	 * @param  {String} 	viewKey  	key for the child view
	 * @param  {Object} 	fallback 	fallback options to create when fail to get
	 * @param  {Boolean}	create  	whether to create a new view if fail to get
	 * @return {View}
	###
	getView: (viewKey, fallback, create) ->
		@_viewMap.get viewKey, fallback, create
	###
	 * set one child views to @view, or set up batch of child views using childOptions and Views
	 * @param  {String} 	viewKey     	key for @view, can used for get and remove
	 * @param  {View} 		view        	the child view to set
	 * @param  {Boolean} 	bind        	whether to call the bindView method using viewKey and now for @child view
	 * @param  {Object} 	bindOptions 	options of view.switch
	 * or
	 * @param  {Object} 	childViews		key view pairs
	 * @param  {Boolean} 	bind        	whether to call the bindView method using viewKey and now for @child view
	 * @return
	###
	setView: (viewKey, view, bind, bindOptions) ->
		if (if typeof viewKey == "object" then view else bind)
			@bindView viewKey, view, bindOptions

		if typeof viewKey == "object"
			for key, view of viewKey
				view.parent = @
				if currView = @_viewMap.get key
					currView.remove()
		else
			view.parent = @
			currView = @_viewMap.get viewKey
			if currView && currView != view
				currView.remove()
		@_viewMap.set viewKey, view
	###
	 * append a view to element, and switch from the current view
	 * @param  {String} 	bindKey 	_view attribute of element being appended to
	 * @param  {View} 		view    	the view to append
	 * @param  {Object} 	options 	options for view switching
	 * @return {View} 		the appendding view
	 * or
	 * @param  {Object} 	childViews	key view pairs
	 * @param  {Object} 	options 	options for view switching
	###
	bindView: (bindKey, view, options) ->
		if typeof bindKey == "object"
			for key of bindKey
				@bindView key, bindKey[key], view
		else
			$view = @$ "[_view='" + bindKey + "']", true
			currView = $view.data "view"
			view.afterTo $view
			$view.removeAttr "_view"
			view.$ele.attr "_view", bindKey
			if currView?
				currView.switch view, options
			else
				view.replaceTo $view
				if !view.visible()
					view.show()
		@
	###
	 * remove a child view, if no viewKey specified, remove all child views
	 * @param  {String} 	viewKey 	key for the view to remove
	 * @return
	###
	removeView: (viewKey) ->
		@_removeFromMap @_viewMap, viewKey, true
		@
	###
	 * get a controller set to the view
	 * @param  {String} 	controllerKey 	key for the controller
	 * @param  {Object} 	fallback      	fallback options to create when fail to get
	 * @param  {Boolean} 	create     		whether to create a new controller if fail to get
	 * @return {Controller}
	###
	getController: (controllerKey, fallback, create) ->
		@_controllerMap.get controllerKey, fallback, create
	###
	 * set one or more controller to the view
	 * @param  {String} 	controllerKey key
	 * @param  {Controller} controller
	 * or
	 * @param {Object}		key:value pairs
	 * @return
	###
	setController: (controllerKey, controller) ->
		@_controllerMap.set controllerKey, controller
	###
	 * remove a controller
	 * @param  {String} controllerKey
	###
	removeController: (controllerKey) ->
		@_removeFromMap @_controllerMap, controllerKey
		@
	###
	 * is view visible
	 * @return {Boolean}
	###
	visible: ->
		(@$ele.css "display") != "none"
	#privates
	###
	 * insert the view element into dom
	 * @param  {String} method jQuery dom method
	 * @param  {Dom} 	div    element to refer
	 * @return
	###
	_insert: (method, div) ->
		$ele = @$ele
		$div = div.$ele || $ div
		$div[method] $ele
		if !@_inserted
			if @autoRender
				@render()
			@_inserted = true
		return
	###
	 * bind Dom events to element, events:view.events, isBind:Boolean
	 * @param  {Object<Function>}  	events event defination object
	 * @param  {Boolean} 			isBind bind or unbind events
	 * @return
	###
	_bindEvents: (events, isBind) ->
		fun = if isBind != false then "on" else "off"

		for key, item of events
			eventArr = key.split "|"
			args = [eventArr[0]]
			$ele = if eventArr.length > 1 && eventArr[1].length > 0 then @$ eventArr[1] else @$ele
			if isBind
				eventArr.length > 2 && args.push eventArr[2]
				args.push $.proxy item, @

				@_domEvents[key] = item
			else
				delete @_domEvents[key]
			$ele[fun].apply($ele, args)
		return
	###
	 * set string value to element
	 * @param {$Object} $ele  $element to set
	 * @param {} 		value
	###
	_setValue: ($ele, value) ->
		value = if value? then value.toString() else ""
		$ele.each ->
			$ele = $ @
			switch $ele.prop "tagName"
				when "INPUT", "SELECT"
					switch $ele.attr "type"
						when "checkbox", "radio"
							$ele.prop "checked", if $ele.val() == value then "checked" else ""
						else
							$ele.val value
				when "IMG", "IFRAME"
					$ele.attr "src", value
					break
				else
					$ele.html value
			return
		return
	#remove view or controller from view and controller map object, and off events
	_removeFromMap: (map, key, isView) ->
		if key?
			item = map.get key
			if item?
				if isView
					item.parent = null
					item.remove()
				else
					item.off @
				map.remove key
		else
			#remove all
			map.foreach (key, item) =>
				@_removeFromMap map, key, isView
		return