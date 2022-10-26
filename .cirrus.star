load("github.com/SonarSource/cirrus-modules@3560618c4ade82152008a15ca82f1bc80ed5e91e", "auth", "parse") # tag=0.0.1

def main(ctx):
    return auth() + parse(".cirrus/build.yml")
