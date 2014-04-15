###
TabView class, view with transitions
###
define (require, exports, module)->
	TabView = aJazz.View.extend
		className: ""
		###
		@var 	{String}	current effect class for tab head
		###
		onClass: "on"
		###
		add a tab to the tab view
		@param {String}		title	title display on tab head
		@param {Function or aJazz.View}	factory	factory function return <aJazz.View>(for async view creation) or an <aJazz.View> for tab content
		@param {Number}		index	position of the tab
		@return {Number}	id of the new tab
		###
		addTab: (title, factory, show, index = @tabs.length)->
			tab =
				id: ++@_idCounter
				title: title
			if typeof factory == "function"
				tab.factory = factory
			else
				@setView "tab#{tab.id}", factory

			if index > @tabs.length
				index = @tabs.length
			else if index < 0
				index = 0
			@tabs.splice index, 0, tab

			@render$ ".role-tab-head"
			(show || @tabs.length == 1) && @gotoTab index
			@_idCounter
		###
		move a tab to another position
		@param {Number}		from	tab index to move from
		@param {Number}		to		tab index to move to
		###
		moveTab: (from, to)->
			if @tabs.length == 0
				return
			tab = @tabs[from]
			@tabs.splice from, 1
			@tabs.splice to, 0, tab
			if @currTabIndex == from
				@currTabIndex = to
			else if @currTabIndex > from && @currTabIndex <= to
				@currTabIndex--
			else if @currTabIndex < from && @currTabIndex >= to
				@currTabIndex++
			@render$ ".role-tab-head"
			return
		moveTabById: (id, to)->
			moveTab @getTabIndexById id, to
		getTabIndexById: (id)->
			for tab,i in @tabs
				if tab.id == id
					return i
			-1
		###
		remove a tab from the tab view by position
		@param 	{Number}	index	optional, position of the tab, remove all tabs if not given
		@return {Number}	number of tabs remain
		###
		removeTab: (index)->
			$tabHead = @$ ".role-tab-head"
			if index?
				id = @tabs[index].id
				@tabs.splice index, 1
				($tabHead.children().eq index).remove()
				@_removeTabView id
				if index == @currTabIndex
					@currTabIndex = null
					@gotoTab index - 1
				else if index < @currTabIndex
					@currTabIndex--
			else
				for tab in @tabs
					@_removeTabView tab.id
				@tabs = []
				@currTabIndex = null
				$tabHead.empty()
			@tabs.length
		###
		remove a tab from the tab view by id
		@param 	{Number}	id	id of the tab
		@return {Number}	number of tabs remain
		###
		removeTabById: (id)->
			@removeTab @getTabIndexById id
		###
		tab to a tab by postion
		@param 	{Number}	index
		###
		gotoTab: (index)->
			if @tabs.length == 0
				return
			if index >= @tabs.length
				index = @tabs.length - 1
			else if index < 0
				index = 0
			$tabHead = @$ ".role-tab-head"
			$tabs = $tabHead.children()
			$onTab = $tabs.eq index
			$currTab = $tabs.eq @currTabIndex
			if index != @currTabIndex
				#switch body view
				view = @getTabView index
				if !view?
					tab = @tabs[index]
					view = tab.factory()
					@setView "tab#{tab.id}", view
				@bindView "tab-body", view
				#change tab head class
				$currTab.removeClass @onClass
				$onTab.addClass @onClass
				@currTabIndex = index
				#trigger change event, (<EventObject>e, <Number>index, <aJazz.View>view)
				@trigger "tabchange", [index, view]
			return
		###
		tab to a tab by id
		@param 	{Number}	id
		###
		gotoTabById: (id)->
			@gotoTab @getTabIndexById id
			return
		###
		get a tab body view by position
		@param 	{Number}	index
		@return {aJazz.View}
		###
		getTabView: (index)->
			@getTabViewById @tabs[index].id
		###
		get a tab body view by id
		@param 	{Number}	id
		@return {aJazz.View}
		###
		getTabViewById: (id)->
			@getView "tab#{id}"
		###
		get current show tab body view
		@return {aJazz.View}
		###
		getCurrentTabView: ->
			@getTabView @currTabIndex
		_removeTabView: (id)->
			@removeView "tab#{id}"
		_tabclick: (e)->
			@gotoTab ($ e.currentTarget).index()
			return
		_tabdeleteclick: (e)->
			@removeTabById ($(e.currentTarget).closest "span").data "id"
			e.stopPropagation()
			return
		render: ->
			aJazz.View::render.call @
			@addEvent "click|.role-tab-head|>", @_tabclick
			@addEvent "click|.role-tab-head|.role-delete", @_tabdeleteclick
			return
		init: (options)->
			aJazz.View::init.call @, options
			if @options.onClass?
				@onClass = options.onClass
			###
			@var {Array<Object<id:Number,title:String>>} data of tabs
			###
			@tabs = []
			###
			@var {Number} id counter, plus 1 ever for new tab
			###
			@_idCounter = 0
			###
			@var {Number} index of current show tab
			###
			@currTabIndex = null
			return
	TabView