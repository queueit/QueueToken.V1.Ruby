require 'digest'
require 'openssl'
require 'json'
require 'base64'
require 'byebug'

# Represent a payload to be add in the Queue-IT token
class QueueItToken::EnqueueTokenPayload
  attr_reader :key, :relative_quality, :custom_data

  def initialize(key: nil, relative_quality: nil, custom_data: {})
    @key = key.freeze
    @relative_quality = relative_quality
    @custom_data = custom_data.freeze
  end

  def encrypted_and_encoded(secret_key, token_identifier)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.key = Digest::SHA2.digest(secret_key)
    cipher.iv = Digest::MD5.digest(token_identifier)
    Base64.urlsafe_encode64(cipher.update(serialize) + cipher.final, padding: false)
  end

  private

  def serialize
    payload_json = {}
    payload_json[:r] = @relative_quality unless @relative_quality.nil?
    payload_json[:k] = @key unless @key.nil?
    payload_json[:cd] = @custom_data unless @custom_data.empty?

    payload_json.to_json
  end
end
