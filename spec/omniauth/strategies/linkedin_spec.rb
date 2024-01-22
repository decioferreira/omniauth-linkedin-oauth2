require 'spec_helper'
require 'omniauth-linkedin-oauth2'

describe OmniAuth::Strategies::LinkedIn do
  subject { OmniAuth::Strategies::LinkedIn.new(nil) }

  it 'adds camelization for itself' do
    expect(OmniAuth::Utils.camelize('linkedin')).to eq('LinkedIn')
  end

  describe '#client' do
    it 'has correct LinkedIn site' do
      expect(subject.client.site).to eq('https://api.linkedin.com')
    end

    it 'has correct `authorize_url`' do
      expect(subject.client.options[:authorize_url]).to eq('https://www.linkedin.com/oauth/v2/authorization?response_type=code')
    end

    it 'has correct `token_url`' do
      expect(subject.client.options[:token_url]).to eq('https://www.linkedin.com/oauth/v2/accessToken')
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      expect(subject.callback_path).to eq('/auth/linkedin/callback')
    end
  end

  describe '#custom redirect_url' do
    let(:redirect_url) {'http://localhost:3001'}

    it 'custom redirect' do
      expect(subject.callback_url).to eq('http://localhost:3001')
    end

  end

  describe '#uid' do
    before :each do
      allow(subject).to receive(:raw_info) { Hash['id' => 'uid'] }
    end

    it 'returns the id from raw_info' do
      expect(subject.uid).to eq('uid')
    end
  end

  describe '#info / #raw_info' do
    let(:access_token) { instance_double OAuth2::AccessToken }

    let(:parsed_response) { Hash[:foo => 'bar'] }

    let(:profile_endpoint) { '/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))' }
    let(:email_address_endpoint) { '/v2/emailAddress?q=members&projection=(elements*(handle~))' }

    let(:email_address_response) { instance_double OAuth2::Response, parsed: parsed_response }
    let(:profile_response) { instance_double OAuth2::Response, parsed: parsed_response }

    before :each do
      allow(subject).to receive(:access_token).and_return access_token

      allow(access_token).to receive(:get)
        .with(email_address_endpoint)
        .and_return(email_address_response)

      allow(access_token).to receive(:get)
        .with(profile_endpoint)
        .and_return(profile_response)
    end

    it 'returns parsed responses using access token' do
      expect(subject.info).to have_key :email
      expect(subject.info).to have_key :first_name
      expect(subject.info).to have_key :last_name
      expect(subject.info).to have_key :picture_url

      expect(subject.raw_info).to eq({ :foo => 'bar' })
    end
  end

  describe '#extra' do
    let(:raw_info) { Hash[:foo => 'bar'] }

    before :each do
      allow(subject).to receive(:raw_info).and_return raw_info
    end

    specify { expect(subject.extra['raw_info']).to eq raw_info }
  end

  describe '#access_token' do
    let(:expires_in) { 3600 }
    let(:expires_at) { 946688400 }
    let(:token) { 'token' }
    let(:refresh_token) { 'refresh_token' }
    let(:access_token) do
      instance_double OAuth2::AccessToken, :expires_in => expires_in,
        :expires_at => expires_at, :token => token, :refresh_token => refresh_token
    end

    before :each do
      allow(subject).to receive(:oauth2_access_token).and_return access_token
    end

    specify { expect(subject.access_token.expires_in).to eq expires_in }
    specify { expect(subject.access_token.expires_at).to eq expires_at }
  end

  describe '#authorize_params' do
    describe 'scope' do
      before :each do
        allow(subject).to receive(:session).and_return({})
      end

      it 'sets default scope' do
        expect(subject.authorize_params['scope']).to eq('r_liteprofile r_emailaddress')
      end
    end
  end
end
