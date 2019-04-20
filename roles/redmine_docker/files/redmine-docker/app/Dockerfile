FROM ruby:2.5.5

ENV TZ Asia/Tokyo
RUN apt-get update \
 && apt-get install -y tzdata \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && echo ${TZ} > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata

COPY --chown=www-data:www-data redmine /var/www/
COPY --chown=www-data:www-data Gemfile.local /var/www/Gemfile.local
COPY --chown=www-data:www-data unicorn.rb /var/www/unicorn.rb

WORKDIR /var/www
RUN bundle install --without development test

USER www-data

EXPOSE 8080
CMD bundle exec rake generate_secret_token && \
    bundle exec rake db:migrate RAILS_ENV=production && \
    bundle exec unicorn -c unicorn.rb -E production -p 8080
