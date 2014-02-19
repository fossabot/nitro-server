core = require('../../core/api')
log = require('log_')('Route -> Login', 'green')
token = require('../controllers/token')

# -----------------------------------------------------------------------------
# Login
# -----------------------------------------------------------------------------

login = (req, res) ->

  console.log req.user

  user =
    email: req.body.email.toLowerCase()
    password: req.body.password

  core.auth.login(user.email, user.password)
  .then (id) ->
    res.send token.createSessionToken(id)

  .catch (err) ->
    log.warn err
    res.status(401)
    res.send(err)

module.exports = [

  type: 'post'
  url: '/auth/login'
  handler: login

]
