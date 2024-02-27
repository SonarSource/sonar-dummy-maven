load("github.com/SonarSource/cirrus-modules@feature/svermeille/BUILD-4311-Add-support-for-Github-Merge-Queue-branches", "load_features")
###

def main(ctx):
    return load_features(ctx, only_if=dict())
