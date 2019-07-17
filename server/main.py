import requests
import flask
import os
import base64
import sys
import decimal

from google.cloud import kms_v1
from google.oauth2 import service_account

import api_key_decorator
import approov_decorator
import kms_utilities

# CONSTANTS
API_KEY_CURRENCY_CONVERTER_ENCRYPTED_BASE64 = os.environ['API_KEY_CURRENCY_CONVERTER_ENCRYPTED_BASE64']
API_KEY_CURRENCY_CONVERTER = kms_utilities.decrypt(API_KEY_CURRENCY_CONVERTER_ENCRYPTED_BASE64)

# FUNCTIONS
# TODO - PUT BACK - @api_key_decorator.check_api_key
@approov_decorator.check_approov_token
def http(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    # Parse request
    body = request.get_json(silent=True)
    from_currency = body['from_currency']
    to_currency = body['to_currency']
    amount = body['amount']

    return call_currency_converter_api(API_KEY_CURRENCY_CONVERTER, from_currency, to_currency, amount)
    
def call_currency_converter_api(api_key, from_currency, to_currency, amount):
    from_to = '{}_{}'.format(from_currency, to_currency).upper()
    url = 'https://free.currconv.com/api/v7/convert?q={}&compact=ultra&apiKey={}'.format(from_to, api_key)
    response = requests.get(url)
    json_response = response.json()
    exchange_rate = json_response[from_to]

    # Truncate to 2 decimal digits
    total_amount = '%.2f'%(decimal.Decimal(exchange_rate) * decimal.Decimal(amount))
    flask_response = flask.jsonify(to_json_response(total_amount))
    return flask_response

def to_json_response(amount):
    json = {
        "amount": amount,
    }

    return json
