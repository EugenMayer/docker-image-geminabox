FROM ruby:alpine

RUN apk --update add --virtual build-dependencies build-base ruby-dev openssl-dev libc-dev linux-headers \
  && gem install geminabox unicorn net-ldap\
  && apk del build-dependencies \
  && mkdir /geminabox /geminabox/data

ENV RAILS_ENV production

COPY config.ru /geminabox/config.ru

WORKDIR /geminabox
EXPOSE 9292
ENTRYPOINT ["unicorn", "-p", "9292"]
