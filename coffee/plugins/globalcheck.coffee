###
ui by JamesMozart
###
(($) ->
	#check box replacement
	class globalValidator extends $.fn._fn_plugin.class
		namespace = "globalValidator"

		namespace: namespace
		constructor: ->
			super
			@_into = null
			@template = @settings.template
			@proxyEvent "focus", "input[data-validator],textarea[data-validator]", "_inputfocus"
			@proxyEvent "change", "select[data-validator]", "_inputchange"
			@proxyEvent "submit", "form", "_formsubmit"
		###
		events
		###
		_inputchange: (e) ->
			$input = $ e.currentTarget
			clearTimeout @_into
			@_into = setTimeout =>
				@_validate $input
				return
			, @settings.delay
			return
		_inputfocus: (e) ->
			$input = $ e.currentTarget
			if $input.val() == ""
				@_genMessage $input, "info"
			inputEvent = if ($input.attr "type") == "text" || ($input.prop "tagName") == "TEXTAREA"
					if "oninput" of window then "input" else "keyup"
				else
					"change"
			@proxyEvent inputEvent, "_inputchange", $input
			@proxyEvent "blur", "_inputblur", $input
			return
		_inputblur: (e) ->
			$input = $ e.currentTarget
			inputEvent = if ($input.attr "type") == "text" || ($input.prop "tagName") == "TEXTAREA"
					if "oninput" of window then "input" else "keyup"
				else
					"change"
			@unproxyEvent inputEvent, $input
			@unproxyEvent "blur", $input
			return
		_formsubmit: (e) ->
			$inputs = ($ e.currentTarget).find "[data-validator]"
			$errors = $inputs.filter (i, input)=>
				!@_validate $ input
			passed = $errors.length == 0
			!passed && $errors.first().focus()
			passed
		_validate: ($input) ->
			validator = new RegExp $input.data "validator"
			passed = validator.test $input.val()
			status = if passed then "ok" else "error"
			@_genMessage $input, status
			passed
		#status: "ok", "error", "info"
		_genMessage: ($input, status) ->
			message = $input.data status
			while ($input.css "display") == "none"
				$input = $input.parent()
			$messagebox = $input.next ".messagebox"
			if !$messagebox.hasClass status
				($input.next ".messagebox").remove()
				$input.after @template message, status
			return
		defaults:
			delay: 500
			template: (message, status)->
				" <span class='messagebox " + status + "'>" + message + "</span>"

		$._plugin_helper.buildFn namespace, @

	#check box replacement
	class globalCheck extends $.fn._fn_plugin.class
		namespace = "globalCheck"

		namespace: namespace
		constructor: ->
			super
			checkSelector = @settings.checkSelector
			@proxyEvent "click", checkSelector, "_checkclick"
			@proxyEvent "change", checkSelector + " input", "_checkchange"
			@proxyEvent "click", "label", "_labelclick"
		###
		events
		###
		_labelclick: (e) ->
			@_changeChecked ($ e.currentTarget).find "input"
			e.preventDefault()
			return
		_checkclick: (e) ->
			activeClass = @settings.activeClass
			$btn = $ e.currentTarget
			$input = $btn.find "input"

			if ($btn.hasClass "disabled") || ($btn.closest "label").length > 0
				return

			@_changeChecked $input
			return
		_checkchange: (e) ->
			$input = $ e.currentTarget
			checked = $input.prop "checked"
			@_setSpanChecked $input, checked

			if ($input.attr "type") == "radio"
				$radios = (($input.closest "form").find "[name='" + ($input.attr "name") + "']").not $input
				@_setSpanChecked $radios, false
			else if ($input.closest @settings.checkAllSelector).length > 0
				@_setChecked ((($input.closest "form").find "[name='" + ($input.attr "name") + "']").not $input), $input.prop "checked"
			return
		#bind the value to the input inside
		_changeChecked: ($input)->
			switch $input.attr "type"
				when "radio"
					@_setChecked $input, true
				when "checkbox"
					checked = $input.prop "checked"
					@_setChecked $input, !checked
			return
		_setChecked: ($inputs, checked)->
			$inputs.each (i, input) =>
				$input = $ input
				if checked != $input.prop "checked"
					$input.prop "checked", checked
					$input.trigger "change"
				return
			return
		_setSpanChecked: ($input, checked)->
			($input.closest @settings.checkSelector)[if checked then "addClass" else "removeClass"] @settings.activeClass
			return
		defaults:
			checkSelector: ".role-check"
			checkAllSelector: ".role-checkall"
			activeClass: "check-on"

		$._plugin_helper.buildFn namespace, @

	class dropdwonBox extends $.fn._fn_plugin.class
		namespace = "dropdwonBox"

		namespace: namespace
		constructor: ->
			super
			@$selectUl = null
			@selectCallback = null
			@options = null
		#events
		_liclicked: (e)->
			if @selectCallback
				$li = $ e.currentTarget
				option = @options[$li.index()]
				@selectCallback.call @, option.label, option.value
				@selectCallback = null
			return
		#generate item from select options
		_genList: ($options, selectCallback)->
			options = $options.map ->
				$option = $ @
				label: $option.text()
				value: $option.val()
				active: $option.prop "selected"
				disabled: ($option.attr "disabled") == "disabled"
			@_genListFromJSON options, selectCallback
		_genListFromJSON: (options, selectCallback)->
			@options = options
			@selectCallback = selectCallback
			html = @settings.template options
			if @$selectUl?
				if html
					$selectUl = @$selectUl.html ($ html).html()
				else @_removeList()
			else if html
				@$selectUl = $selectUl = ($ html).prependTo "body"
				@proxyEvent "click", ">:not(.disabled)", "_liclicked", $selectUl

			$selectUl
		#position the dummy list box
		_positionList: ($rel, addHeight = false, documentHeight = ($ document).height()) ->
			offset = $rel.offset()
			splited = $rel.hasClass "splited"
			top = offset.top
			left = if splited then $rel.prev().offset().left else offset.left
			w = $rel.outerWidth()
			relH = $rel.outerHeight()
			listH = @$selectUl.height()

			if top + listH < documentHeight
				if addHeight
					top += relH
			else
				if !addHeight
					top += relH
				top -= listH

			if splited
				w += $rel.prev().outerWidth()

			@$selectUl.css
				top: top
				left: left
				minWidth: w
			return
		_removeList: ->
			if @$selectUl?
				@unproxyEvent "click", @$selectUl
				@$selectUl.remove()
				@$selectUl = null
				@selectCallback = null
				@options = null
			return
		template:  (options)->
			if options.length > 0
				html = "<ul class='dropdownbox scroll'>"
				html += "<li" + (if option.active
					" class='dropdownbox-on'"
				else if option.disabled
					if option.label == option.value == ""
						" class='seperator'"
					else
						" class='disabled'"
				else "") + ">" + option.label + "</li>" for option in options
				html + "</ul>"
			else ""

		$._plugin_helper.buildFn namespace, @

	#switch selectbox replacement
	class globalSelect extends $.fn.dropdwonBox.class
		namespace = "globalSelect"

		namespace: namespace
		constructor: ->
			super
			selectSelector = @settings.selectSelector
			@selectClicked = false
			@proxyEvent "click", selectSelector, "_selectclick"
			@proxyEvent "change", selectSelector + " select", "_selectchange"
		###
		events
		###
		_selectclick: (e) ->
			@_openSelectSpan $ e.currentTarget
			return
		_openSelectSpan: ($selectSpan) ->
			$select = $selectSpan.find "select"
			$options = $select.children()
			value = $select.val()

			if ($select.attr "disabled") == "disabled"
				return

			offset = $selectSpan.offset()
			if @$selectUl
				@_removeList()
				@selectClicked = true
			else
				docEvent = "click." + namespace + "dropdown"
				($ document).on docEvent, =>
					if !@selectClicked
						@_removeList()
						($ document).off docEvent
					else @selectClicked = false
					return

			@_genList $options, (label, value) =>
				if $select.val() != value
					$select.val value
					$select.trigger "change"

				setTimeout =>
					nextSelector = $select.data "next"
					if nextSelector
						console.log ($ nextSelector).closest @settings.selectSelector
						@_openSelectSpan ($ nextSelector).closest @settings.selectSelector
				, 0
				return
			@_positionList $selectSpan, false

			return
		_selectchange: (e)->
			$select = $ e.currentTarget
			value = $select.val()
			@_setLabel $select, $select.children("[value='" + value + "']").text()
			return
		_setLabel: ($select, label)->
			$select.prev().text label
			return
		defaults:
			selectSelector: ".role-select"
			#template funciotn
			#@param options	<label:String,value:String,active:Boolean>
			template: @::template

		$._plugin_helper.buildFn namespace, @

	#combobox replacement
	class globalCombo extends $.fn.dropdwonBox.class
		namespace = "globalCombo"

		namespace: namespace
		constructor: ->
			super
			@_into = null
			@inputEvent = if "oninput" of window then "input" else "keyup"
			@proxyEvent "focus", @settings.comboSelector + " input", "_inputfocus"
		###
		events
		###
		_inputfocus: (e) ->
			$input = $ e.currentTarget

			@proxyEvent @inputEvent, "_inputchange", $input
			@proxyEvent "blur", "_inputblur", $input

			@_search $input
		_inputchange: (e) ->
			$input = $ e.currentTarget
			@_search $input
			return
		_inputblur: (e)->
			$input = $ e.currentTarget
			@unproxyEvent @inputEvent, $input
			@unproxyEvent "blur", $input
			setTimeout =>
				@_removeList()
			, @settings.delay
			return
		_search: ($input)->
			$comboSpan = $input.closest @settings.comboSelector
			$select = $comboSpan.find "select"
			value = $input.val()
			$options = $select.children().filter ->
				text = ($ @).text()
				(text.indexOf value) > -1 && text != value

			if ($input.attr "disabled") == "disabled"
				return

			selectCallback = (label, value)->
				$select.val value
				($input.val label).focus().trigger @inputEvent
				return

			clearTimeout @_into
			@_into = @proxyTimeout ->
				documentHeight = ($ document).height()
				if (source = $comboSpan.data "source")?
					#source example: ?query={query}
					$.ajax
						url: source.replace "{query}", encodeURIComponent value
						dataType: "json"
						success: (data)=>
							if $input.val() == value && @_genListFromJSON data, selectCallback
								@_positionList $input, true, documentHeight
							return
				else if @_genList $options, selectCallback
					@_positionList $input, true, documentHeight
			, @settings.delay
			return
		defaults:
			comboSelector: ".role-combo"
			delay: 200
			#template funciotn
			#@param options	<label:String,value:String,active:Boolean>
			template: @::template

		$._plugin_helper.buildFn namespace, @

	#dropdown button
	class globalDropDown extends $.fn.dropdwonBox.class
		namespace = "globalDropDown"

		namespace: namespace
		constructor: ->
			super
			@_into = null
			dropdownSelector = @settings.dropdownSelector
			@proxyEvent "click", dropdownSelector, "_btnclick"
		###
		events
		###
		_btnclick: (e) ->
			$btn = $ e.currentTarget

			if $btn.hasClass "disabled"
				return

			hiddenClass = @settings.hiddenClass
			$selectUl = $btn.next().removeClass hiddenClass

			if @$selectUl?
				@$selectUl.addClass hiddenClass
				#hide if the same btn is clicked
				@dropdownClick = $selectUl[0] != @$selectUl[0]
			else
				docEvent = "click." + namespace + "dropdown"
				($ document).on docEvent, =>
					if !@dropdownClick
						@$selectUl.addClass hiddenClass
						($ document).off docEvent
						@$selectUl = null
					else @dropdownClick = false
					return
			@$selectUl = $selectUl
			@_positionList $btn, true
			return
		defaults:
			dropdownSelector: ".role-dropdown"
			dropdownboxSelector: ".role-dropdownbox"
			hiddenClass: "hidden"
			#template funciotn
			#@param options	<label:String,value:String,active:Boolean>
			template: @::template

		$._plugin_helper.buildFn namespace, @

	#dropdown button
	class globalPopup extends $.fn._fn_plugin.class
		namespace = "globalPopup"

		namespace: namespace
		constructor: ->
			super
			@proxyEvent "click", @settings.btnSelector, "_btnclick"
		###
		events
		###
		_btnclick: (e) ->
			$btn = $ e.currentTarget

			if !$btn.hasClass "disabled"
				@open ($btn.attr "href"), $btn.data "modal"

			e.preventDefault()
			return
		_closeclick: (e) ->
			if !e.keyCode? || e.keyCode == 27
				@close()
			return
		_initPopup: ($popup)->
			@$popup = $popup
			@$popup.css
				marginLeft: - @$popup.outerWidth() / 2
			@proxyEvent "click", "_closeclick", @$modal
			@proxyEvent "click", @settings.closeSelector, "_closeclick", @$popup
			@proxyEvent "keydown", "_closeclick", $ document
			return
		#public methods
		open: (selector, showModal) ->
			if @$popup
				@close()

			$popup = $ selector
			$window = $ window

			showModal && @$modal = $("<div class='modal'/>").appendTo "body"
			#existing div
			if $popup.length > 0
				@$popup = $popup.removeClass @settings.hiddenClass
				@_initPopup $popup.removeClass @settings.hiddenClass
			#from ajax
			else
				$.ajax
					url: selector
					dataType: "html"
					success: (html)=>
						@_initPopup ($ html).appendTo "body"
						return
			return
		close: ->
			@unproxyEvent "click", @$popup
			@unproxyEvent "click", @$modal
			@unproxyEvent "keydown", $ document
			@$modal && @$modal.remove()
			if !@$popup.attr "id"
				@$popup.remove()
			else @$popup.addClass @settings.hiddenClass
			@$popup = @$modal = null
			return
		defaults:
			popupSelector: ".role-popup"
			btnSelector: ".role-popupbtn"
			closeSelector: ".role-close"
			hiddenClass: "hidden"

		$._plugin_helper.buildFn namespace, @

	#dropdown button
	class globalTooltip extends $.fn._fn_plugin.class
		namespace = "globalTooltip"

		namespace: namespace
		constructor: ->
			super
			try
				$ ":hover"
				@$tooltip = null
				@_enable()
			catch e
				# ...
		destroy: ->
			clearTimeout @_intv
			return
		###
		events
		###
		_hover: ->
			#find the last hover element
			$hover = ($ "[data-tooltip]:hover").last()

			if $hover.length > 0
				tooltip = $hover.data "tooltip"
				offset = $hover.offset()
				pos =
					top: offset.top + $hover.outerHeight()
					left: offset.left
				if !@$tooltip
					@$tooltip = $ @settings.template tooltip
					(@$tooltip.css pos).appendTo "body"
				else
					@$tooltip.html tooltip
					@$tooltip.css pos
					return
			else if @$tooltip
				@$tooltip.remove()
				@$tooltip = null
			return
		_enable: ->
			@_intv = @proxyInterval "_hover", @settings.delay
			return
		defaults:
			delay: 1000
			template: (tooltip)->
				return "<div class='tooltipbox'>" + tooltip + "</div>"

		$._plugin_helper.buildFn namespace, @

	#wrap and transfer the class to dummy span
	wrapInput = ($inputs, spanClass = "") ->
		activeClass = "check-on"
		disabledClass = "disabled"
		$inputs.each ->
			$input = $ @
			prefix = $input.data "prefix"
			className = @className + " " + spanClass
			if $input.prop "checked"
				className += " " + activeClass
			if $input.attr "disabled"
				className += " " + disabledClass
			$input.wrap "<span class='" + className + "'/>"
			prefix && $input.before prefix
			@className = ""
			return

	#wrap html parts into UI elements
	$.wrapUI = ($ele = document)->
		$ele = $ $ele
		#select
		(wrapInput ($ele.find ".role-select")).each ->
			$select = $ @
			$select.before "<span>" + $select.children("[value='" + $select.val() + "']").text() + "</span>"
			return
		#checkbox and radio and groups
		wrapInput $ele.find ".checkbox,.radiobox,.checkbtn"
		$ele
) $