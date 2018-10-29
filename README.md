# elastisys-pom-root

This repository contains the root POM file for Elastisys Java projects.

It configures a basis of build plugins and leaves some placeholders to be filled
in by inheriting projects. For example, inheriting projects that intend to build
executable all-in-one jar files that also get packaged into Docker images need
to specify the following properties (unless the defaults are acceptable):

- `${shade.mainClass}`: The fully qualified class name of the class that will
  act as Main class in the executable jar built by the maven shade plugin.

- `${docker.registry}`: the targeted docker registry. For example,
  `index.docker.io/v1/` for Docker Hub or `my.private.registry:5000` for a
  private registry.

- `${docker.repo}`: a naming template for naming the repo of a certain image.
  By default, this is set to `${docker.registry}/${docker.image}` which is
  suitable for a private registry, while simply setting this to
  `${docker.image}` would suffice for Docker Hub.

- `${docker.image}`: a naming template for the Docker image name. Individual
  child projects should override this unless the default image name template
  (`elastisys/${project.artifactId}`) is suitable.



So, a child project that wishes to produce an executable jar file and a Docker
image must place a `Dockerfile` in `src/main/docker` and specify something
similar to this in the `pom.xml`:

    <properties>
      <-- The name of the docker image -->
      <docker.image>elastisys/openstackpool</docker.image>
      <!-- The Main class of the executable jar file to build -->
      <shade.mainClass>com.elastisys.scale.cloudpool.openstack.server.Main</shade.mainClass>
    </properties>

    ...

    <build>
      <plugins>
        <!-- Build a standalone executable jar file that embeds all classpath dependencies. -->
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-shade-plugin</artifactId>
        </plugin>

        <!-- Builds a Docker image -->
        <plugin>
          <groupId>com.spotify</groupId>
          <artifactId>docker-maven-plugin</artifactId>
        </plugin>

      </plugins>
    </build>



## Releasing

The root POM does not include a distribution repository (with the intent of
specifying that in inheriting projects). Instead, when deploying, use the
`release.sh` script:

    release.sh

**NOTE** that _after_ deploying to the staging repository, you need to head to
https://oss.sonatype.org/#stagingRepositories and approve the release. Go to
staging repositories, search for `elastisys` or similar to find the released
repository. Then "Close" the repository (takes some time, you may need to
refresh) and finally "Release" the repository. Only after this step has been
completed will the released artifacts show up in the public Maven repo under
https://oss.sonatype.org/content/groups/public/com/elastisys/.
