# OmniAuth LinkedIn OAuth2 Strategy

[![Build Status](https://travis-ci.org/decioferreira/omniauth-linkedin-oauth2.png?branch=master)](https://travis-ci.org/decioferreira/omniauth-linkedin-oauth2)

A LinkedIn OAuth2 strategy for OmniAuth.

For more details, read the LinkedIn documentation: https://learn.microsoft.com/en-us/linkedin/consumer/integrations/self-serve/sign-in-with-linkedin-v2

## Installation

Add this gem to your application's Gemfile:

    bundle add omniauth-linkedin-oauth2

Or install it yourself as:

    $ gem install omniauth-linkedin-oauth2

## Upgrading

This version is a major upgrade to the LinkedIn API version 2. As such, it switches from the soon to be no longer available `r_basicprofile` to `r_liteprofile`. This results in a much limited set of data that we can get from LinkedIn.

Previous versions of this gem used the provider name `:linkedin_oauth2`. In order to provide a cleaner upgrade path for users who were previously using the OAuth 1.0 omniauth adapter for LinkedIn [https://github.com/skorks/omniauth-linkedin], this has been renamed to just `:linkedin`.

Users who are upgrading from previous versions of this gem may need to update their Omniauth and/or Devise configurations to use the shorter provider name.

## Usage

Register your application with LinkedIn to receive an API key: https://www.linkedin.com/secure/developer

This is an example that you might put into a Rails initializer at `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET']
end
```

You can now access the OmniAuth LinkedIn OAuth2 URL: `/auth/linkedin`.

## Granting Member Permissions to Your Application

With the LinkedIn API, you have the ability to specify which permissions you want users to grant your application.
For more details, read the LinkedIn documentation: https://learn.microsoft.com/en-us/linkedin/consumer/integrations/self-serve/sign-in-with-linkedin-v2#authenticating-members

By default, omniauth-linkedin-oauth2 requests the following permissions:

    'r_liteprofile r_emailaddress'

You can configure the scope option:

```ruby
provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], :scope => 'r_liteprofile'
```

## Profile Fields

When specifying which permissions you want to users to grant to your application, you will probably want to specify the array of fields that you want returned in the omniauth hash. The list of default fields is as follows:

```ruby
['id', 'first-name', 'last-name', 'picture-url', 'email-address']
```

Here's an example of a possible configuration where the fields returned from the API are: id, first-name and last-name.

```ruby
provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], :fields => ['id', 'first-name', 'last-name']
```

To see a complete list of available fields, consult the LinkedIn documentation at: https://developer.linkedin.com/docs/fields

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request
