core = require('../../core/api')
config = require('../../config')
log = require('log_')('Route -> Reset', 'yellow')

# -----------------------------------------------------------------------------
# Reset Password
# -----------------------------------------------------------------------------

resetPage = (req, res) ->
  res.sendfile page 'reset'

sendEmail = (req, res) ->
  email = req.body.email.toLowerCase()

  log email, 'wants to reset their password'

  Auth.createResetToken(email)
    .then (token) ->

      link = config.url + '/reset/' + token

      if global.DEBUG_ROUTES
        return res.send link

    .catch (err) ->
      log err
      log email, 'do not get a token'
      res.status 400
      if global.DEBUG_ROUTES
        res.send 'error'
      else
        res.sendfile page 'error'

confirmToken = (req, res) ->
  token = req.params.token

  db.reset.read(token)
    .then ->
      res.sendfile page 'reset_form'
    .catch (err) ->
      if global.DEBUG_ROUTES
        res.send 'error'
      else
        res.sendfile page 'error'

resetPassword = (req, res) ->
  password = req.body.password
  confirmation = req.body.passwordConfirmation
  token = req.params.token

  log 'validating passwords for', token

  if password isnt confirmation
    log 'password mismatch'
    res.status 401
    res.sendfile page 'reset_mismatch'
    return

  db.reset.read(token)
    .then (id) ->
      log 'removing token', token
      db.reset.destroy(token)
      Users.read(id)
    .then (user) ->
      log 'changed password for', user.email
      Auth.changePassword user, password
    .then ->
      res.sendfile page 'reset_success'
    .catch (err) ->
      log err
      res.status 401
      res.send err


module.exports = [

  type: 'get'
  url: '/reset'
  handler: resetPage

,

  type: 'post'
  url: '/reset'
  handler: sendEmail

,


  type: 'get'
  url: '/reset/:token'
  handler: confirmToken

,

  type: 'post'
  url: '/reset/:token'
  handler: resetPassword

]