import os
import jwt
import base64
from functools import wraps
from flask import request, abort, make_response, jsonify

import kms_utilities

# CONSTANTS
APPROOV_SECRET_ENCRYPTED_BASE64 = os.environ['APPROOV_SECRET_ENCRYPTED_BASE64']
APPROOV_SECRET = kms_utilities.decrypt(APPROOV_SECRET_ENCRYPTED_BASE64)

# FUNCTIONS
def check_approov_token(callback):

    @wraps(callback)
    def decorated(*args, **kwargs):

        approov_token = request.headers.get('Approov-Token')

        if approov_token is None:
            print('Missing Approov-Token.')
            abort(make_response(jsonify({}), 400))

        elif verifyApproovToken(approov_token) is None:
            abort(make_response(jsonify({}), 400))

        else:
            return callback(*args, **kwargs)

    return decorated

def verifyApproovToken(token):
  try:
    tokenContents = jwt.decode(token, base64.b64decode(APPROOV_SECRET), algorithms=['HS256'])
    return tokenContents

  except jwt.ExpiredSignatureError as e:
    print('Expired Approov-Token: ' + token)
    return None

  except jwt.InvalidTokenError as e:
    print('Invalid Approov-Token: ' + token)
    return None
