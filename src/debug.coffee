if process.env.NODE_ENV == 'production'
  module.exports = ->
    return ->
if process.env.NODE_ENV == 'development'
  module.exports = (value)->
    return (messages...)->
      console.log(value, messages...)
