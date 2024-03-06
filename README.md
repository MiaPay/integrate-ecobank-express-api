# README

This README would normally document whatever steps are necessary to get the
application up and running.

## Tech Stack

- Ruby: 3.x

## Setup

```
gem install httparty
```
- open ecobank_express_api.rb file to change the constants API_CONFIG and ACCESS_TOKEN
- The constant ACESS_TOKEN can be generated from `EcobankExpressAPI.generate_token`
 method, or you can generate it manually from Token Generation API

## Test

- Execute command `ruby ecobank_express_api.rb` to call the ecobank interfaces
- If you only want to call one of the interfaces, you can comment out the other calling methods.

For example, if you only want to call the Create Account Opening interface, the code at the bottom of the "ecobank_express_api.rb" file becomes:
```
# EcobankExpressAPI.generate_token
# EcobankExpressAPI.check_secure_hash
EcobankExpressAPI.create_account_opening
# EcobankExpressAPI.get_merchant_category_code
# EcobankExpressAPI.create_merchant_qrcode
# EcobankExpressAPI.dynamic_qr_payment
# EcobankExpressAPI.payment
# EcobankExpressAPI.transaction_enquiry
# EcobankExpressAPI.get_account_balance
# EcobankExpressAPI.get_account_enquiry
```
Then save the file and re-execute the command `ruby ecobank_express_api.rb`
