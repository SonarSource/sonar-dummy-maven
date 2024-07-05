# sonar-dummy

A sample project used for testing purposes

This project uses **Maven** and **is not published on Maven Central** (private).

Looking for one published on Maven Central? Have a look
at [sonar-dummy-oss (use gradle)](https://github.com/SonarSource/sonar-dummy-oss)

## Release

Check the Releasability status on master. The reported version is the one that will be released.

Browse https://github.com/SonarSource/sonar-dummy/releases and make a new release with the reported version.

The build is promoted from `sonarsource-private-builds` to `sonarsource-private-releases` in Repox.
The following artifacts are
promoted: `com.sonarsource.dummy:sonar-dummy-plugin:jar`,`com.sonarsource.dummy:dummy:json:cyclonedx`.

The artifacts are available at the following locations:

- https://repox.jfrog.io/ui/native/sonarsource-private-releases/com/sonarsource/dummy/
- https://downloads.sonarsource.com/?prefix=CommercialDistribution/dummy/
- https://javadocs.sonarsource.org/?prefix=sonar-dummy/
