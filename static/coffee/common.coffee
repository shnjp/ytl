global = @

###
最初の引数で、trueかfalseか分ける
###
$.fn.add_or_remove_class = (do_add, args...) ->
  if do_add
    f = this.addClass
  else
    f = this.removeClass
  f.apply(this, args)


###
mongoなjsonをjsで扱いやすく変更
###
_.mixin
  from_mongo: (object_or_array) ->
    if _.isArray(object_or_array)
      return _.map(object_or_array, (value) -> return _.from_mongo(value))
    else if _.isObject(object_or_array)
      if object_or_array.$oid?
        return object_or_array.$oid
      else if object_or_array.$date?
        return moment(object_or_array.$date)
      else
        obj = {}
        _.each object_or_array, ((value, key) ->
          @[key] = _.from_mongo(value)), obj
        return obj
    else
      return object_or_array
