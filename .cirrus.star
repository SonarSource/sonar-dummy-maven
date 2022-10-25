load("cirrus", "env", "fs")
load(".cirrus/lib.star", "auth", "parse")
# load("github.com/SonarSource/sonar-dummy", "creds")

def main(ctx):
    return auth() + parse(".cirrus/build.yml")
