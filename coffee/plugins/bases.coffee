#commons
(($) ->
	Math.region = Math.region || (a, b, c) ->
		Math.min c, Math.max a, b

	getVendor = ->
		m = document.createElement "div"
		property =
			WebkitTransition: 'webkit'
			transition: ''
			MozTransition: 'moz'
			OTransition: 'o'
			msTransition: 'ms'
		for p of property
			if m.style[p]?
				return property[p]
		null

	getTouches = (e) ->
		t = e.touches
		if t? then x: t[0].pageX, y: t[0].pageY else	x: e.pageX,y: e.pageY

	vendor = getVendor()
	vendorPrefix = if vendor == "" then "" else "-" + vendor + "-"
	isTouch = "ontouchstart" of window
	transitionEndEvent = if vendor == ""
		"transitionend"
	else vendor + "TransitionEnd"
	touchEvents = if isTouch?
		start: "touchstart"
		move: "touchmove"
		end: "touchend"
	else
		start: "mousedown"
		move: "mousemove"
		end: "mouseup"

	$._plugin_helper =
		vendor: vendor
		vendorPrefix: vendorPrefix
		transformProp: vendorPrefix + "transform"
		transitionProp: vendorPrefix + "transition"
		hasTransition: vendorPrefix + "transform .5s"
		noTransition: "none"
		isTouch: isTouch
		transitionEndEvent: transitionEndEvent
		touchEvents: touchEvents
		getTouches: getTouches
		###
		jQuery plugin wrapper
		$.namespace
		###
		build: (namespace, plugin) ->
			$[namespace] = (settings) ->
				new plugin(settings)

			$[namespace].class = plugin
			$[namespace].defaults = plugin.prototype.defaults
			$[namespace]
		###
		jQuery plugin wrapper
		$.fn.namespace
		###
		buildFn: (namespace, plugin) ->
			$.fn[namespace] = (settings) ->
				$dom = @
				result = null
				args = Array.prototype.slice.call arguments, 1

				$dom.each ->
					$ele = $ @
					pluginInst = $ele.data "plugin_" + namespace
					if typeof settings == "string"
						#call a method of the plugin
						result = pluginInst[settings].apply pluginInst, args
					else if !(pluginInst?)
						#build and init
						new plugin $ele, settings

				if result? then result else $dom

			$.fn[namespace].class = plugin
			$.fn[namespace].defaults = plugin.prototype.defaults
			$.fn[namespace]
		#get, delete or set attribute from complex object using "attr1.attr2.attr3..."
		manipulateAttr: (obj, key, value) ->
			keys = key.split "."
			result = obj
			while keys.length > 1 && result?
				result = result[keys.unshift()]
			if typeof value == "undefined"
				#get
				result[keys[0]]
			else if value == null
				#delete
				delete result[keys[0]]
				return
			else
				#set
				if result?
					result[keys[0]] = value
	###
	interface:plugin, base for all $ plugin classes
	###
	class _plugin
		namespace = "_plugin"

		namespace: namespace
		constructor: (settings) ->
			@settings = $.extend {}, @defaults, settings
		#create a timeout
		proxyTimeout: (fun, delay) ->
			setTimeout (@_getProxyFun fun), delay
		#create an interval
		proxyInterval: (fun, delay) ->
			setInterval (@_getProxyFun fun), delay
		#get a proxy function to this
		_getProxyFun: (fun) ->
			if typeof fun == "string"
				fun = @[fun]
			$.proxy fun, @

		$._plugin_helper.build namespace, @

	###
	interface:plugin, base for all $.fn plugin classes
	###
	class _fn_plugin extends $._plugin.class
		namespace = "_fn_plugin"

		namespace: namespace
		constructor: ($ele, settings) ->
			@$ele = $ele
			@settings = $.extend {}, @defaults, settings
			$ele.data "plugin_" + @namespace, @
		destroy: ->
			@$ele.removeData "plugin_" + @namespace
			@$ele.off "." + @namespace
			return
		#bind event adn proxy to this (string event[[,string selector],function listner[,$dom]])
		proxyEvent: ->
			args = arguments
			lastArg = args[args.length - 1]
			#is $ object
			if ($ lastArg) == lastArg || lastArg instanceof $
				$dom = lastArg
				listener = args[args.length - 2]
				args = Array.prototype.slice.call args, 0, args.length - 1
			else
				$dom = @$ele
				listener = lastArg

			args[0] = (args[0].replace /\s+/g, "." + @namespace + " ") + "." + @namespace

			args[args.length - 1] = @_getProxyFun listener
			$dom.on.apply $dom, args
			return
		#unbind proxy event (string event[,$dom]])
		unproxyEvent: ->
			args = arguments
			$dom = args[1] || @$ele
			args[0] = (args[0].replace /\s+/g, "." + @namespace + " ") + "." + @namespace
			$dom.off.call $dom, args[0]
			return

		$._plugin_helper.buildFn namespace, @

	class getScripts extends _plugin
		namespace = "getScripts"

		namespace: namespace
		constructor: ->
			super
			@scripts = @settings.scripts
			@success = @settings.success

			@_getNext()
		_getNext: ->
			if @scripts.length > 0
				$.getScript @scripts.shift(), $.proxy arguments.callee, @
			else
				@success && @success()
			return

		$._plugin_helper.build namespace, @
	return
) $