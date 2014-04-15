###
TransView class, view with transitions
###
class aJazz.TransView extends aJazz.View
	require "lib/plugins"
	###
	 * transition enabled or not
	 * @type {Boolean}
	###
	transEnabled: true

	className: ""
	###
	 * css transition class
	 * @type {String}
	###
	transCls: "slideLeft"
	###
	 * css trnsition handling function
	 * @type {Function}
	###
	transit: $.transit
	###
	 * @override
	 * @param  {PageView} 	view
	 * @param  {Object} 	options
	 * @return {View}		@view
	 * options:{
			forward:Boolean,
			transCls:String,
			transEnabled:Boolean
		}
	###
	switch: (view, options) ->
		if view != @
			view.$ele.addClass View.HIDDEN_CLS
			@transit @_getTransOptions @, view, options
		@
	show: (options) ->
		@transit @_getTransOptions null, @, options
		@
	hide: (options) ->
		@transit @_getTransOptions @, options
		@
	_getTransOptions: (fromView, toView, options) ->
		options = options || {}
		forward = options.forward != false
		transCls = if options.transCls || (toView && forward || !fromView) then toView.transCls else fromView.transCls
		transOptions =
			transCls: transCls
			transEnabled: @transEnabled && options.transEnabled
			revert: !forward
			callback: () ->
				#event transEnd, listener:Function(visible, forward)
				if fromView?
					fromView.trigger "transEnd", [false, forward]
				if toView?
					toView.trigger "transEnd", [true, forward]

		if fromView
			transOptions.from = fromView.$ele
		if toView
			transOptions.to = toView.$ele
		transOptions

#view configs
aJazz.config.set
	###
	 * enable transitions for PageView and TransView
	 * @param  {Boolean}	transEnabled
	 * @return
	###
	"transEnabled": (transEnabled) ->
		aJazz.TransView::transEnabled = transEnabled
	###
	 * default transition css class for PageView and TransView
	 * @param  {String} 	transCls
	 * @return
	###
	"transCls": (transCls) ->
		aJazz.TransView::transCls = transCls