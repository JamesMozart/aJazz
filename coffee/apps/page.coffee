###
pageapp, load full html page as a view
###
define (require, exports, module) ->
	aJazz = require "aJazz"
	App = aJazz.App

	App.extend
		defaultOptions:
			#maxinum pages in app
			pageLimit: 10
		events:
			###
			force async loading for pages
			###
			"click||a": (e) ->
				$target = $ e.currentTarget
				href = $target.attr "href"
				@goTo (href.split "?")[0] + ":url=" + href
				e.preventDefaults()
				return
		###
		add a page view
		###
		addPage: (id, PageView, html, forward = true) ->
			$page = @$ "#" + id
			if $page.length == 0
				@$viewport.append $(".page", html).attr "id", id

			view = getView "page_" + id
			###
			create a view if not existed
			###
			if !view?
				view = new PageView
				@pageViewIds.push id
				@setView "page_" + id, view
				###
				unload a page if maxinum exceeded
				###
				if @pageViewIds.length > @getOpion "pageLimit"
					@removeView "page_" + @pageViewIds.shift()

			@bindView "page", view, forward: forward
			return
		###
		load and parse the template from options.url
		###
		routeEnter: (e, routeKey, query, forward) ->
			PageView = @routes[routeKey].View
			if PageView?
				id = PageView::id
				view = @getView "page_" + id
				if view?
					#existing
					@bindView "page", view, forward: forward
				else
					#TODO: handle loading
					require.async query.url, (html) =>
						if @pendingRouteKey == routeKey
							@addPage id, PageView, html, forward
						return
			return
		init: (options) ->
			@on "routeEnter", @routeEnter, @
			#cache for loaded pages
			@pageViewIds = []

			href = window.location.href.replace window.location.origin, ""
			@goTo (href.split "?")[0] + ":url=" + href
			return