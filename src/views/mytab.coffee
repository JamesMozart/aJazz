define (require, exports, module)->
	TabView = require "views/TabView"
	MsgView = require "views/msg"
	TabView.extend
		template: template require "templates/mytab.html"
		events:
			"click|.role-remove-all": (e)->
				@removeTab()
				return
			"click|.role-move": (e)->
				@moveTab @tabs.length - 1, 0
				return
			"click|.role-add": (e)->
				@_i++
				i = @_i
				@addTab "tab" + @_i, ->
					new MsgView msg: "tab#{i}"
				return
		init: (options)->
			TabView::init.call @, options
			@_i = 0
			return