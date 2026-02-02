require 'rails_helper'

RSpec.describe JsonWebToken do
  let(:payload) { { user_id: 1 } }
  let(:secret_key) { Rails.application.secret_key_base }

  describe '.encode' do
    it 'encodes the payload into a JWT string' do
      token = described_class.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').size).to eq(3) # JWTs have 3 parts: Header, Payload, Signature
    end

    it 'sets the expiration time' do
      exp = 2.hours.from_now
      token = described_class.encode(payload, exp)
      decoded = JWT.decode(token, secret_key)[0]

      expect(decoded['exp']).to eq(exp.to_i)
    end
  end

  describe '.decode' do
    let(:token) { described_class.encode(payload) }

    it 'decodes a valid token into a hash' do
      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(1)
    end

    it 'returns a HashWithIndifferentAccess' do
      decoded = described_class.decode(token)
      # This allows accessing by symbol :user_id or string 'user_id'
      expect(decoded).to be_a(HashWithIndifferentAccess)
      expect(decoded[:user_id]).to eq(decoded['user_id'])
    end

    it 'raises JWT::DecodeError when the token is invalid' do
      expect {
        described_class.decode('invalid_token_format')
      }.to raise_error(JWT::DecodeError)
    end

    it 'raises JWT::ExpiredSignature when the token has expired' do
      # Encode a token that expired 1 second ago
      expired_token = described_class.encode(payload, 1.second.ago)

      expect {
        described_class.decode(expired_token)
      }.to raise_error(JWT::ExpiredSignature)
    end
  end
end
