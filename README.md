A Docker container that runs the A-plus
mooc-grader exposed to port 8080.

Note that the MOOC-grader only provides hosting of interactive
course material. The [A-plus front](https://hub.docker.com/r/apluslms/run-aplus-front/)
is required to presenpt user interface and to store records in database.

See into the [A-plus template course](https://github.com/apluslms/course-templates)
that includes a Docker compose configuration to develop and test course content.

### Usage

Mooc grader is installed in `/srv/grader`.
You can mount development version on top of that, if you wish.

Location `/srv/data` is a volume and contains exercise data, database and secret key.
It's world writable, so you can run this container as normal user.
When running as your self, you could even bind local path to it.

Course configuration should be mounted to `/srv/courses/default`.
If you mount grader code to `/srv/grader`,
then you need to change course configuration mount to `/srv/grader/courses/default`
(remember to create that directory).

Partial example of `docker-compose.yml` (user and volumes are optional of course):

```yaml
services:
  grader:
    image: apluslms/run-mooc-grader
    user: $USER_ID:$DOCKER_GID
    volumes:
    # required
    - /var/run/docker.sock:/var/run/docker.sock
    - /tmp/aplus:/tmp/aplus
    # mount a course configuration (current dir presumed to be course repo)
    - .:/srv/courses/default:ro
    # named persistent volume (untill removed)
    # - data:/srv/data
    # per project persistent storage
    # - ./_data/:/srv/data
    # development mounts
    # - /home/user/mooc-grader/:/srv/grader/:ro
    # course configuration needs to be mounted here when developing the code
    # - .:/srv/grader/courses/default:ro
    ports:
      - "8000:8000"
volumes:
  data:
```
