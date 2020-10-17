FROM ruby:2.7.2
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bundle install
COPY . /app/

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
