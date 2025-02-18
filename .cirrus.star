load("github.com/SonarSource/cirrus-modules@74c00b08bd556f6f6f59cc244941f0a815d79e42", "load_features") # 3.3.0
load("cirrus", "env", "fs", "yaml")

def main(ctx):
    if env.get("CIRRUS_REPO_FULL_NAME") == 'SonarSource/sonar-dummy-maven-enterprise' and fs.exists("private/.cirrus.yml"):
        features = yaml.dumps(load_features(ctx, only_if=dict()))
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
