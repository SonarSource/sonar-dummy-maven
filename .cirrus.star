load("github.com/SonarSource/cirrus-modules@5cd6425fdb78665f07284f2c12d495618a7bbc0a", "load_features") # 3.1.0
load("cirrus", "env", "fs", "yaml")

def main(ctx):
    if env.get("CIRRUS_REPO_FULL_NAME") == 'SonarSource/sonar-dummy-maven-enterprise' and fs.exists("private/.cirrus.yml"):
        features = yaml.dumps(load_features(ctx, only_if=dict(), aws=dict(env_type="dev", cluster_name="CirrusCI-10-dev")))
        doc = fs.read("private/.cirrus.yml")
    else:
        if env.get("CIRRUS_USER_PERMISSION") in ["write", "admin"]:
            features = yaml.dumps(load_features(ctx, features=["build_number"]))
        else:
            # workaround for BUILD-4413 (build number on public CI)
            features = yaml.dumps(
                {
                    'env': {
                        'CI_BUILD_NUMBER': env.get("CIRRUS_PR", "1")
                    },
                }
            )
        doc = fs.read(".cirrus/.cirrus.yml")
    return features + doc
