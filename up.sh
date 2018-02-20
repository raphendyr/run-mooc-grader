#!/bin/sh -e

db=$GRADER_DB_FILE

# Check for development mount -> install updated requirements to venv (no root perms)
if [ -e "requirements.txt" ]; then
    python3 -m virtualenv -p python3 --system-site-packages /srv/data/mgrader_venv
    . /srv/data/mgrader_venv/bin/activate
    pip3 install --disable-pip-version-check -r requirements.txt
    [ "$db" -a -e "$db" ] && python3 manage.py migrate
fi

# make sure some data paths exists
mkdir -p "$GRADER_SUBMISSION_PATH" \
         "$GRADER_PERSONALIZED_CONTENT_PATH"

if [ "$1" = "manage" ]; then
    shift
    exec python3 manage.py "$@"
elif [ "$1" ]; then
    exec "$@"
else
    # Create database if one doesn't exists
    if [ "$db" -a ! -e "$db" ]; then
        python3 manage.py migrate
    fi
    
    # generate instances for personalized exercises (course key default)
    python3 manage.py pregenerate_exercises default

    exec python3 manage.py runserver 0.0.0.0:8080
fi
