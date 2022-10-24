load("cirrus", "env", "fs")

def main(ctx):
    return fs.read(".cirrus.aws.yml") + fs.read(".cirrus.build.yml")
