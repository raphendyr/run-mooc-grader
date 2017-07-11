FROM debian:stretch

RUN apt-get update && apt-get install -y --no-install-recommends \
      git \
      python3 \
      python3-pip \
    && rm -rf /var/lib/apt/lists/*

#debian install docker

WORKDIR /srv

RUN git clone https://github.com/Aalto-LeTech/mooc-grader.git .

ADD settings_local.py .

RUN pip3 install -r requirements.txt \
  && python3 manage.py migrate \
  && pip3 install sphinx

#mount to courses/default

EXPOSE 8080

ENTRYPOINT ["python3", "manage.py", "runserver", "0.0.0.0:8080"]
