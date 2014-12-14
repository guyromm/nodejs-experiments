Hapi = require 'hapi'
Good = require 'good'
ECT  = require 'ect'
Boom = require 'boom'
nano = require('nano')('http://localhost:5984/')
util = require 'util'

db = nano.use 'vrealtor'


renderer = ECT
        root: __dirname+'/views'
        watch: true

server = new Hapi.Server()
server.connection port: 3000
server.decorate 'reply', 'tpl', (tpl,data) ->
        return @response (renderer.render tpl, data)
i=0

server.route
        method: 'GET'
        path: '/'
        handler: (request, reply) =>
                i+=1
                data =
                        title : 'Hello, world!'
                        id : 'main'
                        counter : i
                        links: [
                                {name : 'Twitter', url :  'http://twitter.com/'}
                                {name : 'Google', url: 'http://google.com/'}]
                        upperHelper : (string) => string.toUpperCase()
                server.log 'about to call in the cavalry'
                reply.tpl 'page', data

server.route
        method: 'GET'
        path: '/{name}'
        handler: (request, reply) =>
                i+=1
                doc = {key: 'value', key2: 'value2','value':request.params.name,'counter':i}
                db.insert doc, (error,http_body,http_headers) =>
                        if error then return reply new Boom.badImplementation error
                        strg = JSON.stringify doc
                        id = http_body.id
                        return reply ('Hello, '+id+'\n'+request.params.name+'!\n'+strg+'\n')

server.route
        method: 'GET'
        path: '/get/{id}'
        handler: (request, reply) =>
                db.get request.params.id, (err,res) =>
                        if err then return reply new Boom.notFound err.message
                        reply.tpl 'item', {obj:res}
server.route
        method: 'GET'
        path: '/favicon.ico'
        handler: (request, reply) =>
                return reply 'No icon here, go away.'
                
server.route
        method: 'GET'
        path: '/inspect'
        handler: (request, reply) =>
                db.view 'default', 'all',{},(err,body) =>
                        if err then return reply new Boom.badImplementation err
                        data =
                                upperHelper: (string) => string.toUpperCase()
                                id: 'docs'
                                tot_rows: body.total_rows
                                title: "Our docs"
                                docs: body.rows
                        reply.tpl 'docs', data

server.register
        register: Good
        options:
                reporters: [
                        reporter: require 'good-console'
                        args: [
                                log: '*'
                                response: '*'
                                ]
                           ]
        , (err) =>
                if err then throw err
                server.start =>
                        server.log 'info','Server running at: '+server.info.uri
                        
        
                                          
        
