import base64
from google.cloud import kms_v1
import os

# CONSTANTS
PROJECT_ID = os.environ['GCP_PROJECT']
LOCATION_ID = 'global'
KEY_RING_ID = os.environ['KEY_RING_ID']
KEY_ID = os.environ['KEY_ID']

KMS_CLIENT = kms_v1.KeyManagementServiceClient()
CRYPTO_KEY = KMS_CLIENT.crypto_key_path_path(PROJECT_ID, LOCATION_ID, KEY_RING_ID, KEY_ID)

# FUNCTIONS
def decrypt(ciphertext_in_base64):
    ciphertext = base64.b64decode(ciphertext_in_base64)
    decrypt_response = KMS_CLIENT.decrypt(CRYPTO_KEY, ciphertext)
    decrypted_string = decrypt_response.plaintext.decode()

    return decrypted_string
