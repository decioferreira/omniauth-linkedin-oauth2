require 'spec_helper'
require 'omniauth-linkedin-oauth2'

describe OmniAuth::Strategies::LinkedIn do
  subject { OmniAuth::Strategies::LinkedIn.new(nil) }

  it 'should add a camelization for itself' do
    expect(OmniAuth::Utils.camelize('linkedin')).to eq('LinkedIn')
  end

  describe '#client' do
    it 'has correct LinkedIn site' do
      expect(subject.client.site).to eq('https://api.linkedin.com')
    end

    it 'has correct authorize url' do
      expect(subject.client.options[:authorize_url]).to eq('https://www.linkedin.com/oauth/v2/authorization?response_type=code')
    end

    it 'has correct token url' do
      expect(subject.client.options[:token_url]).to eq('https://www.linkedin.com/oauth/v2/accessToken')
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      expect(subject.callback_path).to eq('/auth/linkedin/callback')
    end
  end

  describe '#uid' do
    before :each do
      allow(subject).to receive(:raw_info) { { 'id' => 'uid' } }
    end

    it 'returns the id from raw_info' do
      expect(subject.uid).to eq('uid')
    end
  end

  describe '#info' do
    before :each do
      allow(subject).to receive(:raw_info) { {} }
    end

    context 'api_version is v1' do
      context 'and therefore has all the necessary fields' do
        it { expect(subject.info).to have_key :name }
        it { expect(subject.info).to have_key :email }
        it { expect(subject.info).to have_key :nickname }
        it { expect(subject.info).to have_key :first_name }
        it { expect(subject.info).to have_key :last_name }
        it { expect(subject.info).to have_key :location }
        it { expect(subject.info).to have_key :description }
        it { expect(subject.info).to have_key :image }
        it { expect(subject.info).to have_key :urls }
      end
    end

    context 'api_version is v2' do
      before :each do
        subject.stub(:options => double('options', :api_version => 'v2').as_null_object)
      end

      context 'and therefore has all the necessary fields' do
        it { expect(subject.info).to have_key :name }
        it { expect(subject.info).to have_key :nickname }
        it { expect(subject.info).to have_key :first_name }
        it { expect(subject.info).to have_key :last_name }
        it { expect(subject.info).to have_key :description }
        it { expect(subject.info).to have_key :image }
        it { expect(subject.info).to have_key :urls }
      end
    end
  end

  describe '#extra' do
    before :each do
      allow(subject).to receive(:raw_info) { { :foo => 'bar' } }
    end

    it { expect(subject.extra['raw_info']).to eq({ :foo => 'bar' }) }
  end

  describe '#access_token' do
    before :each do
      allow(subject).to receive(:oauth2_access_token) { double('oauth2 access token', :expires_in => 3600, :expires_at => 946688400).as_null_object }
    end

    it { expect(subject.access_token.expires_in).to eq(3600) }
    it { expect(subject.access_token.expires_at).to eq(946688400) }
  end

  describe '#raw_info' do
    before :each do
      allow(subject).to receive(:option_fields) { ['baz', 'qux'] }
    end

    context 'api_version is v1' do
      before :each do
        response = double('response', :parsed => { :foo => 'bar' })
        access_token = double('access token')
        expect(access_token).to receive(:get).with("/v1/people/~:(baz,qux)?format=json").and_return(response)
        allow(subject).to receive(:access_token) { access_token }
      end

      it 'returns parsed response from access token' do
        expect(subject.raw_info).to eq({ :foo => 'bar' })
      end
    end

    context 'api_version is v2' do
      before :each do
        response = double('response', :parsed => { :foo => 'bar' })
        access_token = double('access token')
        expect(access_token).to receive(:get).with("/v2/me?projection=(baz,qux)").and_return(response)
        allow(subject).to receive(:access_token) { access_token }
        subject.stub(:options => double('options', :api_version => 'v2').as_null_object)
      end

      it 'returns parsed response from access token' do
        expect(subject.raw_info).to eq({ :foo => 'bar' })
      end
    end
  end

  describe '#authorize_params' do
    describe 'scope' do
      before :each do
        subject.stub(:session => {})
      end

      it 'sets default scope' do
        expect(subject.authorize_params['scope']).to eq('r_basicprofile r_emailaddress')
      end
    end
  end

  describe '#option_fields' do
    context 'api_version is v1' do
      it 'returns options fields' do
        subject.stub(:options => double('options', :fields => ['foo', 'bar'], :api_version => 'v1').as_null_object)
        expect(subject.send(:option_fields)).to eq(['foo', 'bar'])
      end

      it 'http avatar image by default' do
        subject.stub(:options => double('options', :fields => ['picture-url'], :api_version => 'v1'))
        allow(subject.options).to receive(:[]).with(:secure_image_url).and_return(false)
        expect(subject.send(:option_fields)).to eq(['picture-url'])
      end

      it 'https avatar image if secure_image_url truthy' do
        subject.stub(:options => double('options', :fields => ['picture-url'], :api_version => 'v1'))
        allow(subject.options).to receive(:[]).with(:secure_image_url).and_return(true)
        expect(subject.send(:option_fields)).to eq(['picture-url;secure=true'])
      end
    end

    context 'api_version is v2' do
      it 'returns options fields' do
        subject.stub(:options => double('options', :fields => ['foo', 'bar'], :api_version => 'v2').as_null_object)
        expect(subject.send(:option_fields)).to eq(['foo', 'bar'])
      end

      it 'converts picture-url to the profilePicture projection' do
        subject.stub(:options => double('options', :fields => ['picture-url'], :api_version => 'v2').as_null_object)
        expect(subject.send(:option_fields)).to eq(['profilePicture(displayImage~:playableStreams)'])
      end

      it 'converts first-name to the localizedFirstName projection' do
        subject.stub(:options => double('options', :fields => ['first-name'], :api_version => 'v2').as_null_object)
        expect(subject.send(:option_fields)).to eq(['localizedFirstName'])
      end

      it 'converts last-name to the localizedLastName projection' do
        subject.stub(:options => double('options', :fields => ['last-name'], :api_version => 'v2').as_null_object)
        expect(subject.send(:option_fields)).to eq(['localizedLastName'])
      end

      it 'converts industry to the industryName projection' do
        subject.stub(:options => double('options', :fields => ['industry'], :api_version => 'v2').as_null_object)
        expect(subject.send(:option_fields)).to eq(['industryName'])
      end

      it 'converts public-profile-url to the vanityName projection' do
        subject.stub(:options => double('options', :fields => ['public-profile-url'], :api_version => 'v2').as_null_object)
        expect(subject.send(:option_fields)).to eq(['vanityName'])
      end

      it 'ignores email-address' do
        subject.stub(:options => double('options', :fields => ['email-address'], :api_version => 'v2').as_null_object)
        expect(subject.send(:option_fields)).to eq([])
      end

      it 'ignores location' do
        subject.stub(:options => double('options', :fields => ['location'], :api_version => 'v2').as_null_object)
        expect(subject.send(:option_fields)).to eq([])
      end
    end
  end
end
