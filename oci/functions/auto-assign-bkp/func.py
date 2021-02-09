# auto-assign-bkp
# This script runs after Block Volume Creation and assing the Gold backup pol.
# This is based on https://github.com/oracle/oracle-functions-samples/tree/master/samples/oci-stop-untagged-instance-python


import io
import json
from fdk import response

import oci

volume_backup_policy = "ocid1.volumebackuppolicy.oc1..aaaaaaaagcremuefit7dpcnjpdrtphjk4bwm3emm55t6cghctt2m6iyyjdva"


def handler(ctx, data: io.BytesIO = None):

    resp = None

    try:
        body = json.loads(data.getvalue())
        jsondata = body.get("data")

        print("Event          : " + body["eventType"], flush=True)
        print("Disk ID        : " +
              body["data"]["resourceId"], flush=True)
        print("Disk Name       : " +
              body["data"]["resourceName"], flush=True)
        print("When : " + body["eventTime"], flush=True)

        print(json.dumps(body, indent=4), flush=True)

        instanceId = body["data"]["resourceId"]
        signer = oci.auth.signers.get_resource_principals_signer()

        resp = do(signer, instanceId)

        return response.Response(
            ctx, response_data=json.dumps(resp),
            headers={"Content-Type": "application/json"}
        )
    except (Exception, ValueError) as e:
        print("Error " + str(e), flush=True)


def do(signer, instanceId):

    print("Assigning Bkp pol", flush=True)

    block_storage_client = oci.core.BlockstorageClient({}, signer=signer)
    create_response = block_storage_client.create_volume_backup_policy_assignment(
        oci.core.models.CreateVolumeBackupPolicyAssignmentDetails(
            asset_id=instanceId,
            policy_id=volume_backup_policy
        )
    )
