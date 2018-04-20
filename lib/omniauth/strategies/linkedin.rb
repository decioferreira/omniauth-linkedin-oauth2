require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class LinkedIn < OmniAuth::Strategies::OAuth2
      V1_TO_V2_FIELD_MAP = {
        'id' => 'id',
        'email-address' => nil,
        'first-name' => 'localizedFirstName',
        'last-name' => 'localizedLastName',
        'headline' => 'headline',
        'location' => nil,
        'industry' => 'industryName',
        'picture-url' => 'profilePicture(displayImage~:playableStreams)',
        'public-profile-url' => 'vanityName'
      }

      PROFILE_ENDPOINT = {
        'v1' => '/v1/people/~',
        'v2' => '/v2/me'
      }

      # Give your strategy a name.
      option :name, 'linkedin'

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site => 'https://api.linkedin.com',
        :authorize_url => 'https://www.linkedin.com/oauth/v2/authorization?response_type=code',
        :token_url => 'https://www.linkedin.com/oauth/v2/accessToken'
      }

      option :scope, 'r_basicprofile r_emailaddress'
      option :fields, ['id', 'email-address', 'first-name', 'last-name', 'headline', 'location', 'industry', 'picture-url', 'public-profile-url']
      option :api_version, 'v1'

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['id'] }

      info do
        if options.api_version == "v1"
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
        elsif options.api_version == "v2"
          {
            :name => user_name,
            :email => nil,
            :nickname => user_name,
            :first_name => raw_info['localizedFirstName'],
            :last_name => raw_info['localizedLastName'],
            :location => nil,
            :description => localized_field(raw_info['headline']),
            :image => profile_picture,
            :urls => {
              'public_profile' => "https://www.linkedin.com/in/#{raw_info['vanityName']}"
            }
          }
        end
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      alias :oauth2_access_token :access_token

      def access_token
        ::OAuth2::AccessToken.new(client, oauth2_access_token.token, {
          :mode => :query,
          :param_name => 'oauth2_access_token',
          :expires_in => oauth2_access_token.expires_in,
          :expires_at => oauth2_access_token.expires_at
        })
      end

      def raw_info
        @raw_info ||= access_token.get(profile_endpoint).parsed
      end

      private

      def option_fields
        fields = options.fields
        fields.map! do |f|
          if options.api_version == 'v2'
            V1_TO_V2_FIELD_MAP.fetch(f,f)
          elsif !!options[:secure_image_url] && f == 'picture-url'
            "picture-url;secure=true"
          else
            f
          end
        end
        fields.compact
      end

      def localized_field(field)
        return nil unless field
        locale = "#{field['preferredLocale']['language']}_#{field['preferredLocale']['country']}"
        field['localized'][locale]
      end

      def profile_picture
        return nil if raw_info['profilePicture'].to_s.empty?
        raw_info['profilePicture']['displayImage~']['elements'].first['identifiers'].first['identifier']
      end

      def first_name
        raw_info['firstName'] || raw_info['localizedFirstName']
      end

      def last_name
        raw_info['lastName'] || raw_info['localizedLastName']
      end

      def user_name
        name = "#{first_name} #{last_name}"
        name.empty? ? nil : name
      end

      def profile_endpoint
        suffix = case options.api_version
                 when 'v1'
                   ":(#{option_fields.join(',')})?format=json"
                 when 'v2'
                   "?projection=(#{option_fields.join(',')})"
                 end

        PROFILE_ENDPOINT[options.api_version] + suffix
      end
    end
  end
end

OmniAuth.config.add_camelization 'linkedin', 'LinkedIn'
