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

      option :scope, 'r_liteprofile r_emailaddress'
      option :fields, ['id', 'first-name', 'last-name', 'picture-url', 'email-address']

      uid do
        raw_info['id']
      end

      info do
        {
          :email => email_address,
          :first_name => localized_field('firstName'),
          :last_name => localized_field('lastName'),
          :picture_url => picture_url
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
          :expires_at => oauth2_access_token.expires_at
        })
      end

      def raw_info
        @raw_info ||= access_token.get(profile_endpoint).parsed
      end

      private

      def email_address
        if options.fields.include? 'email-address'
          fetch_email_address
          parse_email_address
        end
      end

      def fetch_email_address
        @email_address_response ||= access_token.get(email_address_endpoint).parsed
      end

      def parse_email_address
        return unless email_address_available?

        @email_address_response['elements'].first['handle~']['emailAddress']
      end

      def email_address_available?
        @email_address_response['elements'] &&
          @email_address_response['elements'].is_a?(Array) &&
          @email_address_response['elements'].first &&
          @email_address_response['elements'].first['handle~']
      end

      def fields_mapping
        {
          'id' => 'id',
          'first-name' => 'firstName',
          'last-name' => 'lastName',
          'picture-url' => 'profilePicture(displayImage~:playableStreams)'
        }
      end

      def fields
        options.fields.each.with_object([]) do |field, result|
          result << fields_mapping[field] if fields_mapping.has_key? field
        end
      end

      def localized_field field_name
        return unless localized_field_available? field_name

        raw_info[field_name]['localized'][field_locale(field_name)]
      end

      def field_locale field_name
        "#{ raw_info[field_name]['preferredLocale']['language'] }_" \
          "#{ raw_info[field_name]['preferredLocale']['country'] }"
      end

      def localized_field_available? field_name
        raw_info[field_name] && raw_info[field_name]['localized']
      end

      def picture_url
        return unless picture_available?

        picture_references.last['identifiers'].first['identifier']
      end

      def picture_available?
        raw_info['profilePicture'] &&
          raw_info['profilePicture']['displayImage~'] &&
          picture_references
      end

      def picture_references
        raw_info['profilePicture']['displayImage~']['elements']
      end

      def email_address_endpoint
        '/v2/emailAddress?q=members&projection=(elements*(handle~))'
      end

      def profile_endpoint
        "/v2/me?projection=(#{ fields.join(',') })"
      end
    end
  end
end

OmniAuth.config.add_camelization 'linkedin', 'LinkedIn'
