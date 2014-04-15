(($) ->
	class transit extends $._plugin.class
		namespace = "transit"
		vendor = $._plugin_helper.vendor
		vendorPrefix = $._plugin_helper.vendorPrefix

		namespace: namespace
		constructor: ->
			super
			#assign values
			@$from = $ @settings.from
			@$to = $ @settings.to
			#select a transition for the browser
			transitFun = "hideShow"
			if @settings.transEnabled
				if vendor?
					transitFun = "cssTransit"
			@[transitFun] @$from, @$to
		#css3 transition
		cssTransit: ($from, $to) ->
			transSettings = @settings
			revert = transSettings.revert
			inCls = if revert then transSettings.outCls else transSettings.inCls
			outCls = if revert then transSettings.inCls else transSettings.outCls
			transCls = transSettings.transCls
			allCls = transCls + " " + inCls + " " + outCls
			hiddenCls = transSettings.hiddenCls
			#callback will not fire if transition interrupted
			delay = transSettings.delay

			@_changeClass $to, outCls+" "+hiddenCls, transCls + " " + inCls + " "
			@_changeClass $from, inCls, transCls

			eventPage = if $to.length > 0 then $to else $from
			#dind the transition end time
			transDur = (parseFloat eventPage.css vendorPrefix + "transition-duration") * 1000
			timeoutDataKey = namespace + "-timeout"

			#clear the previous transition
			timeoutFrom = $from.data timeoutDataKey
			timeoutTo = $to.data timeoutDataKey
			timeoutFrom && clearTimeout timeoutFrom
			timeoutTo && clearTimeout timeoutTo

			#delay before start
			@proxyTimeout ->
				$to.length > 0 && ($to.removeClass inCls).data timeoutDataKey, @proxyTimeout ->
					($to.removeClass allCls).removeData timeoutDataKey
					@_transCallback()
					return
				, transDur

				$from.length > 0 && ($from.addClass outCls).data timeoutDataKey, @proxyTimeout ->
					(($from.removeClass allCls).addClass hiddenCls).removeData timeoutDataKey
					if $to.length == 0
						@_transCallback()
					return
				, transDur

				return
			, delay

			return
		#Zepto animation
		jqTransit: ($from, $to) ->
			settings = @settings
			animateComplete = $.proxy @_transCallback(), @
			fromParam = duration: @settings.jqDelay
			toParam = duration: @settings.jqDelay
			if $from.length > 0
				fromParam.complete = animateComplete
			else toParam.complete = animateComplete
			$from.stop(true).fadeOut fromParam
			$to.stop(true).fadeIn toParam
			return
		#hide and show
		hideShow: ($from, $to) ->
			callback = @settings.callback
			hiddenCls = @settings.hiddenCls
			$to && $to.removeClass hiddenCls
			$from && $from.addClass hiddenCls

			@_transCallback()
			return
		_changeClass: ($ele, fromCls, toCls) ->
			($ele.removeClass fromCls).addClass toCls
		_transCallback: ->
			callback = @settings.callback
			callback && callback.call @, @settings.from, @settings.to
		defaults:
			inCls: "in"
			outCls: "out"
			hiddenCls: "hidden"
			transCls: "fade"
			revert: false
			callback: null
			delay: 0
			jqDelay: 500
			transEnabled: true

		$._plugin_helper.build namespace, @

	return
) $