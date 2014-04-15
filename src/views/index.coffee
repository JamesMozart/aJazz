###
Index page view class
###
define (require, exports, module)->
	TransView = require "views/TransView"
	TransView.extend
		className: "page"
		template: template require "templates/index.html"