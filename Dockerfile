FROM apluslms/run-python3

RUN apt-get update -qqy && apt-get install -qqy --no-install-recommends \
    apt-transport-https \
    software-properties-common \
    curl \
    gnupg2 \
    libxml2-dev \
    libxslt-dev \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian jessie stable" \
  && apt-get update -qqy && apt-get install -qqy --no-install-recommends \
    docker-ce \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

WORKDIR /srv

RUN git clone --branch v1.0 https://github.com/Aalto-LeTech/mooc-grader.git .

ADD settings_local.py .
ADD docker-compose-run.sh ./scripts/

RUN pip3 install -r requirements.txt \
  && rm -rf /root/.cache \
  && python3 manage.py migrate

VOLUME /srv/courses/default
EXPOSE 8080

ENTRYPOINT ["python3", "manage.py", "runserver", "0.0.0.0:8080"]
