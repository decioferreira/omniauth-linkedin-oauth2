require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class LinkedInOAuth2 < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, 'linkedin_oauth2'

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site => 'https://www.linkedin.com',
        :authorize_url => '/uas/oauth2/authorization?response_type=code',
        :token_url => '/uas/oauth2/accessToken'
      }

      option :scope, 'r_fullprofile r_emailaddress r_network'
      option :fields, ['id', 'email-address', 'first-name', 'last-name', 'headline', 'location', 'industry', 'picture-url', 'public-profile-url']

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['id'] }

      info do
        {
          :name => user_name,
          :email => raw_info['emailAddress'],
          :nickname => user_name,
          :first_name => raw_info['firstName'],
          :last_name => raw_info['lastName'],
          :location => raw_info['location'],
          :description => raw_info['headline'],
          :image => raw_info['pictureUrl'],
          :urls => {
            'public_profile' => raw_info['publicProfileUrl']
          }
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def raw_info
        @raw_info ||= linkedin_access_token.get("/v1/people/~:(#{options.fields.join(',')})?format=json").parsed
      end

      private

      def user_name
        name = "#{raw_info['firstName']} #{raw_info['lastName']}".strip
        name.empty? ? nil : name
      end

      def linkedin_access_token
        ::OAuth2::AccessToken.new(client, self.access_token.token, {
          :mode => :query,
          :param_name => 'oauth2_access_token'
        })
      end
    end
  end
end

OmniAuth.config.add_camelization 'linkedin_oauth2', 'LinkedInOAuth2'
