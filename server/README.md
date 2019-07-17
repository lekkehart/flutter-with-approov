# currency-converter

## NOTE

The API Key check has been temporarily disabled in order to just use Approov Token security, see [main.py](./main.py).

```python
# TODO - PUT BACK - @api_key_decorator.check_api_key
@approov_decorator.check_approov_token
def http(request):
```


## Purpose

This is an GCP Cloud Function example which makes a remote API call to the  [Free Currency Converter API](https://free.currencyconverterapi.com/).

It demonstrates the following:

* Deploys an GCP cloud function by means of Serverless.
* Implements function in Python.
* Injects encrypted environment variables into the cloud function so that API keys and Approov secret do not get disclosed.
* The cloud function decrypts these values.
* It protects the API with header `Api-Key`.
* Furthermore, it even protects the API with the Approov solution.

## Prerequisites

### Setup a Trial with the Approov API Protection Solution

Approov is an API Protection Solution.

For setting up a trial see <https://approov.io/.>

### Create Serverless Project

* Install Serverless.
* Create GCP pre-requisites for Serverless, see [Google Credentials](https://serverless.com/framework/docs/providers/google/guide/credentials/), such as:
  * Create project.
  * Create service account:
    * Add keyfile.
    * Add roles, such as Deployment Manager Editor, etc.
  * Enable Google APIs, such as Google Cloud Deployment Manager, etc.
* Run Cloud Shell from <https://console.cloud.google.com>.

The Serverless project was created by means of:

```bash
serverless create --template google-python --path currency-converter
cd currency-converter

# Install plugins such as "serverless-google-cloudfunctions"
npm install
```

### Modify `serverless.yml`

#### Base Data

* region: <REGION_>
* project: <GCP_PROJECT_ID>
* credentials: /Users/<USER_>/.gcloud/<SERVICE_ACCOUNT_KEY_FILE>.json

#### Environment Variables

A number of environment variables are required both for setting up KMS as well as the actual encrypted secrets, see [serverless.yml](./serverless.yml).

```bash
functions:
  first:
...
    environment:
      KEY_RING_ID: <...>
      KEY_ID: <...>
      API_KEY_ENCRYPTED_BASE64: <...>
      API_KEY_CURRENCY_CONVERTER_ENCRYPTED_BASE64: <...>
      APPROOV_SECRET_ENCRYPTED_BASE64: <...>
```

Get an API key for the currency converter by registering at <https://free.currencyconverterapi.com/>.

Get secret for Approov by running Approov CLI tool `approov secret administration.tok -get`.

Encrypt all secrets by means of [encrypt-utility](./../../encrypt-utility/README.md). 

_NOTE!_ Make sure that the API key is BASE64 encoded before encrypting because the client (i.e. mobile app) will send the API key BASE64 encoded.

### Deploy Serverless Project into Google Cloud Functions

```bash
cd currency-converter
serverless deploy
```

## Run

Use Postman to send a POST request to the API published by `serverless deploy`.

For an example of the request body see: [request_body.json](./request_body.json).

Set the following request headers accordingly:

* Api-Key
* Approov-Token (generate one by means of Approov CLI tool `approov token -genExample my.domain.com`)

Check logs of the Google Cloud Function execution in the GCP console.

## Uninstall

```bash
serverless remove
```
