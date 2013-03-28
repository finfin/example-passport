exports.filter = (res, query, collection) ->
	limit = 20
	skip = 0
	results = null

	if query.q
		1
		#search for documents containing q
	try
		limit = Number(query.limit)
	catch err

	try
		skip = Number(query.skip)
	catch err

	cursor = collection.find({}, parseProjection(query.fields))
	cursor.skip(skip).limit(limit)
	
	cursor.toArray (err, items) ->
		res.send items


exports.parseProjection = (fields) ->
	projection = {}
	if fields instanceof String
		fields.split(",").forEach (element, index, array) ->
			projection[element] = 1
	#util.log util.inspect projection
	projection