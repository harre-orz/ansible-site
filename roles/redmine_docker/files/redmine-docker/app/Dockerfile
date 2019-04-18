FROM ruby:2.5.5

COPY redmine /var/redmine
RUN rm -rf $/var/redmine/.??*
COPY Gemfile.local /var/redmine
COPY unicorn.rb /var/redmine

WORKDIR /var/redmine
RUN bundle install --without development test

EXPOSE 8080
CMD bundle exec rake generate_secret_token && \
    bundle exec rake db:migrate RAILS_ENV=production && \
    bundle exec unicorn -c unicorn.rb -E production -p 8080
