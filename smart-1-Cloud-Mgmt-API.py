#!/usr/bin/env python3
"""
This script will use the provided variables from tfvard.tf to login to the mgmt instance
and configure the gateway we deployed on Azure.
"""

import argparse
import requests
import json
import logging
import sys
import time

logging.basicConfig(level=logging.WARNING)
log = logging.getLogger(__name__)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--context", required=True)
    parser.add_argument("-d", "--domain", required=False)
    parser.add_argument("-i", "--instance", required=True)
    parser.add_argument("-k", "--apikey", required=True)
    parser.add_argument(
        "-g", "--gateway", help="We use the Gateway Name which is formed from the variable company and a suffix 'company-cp-gw'")
    parser.add_argument("-v", "--version", required=True,
                        help="used to set the Gateway version")
    parser.add_argument("-s", "--sickey", required=True)
    parsed_args = parser.parse_args()

    login_URL = f"https://{parsed_args.instance}.maas.checkpoint.com/{parsed_args.context}/web_api/login"

    login_payload = json.dumps({
        "api-key": parsed_args.apikey,
    })

    headers = {
        'Content-Type': 'application/json'
    }

    # Here we use the parameters to login to the API and get a session ID (SID)
    login_res = requests.request(
        "POST", login_URL, headers=headers, data=login_payload)

    if login_res.status_code != 200:
        print("Login failed:\n{}".format(login_res.text))
        exit(1)
    else:
        sid = login_res.json()['sid']
        print(f" Login Sucess. Session-id: {sid}")

    show_gateway_config_URL = f"https://{parsed_args.instance}.maas.checkpoint.com/{parsed_args.context}/web_api/show-simple-gateway"

    gateway_config_URL = f"https://{parsed_args.instance}.maas.checkpoint.com/{parsed_args.context}/web_api/set-simple-gateway"
    gateway_config_payload = json.dumps({
        "name": parsed_args.gateway,
        "one-time-password": parsed_args.sickey,
        "version": parsed_args.version
    })

    headers = {
        'Content-Type': 'application/json',
        'X-chkp-sid': sid
    }

    # establish SIC for the gateway
    while True:
        gateway_config_res = requests.request(
            "POST", show_gateway_config_URL, headers=headers, json={"name": parsed_args.gateway})
        if gateway_config_res.status_code == 200:
            gateway_set_config_res = requests.request(
                "POST", gateway_config_URL, data=gateway_config_payload, headers=headers)

            if gateway_set_config_res.json()['sic-state'] == 'communicating':
                print('SIC is communicating')
                break
        elif gateway_config_res.status_code != 404:
            print(f"Unexpected code: {gateway_config_res.status_code}")
            print(gateway_config_res.text)
            sys.exit(1)
        print("gateway is not ready to establish SIC. Trying again in 10 seconds")
        time.sleep(10)

    # change clean up rule to accept and log all traffic
    set_policy_URL = f"https://{parsed_args.instance}.maas.checkpoint.com/{parsed_args.context}/web_api/set-access-rule"
    set_policy_payload = json.dumps({
        "name": "Clean up",
        "action": "accept",
        "track": {"type": "log"}
    })

    headers = {
        'Content-Type': 'application/json',
        'X-chkp-sid': sid
    }

    set_policy_res = requests.request(
        "POST", set_policy_URL, headers=headers, data=set_policy_payload)

    print(set_policy_res)

    # publish everything
    publish_URL = f"https://{parsed_args.instance}.maas.checkpoint.com/{parsed_args.context}/web_api/publish"

    publish_res = requests.request(
        "POST", publish_URL, headers=headers, json={})

    print(f'publish ended with {publish_res.text}')

    # Install Access Policy
    time.sleep(10) # give the publish operation time to finish before we install polciy
    install_policy_URL = f"https://{parsed_args.instance}.maas.checkpoint.com/{parsed_args.context}/web_api/install-policy"
    install_policy_payload = {
        "policy-package": "Standard",
        "targets": parsed_args.gateway,
        "access": "True",
        "threat-prevention": "False"
    }

    install_policy_res = requests.request(
        "POST", install_policy_URL, headers=headers, json=install_policy_payload)
    print(f"Policy Installation ended with: {install_policy_res.text}")

    task_id = install_policy_res.json()['task-id']
    show_policy_install_status = f"https://{parsed_args.instance}.maas.checkpoint.com/{parsed_args.context}/web_api/show-task"

    show_policy_install_payload = json.dumps({
        "task-id": task_id,
    })

    while True:
        show_policy_install_res = requests.request(
            "POST", show_policy_install_status, headers=headers, data=show_policy_install_payload)
        if show_policy_install_res.json()['tasks'][0]['status'] == "in progress":

            print(
                "Installing Access policy in progress, waiting for 20 Seconds to succeed")
            time.sleep(20)

        elif show_policy_install_res.json()['tasks'][0]['status'] == "succeeded":
            install_policy_payload['access'] = False
            install_policy_payload['threat-prevention'] = True
            install_policy_res = requests.request(
                "POST", install_policy_URL, headers=headers, json=install_policy_payload)
            print(f"installing threat policy ended with {install_policy_res}")
            break

        else:
            print(show_policy_install_res.json()['tasks'][0]['status'])
            break

    # logging out
    logout_URL = f"https://{parsed_args.instance}.maas.checkpoint.com/{parsed_args.context}/web_api/logout"

    logout_res = requests.request(
        "POST", logout_URL, headers=headers, json={})
    print(f"logout response: {logout_res}")


if __name__ == '__main__':
    main()
