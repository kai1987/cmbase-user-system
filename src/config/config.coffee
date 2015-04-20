
path = require('path')
#rootPath = path.normalize(__dirname + '/../..')
rootPath = process.cwd()
console.log "[config::rootPath] #{rootPath}"


templatePath = path.normalize(__dirname + '/../app/mailer/templates')
notifier =
  APN: false,
  email: false, # true
  actions: ['comment'],
  tplPath: templatePath,
  postmarkKey: 'POSTMARK_KEY',
  parseAppId: 'PARSE_APP_ID',
  parseApiKey: 'PARSE_MASTER_KEY'

module.exports =
  development:
    db: 'mongodb://192.168.1.119/cmbase_dev',
    root: rootPath,
    notifier: notifier,
    app:
      name: 'CMBase user system'
  test:
    db: 'mongodb://localhost/cmbase_test',
    root: rootPath,
    notifier: notifier,
    app:
      name: 'CMBase user system'
  production:
    db: 'mongodb://localhost/cmbase_mc',
    root: rootPath,
    notifier: notifier,
    app:
      name: 'CMBase user system'




