Q = require 'kew'
Table = require '../controllers/table'

ERR_BAD_TOKEN = 'err_bad_token'

class Reset extends Table

  table: 'reset'

  setup: ->

    @_createTable (table) =>

      table.primary(['userId', 'token'])

      table.integer('userId').unsigned()
        .references('id').inTable('user')
        .onDelete('cascade')
        .onUpdate('cascade')

      table.string('token', 22)
      table.timestamp('created_at').defaultTo @query.raw 'now()'

      # CREATE TABLE IF NOT EXISTS `reset` (
      #   `userId`      int(11)        unsigned   NOT NULL,
      #   `token`        char(22)                  NOT NULL,
      #   `created_at`   timestamp                 NOT NULL    DEFAULT CURRENT_TIMESTAMP,
      #   PRIMARY KEY (`userId`,`token`),
      #   CONSTRAINT `reset_userId` FOREIGN KEY (`userId`)
      #   REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
      # ) ENGINE=InnoDB DEFAULT CHARSET=latin1;


  create: (id, token) ->

    promise = @_create 'userId',
      userId: id
      token: token

    promise.then ->
      return id + '_' + token


  read: (token) ->

    match = @_parseToken(token)
    unless match then return Q.reject ERR_BAD_TOKEN

    promise = @_search 'userId',
      userId: match[0]
      token: match[1]

    promise
      .then (rows) -> return rows[0].userId
      .fail -> throw ERR_BAD_TOKEN

  update: ->

    throw new Error 'Cannot update a reset token'


  destroy: (token) ->

    match = @_parseToken(token)
    unless match then return Q.reject ERR_BAD_TOKEN

    @_delete
      userId: match[0]
      token: match[1]


module.exports = Reset