require 'digest'
require 'securerandom'
require 'json'
require 'base64'

class EnqueueToken
  attr_reader :customer_id, :event_id, :ip_address, :ip_forwared_for, :payload, :token_identifier,
              :issued_at, :expire_at

  def initialize(customer_id:, event_id: nil, ip_address: nil, ip_forwared_for: nil, payload: nil,
                 token_identifier: nil, token_identifier_prefix: nil, issued_at: nil, expire_at: nil)
    @customer_id = customer_id
    @event_id = event_id
    @ip_address = ip_address
    @ip_forwared_for = ip_forwared_for
    @payload = payload
    @token_identifier = token_identifier || [token_identifier_prefix, SecureRandom.uuid].compact.join('~')
    @issued_at = issued_at || (Time.now.to_f * 1000).to_i
    @expire_at = expire_at
  end

  def token(secret_key)
    "#{token_serialized(secret_key)}.#{hash(secret_key)}"
  end

  # private

  def token_serialized(secret_key)
    payload_encrypted = @payload.encrypted_and_encoded(secret_key, @token_identifier) unless @payload.nil?
    "#{header_serialized}.#{payload_encrypted}"
  end

  def headers
    headers = {
      typ: 'QT1',
      enc: 'AES256',
      iss: @issued_at
    }
    headers[:exp] = @expire_at unless @expire_at.nil?
    headers[:ti] = @token_identifier
    headers[:c] = @customer_id
    headers[:e] = @event_id unless @event_id.nil?
    headers[:ip] = @ip_address unless @ip_address.nil?
    headers[:xff] = @ip_forwared_for unless @ip_forwared_for.nil?
    headers
  end

  def header_serialized
    Base64.urlsafe_encode64(headers.to_json, padding: false)
  end

  def hash(secret_key)
    Base64.urlsafe_encode64(Digest::SHA256.digest("#{token_serialized(secret_key)}#{secret_key}"), padding: false)
  end
end