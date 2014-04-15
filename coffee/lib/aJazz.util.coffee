###
JavaScript Document, by 梁达俊
	aJazz.util util functions
version 1.0
###
aJazz.util =
	###
	convert query string to json object
	@param  {String} str
	@return {Object}
	###
	deparam: (str) ->
		pattern = /([^&=#?]+)=([^&=#?]*)/g
		data = {}
		query = str.replace /\+/g, "%20"
		while row = pattern.exec query
			rowHead = decodeURIComponent row[1]
			isArray = (rowHead.indexOf "[]") > -1
			rowHead = rowHead.replace "[]", ""
			rowBody = decodeURIComponent row[2]
			if rowHead of data
				# convert into array if more than 1 param have the same name
				!(data[rowHead] instanceof Array) && data[rowHead] = [data[rowHead]]
				data[rowHead].push rowBody
			else if isArray
				data[rowHead] = [rowBody]
			else
				data[rowHead] = rowBody
		data
	###
	move object child node to another object
	###
	moveTo: (toObj, formObj, key) ->
		if formObj[key]?
			toObj[key] = formObj[key]
			delete formObj[key]
	createFactory: (Class, options) ->
		-> new Class options
	###
	extend from a super class
	###
	extendClass: (params, classProp) ->
		extend = arguments.callee
		class newClass extends @
			@extend: extend
		$.extend newClass::, params
		$.extend newClass, classProp
		newClass
	getFuncOrValue: (dataItem, args = [], context) ->
		if typeof dataItem is "function"
			dataItem.apply context, args
		else dataItem
	###
	validate data
	@param  {Object<message:String|pattern:RegExp|value:String>} 	options
	@param {Boolean}		fullValidation		validate all fields or stop when get an error default:false
	@return {Array<error:String|message:String>}       error key:error message pairs
	###
	validate: (options, fullValidation) ->
		errors = []
		for key,item of options
			value = if item.value? then item.value else ""
			if !item.pattern.test item.value
				errors.push
					error: key,
					message: item.message
				if !fullValidation
					break
		if errors.length > 0
			errors
		else true