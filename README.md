# LINE Login

LINE Login is a [LINE Login 2.1](https://developers.line.biz/en/reference/line-login/) Client for Ruby.

## Installation

Add the following code to your application's Gemfile:

```ruby
gem 'line_login'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install line_login

## Usage

### initialize client instance

```ruby
client = LineLogin::Client.new(
  client_id: "your line login client id",
  client_secret: "your line login client secret",
  redirect_uri: "your redirect uri"
)
```

### get auth link

Describe all parameters of this method in [the LINE Login documentation](https://developers.line.biz/en/docs/line-login/integrate-line-login/#making-an-authorization-request).

There are no required parameters, the default value of scope is `profile%20openid%20email`, and state is `state`.

```ruby
auth_link = client.get_auth_link
```

You can override any parameter by passing it.

```ruby
auth_link = client.get_auth_link(scope: "", state: "state")
```

### get access token

```ruby
code = "you can get code from redirect uri after user click the auth link"
token = client.get_access_token(code)
```


### revoke access token

```
response = client.revoke(token)
```

## Testing

Type the following command in your terminal to run the tests:

```
rake spec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/etrex/line_login.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

