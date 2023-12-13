require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class LinkedIn < OmniAuth::Strategies::OAuth2
      option :name, 'linkedin'

      option :client_options, {
        :site => 'https://api.linkedin.com',
        :authorize_url => 'https://www.linkedin.com/oauth/v2/authorization?response_type=code',
        :token_url => 'https://www.linkedin.com/oauth/v2/accessToken'
      }
      option :scope, 'profile email w_member_social openid'

      uid do
        raw_info['sub']
      end

      info do
        {
          :email => localized_field('email_verified') && localized_field('email'),
          :first_name => localized_field('given_name'),
          :last_name => localized_field('family_name'),
          :picture_url => localized_field('picture')
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      alias :oauth2_access_token :access_token

      def access_token
        ::OAuth2::AccessToken.new(client, oauth2_access_token.token, {
          :expires_in => oauth2_access_token.expires_in,
          :expires_at => oauth2_access_token.expires_at,
          :refresh_token => oauth2_access_token.refresh_token
        })
      end

      def raw_info
        @raw_info ||= access_token.get(profile_endpoint).parsed
      end

      private

      def localized_field field_name
        value = raw_info[field_name]
        if value.is_a?(Hash)
          value.dig('localized', field_locale(field_name))
        else
          value
        end
      end

      def field_locale field_name
        field_value = raw_info[field_name]
        return unless field_value.is_a?(Hash)

        preferred_locale = field_value['preferredLocale']
        return unless preferred_locale

        "#{preferred_locale['language'] }_#{preferred_locale['country'] }"
      end

      def profile_endpoint
        "/v2/userinfo"
      end
      
      def token_params
        super.tap do |params|
          params.client_secret = options.client_secret
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'linkedin', 'LinkedIn'
