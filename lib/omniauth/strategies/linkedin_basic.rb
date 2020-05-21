require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class LinkedInBasic < LinkedIn
      option :scope, 'r_basicprofile r_emailaddress'

      option :fields, %w[
        id
        first-name
        last-name
        picture-url
        email-address
        vanity-name
        maiden-name
        headline
      ]

      info do
        {
          email: email_address,
          first_name: localized_field('firstName'),
          last_name: localized_field('lastName'),
          vanity_name: raw_info['vanityName'],
          maiden_name: localized_field('maidenName'),
          headline: localized_field('headline'),
          picture_url: picture_url
        }
      end

      private

      def fields_mapping
        {
          'id' => 'id',
          'first-name' => 'firstName',
          'last-name' => 'lastName',
          'picture-url' => 'profilePicture(displayImage~:playableStreams)',
          'vanity-name' => 'vanityName',
          'maiden-name' => 'maidenName',
          'headline' => 'headline'
        }
      end
    end
  end
end
