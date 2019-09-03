require 'digest'
require 'openssl'

class EnqueueTokenPayload
  attr_reader :key, :relative_quality, :custom_data

  def initialize(key:, relative_quality:, custom_data: {})
    @key = key.freeze
    @relative_quality = relative_quality
    @custom_data = custom_data.freeze
  end

  def encrypted_and_encoded(secret_key, token_identifier)
    cipher = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.key = Digest::SHA2.hexdigest(secret_key)
    cipher.iv = Digest::MD5.hexdigest(token_identifier)
    urlsafe_encode64(cipher.update(serialize) + cipher.final)
  end

  private

  def serialize
    payload_json = custom_data.dup
    payload_json[:r] = @relative_quality unless @relative_quality.nil?
    payload_json[:k] = @key unless @key.nil?

    payload_json.to_json
  end
end