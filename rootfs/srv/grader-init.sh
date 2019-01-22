#!/bin/sh -eu

# generate instances for personalized exercises (course key default)
setuidgid $USER python3 manage.py pregenerate_exercises --gen-if-none-exist default || true
