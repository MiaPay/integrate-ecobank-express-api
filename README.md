# README

This README would normally document whatever steps are necessary to get the
application up and running.

## Tech Stack

- Ruby: 3.0.2
- Rails: 6.1.4

## Setup

```
intsall psql & redis
git clone git@github.com:MiaPay/integrate-ecobank-express-api.git
echo "<master.key>" > config/master.key
#yarn install
bundle install
rails db:create db:migrate db:seed
```

Or you can go to the single_file directory, and just follow the readme(in the single_file directory) to execute “ecobank_express_api.rb” ruby file. This way you don’t need to setup the rails service.

## Test

- Execute command `rails console` to enter the console
- Then you can call the encapsulated method to call the ecobank interface, such as `EcobankExpress::API.create_account_opening `
