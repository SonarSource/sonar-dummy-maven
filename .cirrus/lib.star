load("cirrus", "fs", "re", "yaml")


# load("github.com/cirrus-modules/helpers", "task", "container", "script")

def get_aws_account(environment="prod"):
    if environment == "prod":
        return "275878209202"
    elif environment == "staging":
        return "166916561812"
    elif environment == "sandbox":
        return "501215020883"
    elif environment == "dev":
        return "460386131003"
    else:
        return None


def get_aws_subnet(environment="prod"):
    if environment == "prod":
        return "subnet-063c427f490da35b9"
    elif environment == "staging":
        return "subnet-0a586a671ae59a796"
    else:
        return None


def auth(host="aws", env_type="prod", cluster_name="CirrusCI"):
    if host == "aws":
        return yaml.dumps({
            "aws_credentials": {
                "role_arn": "arn:aws:iam::" + get_aws_account(env_type) + ":role/" + cluster_name,
                "role_session_name": "cirrus",
                "region": "eu-central-1"
            }
        })
    elif host == "gcp":
        return yaml.dumps({
            "gcp_credentials": "ENCRYPTED[!149d4005ecdba4cdd78bb5ba22756ebb98bf8e3367ee2e9ab08c5a1608c0d3e3b501904b67a1d67c0b63085e469d7dde!]"
        })


def parse(build_file=".cirrus/build.yml", env_type="prod", subnet_id=None):
    """
    Parse the build file for replacement of the following strings:
    - CIRRUS_AWS_ACCOUNT
    - CIRRUS_AWS_SUBNET
    :param build_file: Cirrus YAML file to parse for replacement
    :param env_type: prod, staging, sandbox or dev; this determines the value for CIRRUS_AWS_ACCOUNT
    :param subnet_id: AWS subnet ID
    """
    if subnet_id == None:
        subnet_id = get_aws_subnet(env_type)
    build_yaml = fs.read(build_file)
    build_yaml = build_yaml.replace('${CIRRUS_AWS_ACCOUNT}', get_aws_account(env_type))
    build_yaml = build_yaml.replace('${CIRRUS_AWS_SUBNET}', subnet_id)
    return build_yaml
