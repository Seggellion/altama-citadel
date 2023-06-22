# what is altama citadel?

Altama Citadel is a companion OS for [Star Citizen](https://robertsspaceindustries.com/star-citizen/play-now) brought to you by [Altama Energy](https://altama.energy/)


# development

## install for macos

- Install ruby 3

- `sudo gem install rails`

- (may have to restart terminal)

- `bundle install`

- `rails db:create:migrate`

- `rails db:seed`
- in order for your dev user account to access all apps in citadel, run `rails c` and set `User.first.update(rsi_verify: true, user_type: 0)`

### potential install errors:
- [fatal password authentication failed for user](https://stackoverflow.com/questions/55038942/fatal-password-authentication-failed-for-user-postgres-postgresql-11-with-pg): `psql -U postgres` and create new password with \password. in database.yml, set user to `postgres` and set password to the password you just created. **be sure not to commit the database.yml file with your password**
- `initialize': Address already in use - bind(2) for "127.0.0.1" port 3000 (Errno::EADDRINUSE)`: ` killall -9 ruby`

