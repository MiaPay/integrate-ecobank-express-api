
# test code to access the EcoBank XpressAccount API
# documentation: https://documenter.getpostman.com/view/9576712/2s7YtWCtNX#intro


# frozen_string_literal: true
require "httparty"

class EcobankExpressAPI
  include HTTParty
  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error
  ]
  HTTPARTY_TIMEOUT = 10
  RETRY_TIMES = 3
  API_CONFIG = {
    # credentials available in accompanying google doc
  }
  # ACCESS_TOKEN
  ACCESS_TOKEN = nil 

  base_uri "https://developer.ecobank.com"

  def self.generate_token
    tries = RETRY_TIMES
    body = {
      userId: API_CONFIG[:user_id],
      password: API_CONFIG[:password]
    }
    headers = {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Origin" => "developer.ecobank.com",
    }
    response = begin
                  post("/corporateapi/user/token", body: JSON.pretty_generate(body), headers: headers, timeout: HTTPARTY_TIMEOUT)
              rescue *HTTP_ERRORS => error
                if (tries -= 1) > 0
                  retry
                else
                  raise "ecobank express api timeout"
                end
              rescue StandardError => error
                raise "ecobank express api error: #{error.message}"
              end
    #puts "token: #{response["token"]}"
    response["token"]
  end

  def self.get_token
    ACCESS_TOKEN || generate_token
  end

  def self.request_api(path, body)
    headers = {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Origin" => "developer.ecobank.com",
      "Authorization" => "Bearer #{get_token}"
    }
    puts ">>>>>>>>>>> request:"
    puts JSON.pretty_generate({method: 'post', url: path, body: body})
    response = begin
                post(path, body: JSON.pretty_generate(body), headers: headers)
              rescue *HTTP_ERRORS => error
                (tries -= 1) > 0 ? retry : { "msg" => "Timeout" }
              end
    puts "<<<<<<<<<<< response:"
    pp response 
    puts
    puts
    response
  end

  def self.generate_secure_hash(body)
    body.delete(:secureHash)
    body.delete(:secure_hash)
    payload = body.values.join("")
    data = payload + API_CONFIG[:lab_key]
    digest = Digest::SHA512.new
    hash_bytes = data.encode("UTF-8")
    message_digest = digest.digest(hash_bytes)
    result = message_digest.unpack1('H*')
  end

 

  TEST_SECURE_HASH_PARAMETERS = {
      "param1": "Aymard",
      "param2": "Gildas",
      "param3": "MILANDOU",
      "param4": "Ecobank",
      "param5": "Group"
    }

  TEST_ACCOUNT_CREATION_PARAMETERS = {
      "requestId": "ECO76383823",
      "affiliateCode": "ENG",
      "firstName": "Rotimi",
      "lastname": "Akinola",
      "mobileNo": "2348089991325",
      "gender": "M",
      "identityNo": "198837383982",
      "identityType": "MOBILE_WALLET_NO",
      "IDIssueDate": "01072021",
      "ccy": "NGN",
      "country": "NGN",
      "branchCode": "ENG",
      "datetime": "01072021",
      "countryOfResidence": "NIGERIA",
      "email": "treknfreedom@yahoo.com",
      "city": "Accra",
      "state": "Accra",
      "street": "Labone",
  }



 # Execute statement in rails console: `EcobankExpressAPI.check_secure_hash`
  # response_message: "success"
  def self.check_secure_hash

    puts "Testing with the secureHash examples - this SUCCEEDS"
    body = TEST_SECURE_HASH_PARAMETERS
    body = body.merge(
      secureHash: generate_secure_hash(body)
    )
    request_api("/corporateapi/merchant/securehash", body)
    
    puts "Testing with the creatAccount example - this FAILS"
    body = TEST_ACCOUNT_CREATION_PARAMETERS
    body = body.merge(
      secureHash: generate_secure_hash(body)
    )
    request_api("/corporateapi/merchant/securehash", body)
  end



































  # Execute statement in rails console: `EcobankExpressAPI.create_account_opening`
  # response_message: "Invalid security parameters provided"
  def self.create_account_opening_succeeds
    body = TEST_ACCOUNT_CREATION_PARAMETERS
    request_api("/corporateapi/merchant/createexpressaccount", body)
  end

   def self.create_account_opening_fails
    body = TEST_ACCOUNT_CREATION_PARAMETERS
    body = body.merge(
      "secureHash" => generate_secure_hash(body)
    )
    request_api("/corporateapi/merchant/createexpressaccount", body)
  end



































  # Execute statement in rails console: `EcobankExpressAPI.get_merchant_category_code`
  # Success
  def self.get_merchant_category_code
    body = {
      "requestId": "123344",
      "affiliateCode": "EGH",
      "requestToken": "/4mZF42iofzo7BDu0YtbwY6swLwk46Z91xItybhYwQGFpaZNOpsznL/9fca5LkeV",
      "sourceCode": "ECOBANK_QR_API",
      "sourceChannelId": "KANZAN",
      "requestType": "CREATE_MERCHANT"
    }
    request_api("/corporateapi/merchant/getmcc", body)
  end





















  # Execute statement in rails console: `EcobankExpressAPI.create_merchant_qrcode`
  # Using secure_hash in the test case, the result is success,
  #   but the secure_hash generated by ourselves will report an error: "Invalid security parameters provided"
  def self.create_merchant_qrcode
    body = {
      "headerRequest": {
          "requestId": "",
          "affiliateCode": "EGH",
          "requestToken": "/4mZF42iofzo7BDu0YtbwY6swLwk46Z91xItybhYwQGFpaZNOpsznL/9fca5LkeV",
          "sourceCode": "ECOBANK_QR_API",
          "sourceChannelId": "KANZAN",
          "requestType": "CREATE_MERCHANT"
      },
      "merchantAddress": "Labone",
      "merchantName": "UNIFIED SHOPPING CENTER",
      "accountNumber": "02002233444",
      "terminalName": "UNIFIED KIDS SHOPPING ARCADE",
      "mobileNumber": "2348089991325",
      "email": "treknfreedom@yahoo.com",
      "area": "Accra",
      "city": "Accra",
      "referralCode": "123456",
      "mcc": "0000",
      "dynamicQr": "N",
      "callBackUrl": "http://koala.php",
      "secure_hash": "7f137705f4caa39dd691e771403430dd23d27aa53cefcb97217927312e77847bca6b8764f487ce5d1f6520fd7227e4d4c470c5d1e7455822c8ee95b10a0e9855"
    }
    # # generate the secure_hash by ourselves
    # body = body.merge(
    #   "secure_hash" => generate_secure_hash(body["headerRequest"])
    # )
    request_api("/corporateapi/merchant/createqr", body)
  end

















  # Execute statement in rails console: `EcobankExpressAPI.create_merchant_qrcode`
  # Using secure_hash in the test case, the result is success,
  #   but the secure_hash generated by ourselves will report an error: "Invalid security parameters provided"
  def self.dynamic_qr_payment
    body = {
      "ec_terminal_id": "20240305",
      "ec_transaction_id": "20240305001",
      "ec_amount": 200,
      "ec_charges": "0",
      "ec_fees_type": "P",
      "ec_ccy": "KES",
      "ec_payment_method": "QR",
      "ec_customer_id": "OK2024/01",
      "ec_customer_name": "Customer name",
      "ec_mobile_no": "8615748957846",
      "ec_email": "customer@test.com",
      "ec_payment_description": "PAYMENT FOR JUMIA SHOPPING",
      "ec_product_code": "Product Code",
      "ec_product_name": "Product Name",
      "ec_transaction_date": "2024-03-05",
      "ec_affiliate": "BS",
      "ec_country_code": "86",
      "secure_hash": "7f137705f4caa39dd691e771403430dd23d27aa53cefcb97217927312e77847bca6b8764f487ce5d1f6520fd7227e4d4c470c5d1e7455822c8ee95b10a0e9855"
    }
    # # generate the secure_hash by ourselves
    # body = body.merge(
    #   "secure_hash" => generate_secure_hash(body)
    # )
    request_api("/corporateapi/merchant/qr", body)
  end

  # Execute statement in rails console: `EcobankExpressAPI.payment`
  # Using secure_hash in the test case, the result is success,
  #   but the secure_hash generated by ourselves will report an error: "Invalid security parameters provided"
  def self.payment
    body = {
      "paymentHeader": {
          "clientid": "ABC123",
          "batchsequence": "1",
          "batchamount": 52,
          "transactionamount": 52,
          "batchid": "BID0305001",
          "transactioncount": 2,
          "batchcount": 2,
          "transactionid": "20240305-001",
          "debittype": "Multiple",
          "affiliateCode": "EGH",
          "totalbatches": "1",
          "execution_date": "2024-03-05 14:46:00"
      },
      "extension": [
          {
              "request_id": "RE001",
              "request_type": "token",
              "param_list": [
                  {"key":"transactionDescription", "value":"Service payment for tickets."},
                  {"key":"secretCode", "value":"AWER1235"},
                  {"key":"sourceAccount","value":"1441000565307"},
                  {"key":"sourceAccountCurrency", "value":"GHS"},
                  {"key":"sourceAccountType", "value":"Corporate"},
                  {"key":"senderName", "value":"Freeman Kay"},
                  {"key":"ccy", "value":"GHS"},
                  {"key":"senderMobileNo", "value":"0202205113"},
                  {"key":"amount", "value":"40"},
                  {"key":"senderId", "value":"QWE345Y4"},
                  {"key":"beneficiaryName", "value":"Stephen Kojo"},
                  {"key":"beneficiaryMobileNo", "value":"0233445566"},
                  {"key":"withdrawalChannel", "value":"ATM"}
                ],
              "amount": 40,
              "currency": "GHS",
              "status": "",
              "rate_type": "spot"
          },
          {
              "request_id": "RE002",
              "request_type": "INTERBANK",
              "param_list": [
                {"key":"destinationBankCode", "value":"ASB"},
                {"key":"senderName", "value":"BEN"},
                {"key":"senderAddress", "value":"23 Accra Central"},
                {"key":"senderPhone", "value":"233263653712"},
                {"key":"beneficiaryAccountNo","value":"110424812001"},
                {"key":"beneficiaryName", "value":"Owen"},
                {"key":"beneficiaryPhone", "value":"233543837123"},
                {"key":"transferReferenceNo", "value":"QWE345Y4"},
                {"key":"amount", "value":"10"},
                {"key":"ccy", "value":"GHS"},
                {"key":"transferType", "value":"spot"}
              ],
              "amount": 12,
              "currency": "GHS",
              "status": "",
              "rate_type": "spot"
          }
      ],
      "secureHash": "398d4f285cc33e12f035da19fa9d954be35afaf66816531c4f1a1aedd3c6f132a85c62b23ca12d7b9a99bf5a84fc69b66738289a70e8f8115e90ffaa060f4026"
    }
    # # generate the secure_hash by ourselves
    # body = body.merge(
    #   "secureHash" => generate_secure_hash(body["paymentHeader"])
    # )
    request_api("/corporateapi/merchant/payment", body)
  end

  # Execute statement in rails console: `EcobankExpressAPI.transaction_enquiry`
  # Using secure_hash in the test case, the result is 405 Method Not Allowed.
  #   Using the secure_hash generated by ourselves will report an error: "Invalid security parameters provided"
  def self.transaction_enquiry
    body = {
      "requestId": "23100191000000004",
      "transactionReference": "Mondayda300920222#3",
      "secureHash": "f6f7e3d907432d284431b10278c6ee1f2dfc1d8fee520a7d0933067cc5b0d5cb4da1de669dd3a34c39a11e0e4cd97d44"
    }
    # # generate the secure_hash by ourselves
    # body = body.merge(
    #   "secureHash" => generate_secure_hash(body.slice("requestId"))
    # )
    request_api("/corporateapi/merchant/ecobankafrica/transaction/enquiry", body)
  end

  # Execute statement in rails console: `EcobankExpressAPI.get_account_balance`
  # Uresponse_message: "Invalid security parameters provided"
  def self.get_account_balance
    body = {
      "requestId": "REBA001",
      "affiliateCode": "EGH",
      "accountNo": "6500184371",
      "clientId": "ECO00184371123",
      "companyName": "ECOBANK",
    }
    # generate the secure_hash by ourselves
    body = body.merge(
      "secureHash" => generate_secure_hash(body)
    )
    request_api("/corporateapi/merchant/accountbalance", body)
  end

  # Execute statement in rails console: `EcobankExpressAPI.get_account_enquiry`
  # Using secure_hash in the test case, the result is success,
  #   but the secure_hash generated by ourselves will report an error: "Invalid security parameters provided"
  def self.get_account_enquiry
    body = {
      "requestId": "REBA002",
      "affiliateCode": "EGH",
      "accountNo": "6500184371",
      "clientId": "ECO00184371123",
      "companyName": "ECOBANK TEST CO",
      "secureHash": "255c24fb0f941002af9b2f3e98d2d6ee4b10d049d255bdd47d1ca0d1ac2a70f88b704bbfc1cca534adbbbd0b310fabee9e9ac3d7ae72ad6ed7a5c8ec548fe19e"
    }
    # generate the secure_hash by ourselves
    # body = body.merge(
    #   "secureHash" => generate_secure_hash(body)
    # )
    request_api("/corporateapi/merchant/accountinquiry", body)
  end
end

#EcobankExpressAPI.generate_token
puts "Trying to test the secure hash feature"
EcobankExpressAPI.check_secure_hash
#puts "Trying to open an account"
#EcobankExpressAPI.create_account_opening_succeeds
#EcobankExpressAPI.create_account_opening_fails
#EcobankExpressAPI.get_merchant_category_code
#EcobankExpressAPI.create_merchant_qrcode
#EcobankExpressAPI.dynamic_qr_payment
#EcobankExpressAPI.payment
#EcobankExpressAPI.transaction_enquiry
#EcobankExpressAPI.get_account_balance
#EcobankExpressAPI.get_account_enquiry
