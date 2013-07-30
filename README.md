# OmniAuth LinkedIn OAuth2 Strategy

[![Build Status](https://travis-ci.org/decioferreira/omniauth-linkedin-oauth2.png?branch=master)](https://travis-ci.org/decioferreira/omniauth-linkedin-oauth2)

A LinkedIn OAuth2 strategy for OmniAuth.

For more details, read the LinkedIn documentation: https://developer.linkedin.com/documents/authentication

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-linkedin-oauth2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-linkedin-oauth2

## Usage

Register your application with LinkedIn to receive an API key: https://www.linkedin.com/secure/developer

This is an example that you might put into a Rails initializer at `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin_oauth2, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET']
end
```

You can now access the OmniAuth LinkedIn OAuth2 URL: `/auth/linkedin_oauth2`.

## Granting Member Permissions to Your Application

With the LinkedIn API, you have the ability to specify which permissions you want users to grant your application.
For more details, read the LinkedIn documentation: https://developer.linkedin.com/documents/authentication

By default, omniauth-linkedin-oauth2 requests the following permissions:

    'r_basicprofile r_emailaddress'

You can configure the scope option:

```ruby
provider :linkedin_oauth2, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], :scope => 'r_fullprofile r_emailaddress r_network'
```

## Profile Fields

When specifying which permissions you want to users to grant to your application, you will probably want to specify the array of fields that you want returned in the omniauth hash. The list of default fields is as follows:

```ruby
['id', 'email-address', 'first-name', 'last-name', 'headline', 'location', 'industry', 'picture-url', 'public-profile-url']
```

Here's an example of a possible configuration where the the fields returned from the API are: id, email-address, first-name and last-name.

```ruby
provider :linkedin_oauth2, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], :fields => ['id', 'email-address', 'first-name', 'last-name']
```

To see a complete list of available fields, consult the LinkedIn documentation at: https://developer.linkedin.com/documents/profile-fields

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
