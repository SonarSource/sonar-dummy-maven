load("github.com/SonarSource/cirrus-modules", "auth", "parse")

def main(ctx):
    return auth() + parse(".cirrus/build.yml")
