import os
from functools import wraps
from flask import request, abort, make_response, jsonify

import kms_utilities

# CONSTANTS
API_KEY_ENCRYPTED_BASE64 = os.environ['API_KEY_ENCRYPTED_BASE64']
API_KEY = kms_utilities.decrypt(API_KEY_ENCRYPTED_BASE64)

# FUNCTIONS
def check_api_key(callback):

    @wraps(callback)
    def decorated(*args, **kwargs):

        api_key = request.headers.get('Api-Key')

        if api_key is None:
            print('Missing API Key.')
            abort(make_response(jsonify({}), 400))

        elif api_key != API_KEY:
            print('Wrong API Key. Header Api-Key: ' + api_key)
            abort(make_response(jsonify({}), 400))

        else:
            return callback(*args, **kwargs)

    return decorated
