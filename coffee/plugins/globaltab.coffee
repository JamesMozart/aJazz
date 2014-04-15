(($) ->
	#load html into div
	preload = ($div, callback) ->
		src = $div.data "src"
		cache = $div.data "cache"
		if src
			if cache != false
				($div.removeAttr "data-src").removeData "src"
			$div.load src, ->
				callback && callback()
		else callback && callback()
		return

	#button group
	class globalBtnGroup extends $.fn._fn_plugin.class
		namespace = "globalBtnGroup"

		namespace: namespace
		constructor: ->
			super
			@proxyEvent "click", @settings.groupSelector + " a", "_btnclick"
		switchTo: ($btn) ->
			activeClass = @settings.activeClass
			$on = $btn.siblings "." + activeClass

			index = $btn.index()
			last = $on.index()

			if !$btn.hasClass activeClass
				#bind the value to the input inside
				($btn.addClass activeClass).prop "checked", true
				last >=0 && $on.removeClass activeClass
			return
		###
		events
		###
		_btnclick: (e) ->
			@switchTo $ e.currentTarget
			return
		defaults:
			groupSelector: ".role-btn-group"
			activeClass: "btn-on"

		$._plugin_helper.buildFn namespace, @

	#tabs
	class globalTab extends $.fn._fn_plugin.class
		namespace = "globalTab"

		namespace: namespace
		constructor: ->
			super
			@proxyEvent "click", @settings.tabSelector + " a", "_tabclick"
		switchTo: ($tab) ->
			activeClass = @settings.activeClass
			hiddenClass = @settings.hiddenClass

			$parent = $tab.closest @settings.tabSelector
			contentsSelector = $parent.data "contents"
			$on = $tab.siblings "." + activeClass
			$contents = if contentsSelector then ($ contentsSelector) else $parent.next().children()

			index = $tab.index()
			last = $on.index()

			if !$tab.hasClass activeClass
				$tab.addClass activeClass
				if last >= 0
					$on.removeClass activeClass
					($contents.eq last).addClass hiddenClass

				@_preload ($contents.eq index), ->
					if $tab.hasClass activeClass
						($contents.eq index).removeClass hiddenClass
					return
				$parent.trigger "tabChange", index
			return
		###
		events
		###
		_tabclick: (e) ->
			@switchTo $ e.currentTarget
			return
		_preload: preload
		defaults:
			tabSelector: ".role-tabs"
			activeClass: "tab-on"
			hiddenClass: "hidden"

		$._plugin_helper.buildFn namespace, @

	#accordion
	class globalAcorr extends $.fn._fn_plugin.class
		vendor = $._plugin_helper.vendor
		namespace = "globalAcorr"

		namespace: namespace
		constructor: ->
			super
			@proxyEvent "click", @settings.acorrSelector + " " + @settings.handleSelector, "_acorrclick"
		switchTo: ($tab) ->
			activeClass  = @settings.activeClass

			$parent = $tab.parent()
			$on = $tab.siblings "." + activeClass

			index = $tab.index()
			last = $on.index()

			if !$tab.hasClass activeClass
				@_preload $tab,  $.proxy ->
					contentSelector = @settings.contentSelector
					
					$tab.addClass activeClass
					$content = $tab.children contentSelector
					h = $content.height()
					$content.detach().css "height", 0
					$tab.append $content
					@proxyTimeout ->
						$content.css "height", h
						return

					if last >= 0
						$onContent = $on.children contentSelector
						if !(vendor?) || $onContent[0].style.height
							$on.removeClass activeClass
							$onContent.css "height", ""
						else
						#first time
							($onContent.css "height", $onContent.height()).detach()
							($on.removeClass activeClass)
							.append $onContent
							@proxyTimeout ->
								$onContent.css "height", ""
								return
							, 0
					return
				, @
				$parent.trigger "acorrChange", index
			return
		###
		events
		###
		_acorrclick: (e) ->
			@switchTo ($ e.currentTarget).closest @settings.acorrSelector + ">"
			return
		_preload: preload
		defaults:
			handleSelector: ".role-handle"
			contentSelector: ".acorr-content"
			acorrSelector: ".role-acorr"
			activeClass: "acorr-on"

		$._plugin_helper.buildFn namespace, @

	return
) $