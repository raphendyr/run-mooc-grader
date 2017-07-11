FROM debian:stretch

RUN apt-get update && apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      build-essential \
      software-properties-common \
      curl \
      gnupg2 \
      git \
      python3 \
      python3-pip \
      python3-dev \
      libxml2-dev \
      libxslt-dev \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian jessie stable" \
  && apt-get update \
  && apt-get install -y docker-ce

WORKDIR /srv

RUN git clone https://github.com/Aalto-LeTech/mooc-grader.git .

ADD settings_local.py .

RUN pip3 install setuptools wheel \
  && pip3 install -r requirements.txt \
  && python3 manage.py migrate \
  && pip3 install sphinx

VOLUME /srv/courses/default
EXPOSE 8080

ENTRYPOINT ["python3", "manage.py", "runserver", "0.0.0.0:8080"]
