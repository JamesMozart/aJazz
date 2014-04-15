###
simple text msg view class
###
define (require, exports, module)->
	aJazz.View.extend
		template: ->
			@options.msg
			