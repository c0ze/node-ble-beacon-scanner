http = require('http')
express = require('express')
path = require('path')
Bleacon = require('bleacon')

stack = []
MAX_STACK_SIZE = 10

app = express()
app.set 'port', process.env.PORT || 3000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

assets = require("connect-assets")
paths = [
  "assets/js",
  "assets/css"
#  "node_modules/jquery/dist",
#  "node_modules/semantic-ui/dist"
  ]

app.use assets({paths: paths})
# app.use express.static(process.cwd() + '/public')

app.get '/', (req, res) ->
  res.render('index')

app.get '/stack', (req, res) ->
  res.write(JSON.stringify(stack));
  res.end()

http.createServer(app).listen app.get('port'), () ->
  console.log('Express server listening on port ' + app.get('port'))

Bleacon.on 'discover', (bleacon) ->
  console.log JSON.stringify(bleacon)
  stack.push(bleacon)
  if (stack.length > MAX_STACK_SIZE)
    stack.shift()

Bleacon.startScanning()
