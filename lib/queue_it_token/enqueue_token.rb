require 'digest'
require 'securerandom'
require 'json'
require 'base64'

# Base class for creating a Queue-IT Token
class QueueItToken::EnqueueToken
  ##
  # This class need a customer_id (Queue-IT account) and optionnals options:
  # event_id: ID of the Queue-IT event
  # ip_address: IP address of the user
  # ip_forwared_for: IP addresses forwarded for
  # payload: payload (QueueItToken::EnqueueTokenPayload)
  # token_identifier: fixed token identifier
  # token_identifier_prefix: prefix for generating random identifier
  # issued_at: UNIX timestamp of issued date
  # expire_at: UNIX timestamp of expiration date
  def initialize(customer_id:, options: {})
    @customer_id = customer_id
    @event_id, @ip_address, @ip_forwared_for,
    @payload, @expire_at = options.values_at(:event_id, :ip_address, :ip_forwared_for, :payload, :expire_at)

    @token_identifier = options[:token_identifier] || random_token_identifier(options[:token_identifier_prefix])
    @issued_at = options[:issued_at] || (Time.now.to_f * 1000).to_i
  end

  def token(secret_key)
    "#{token_serialized(secret_key)}.#{hash(secret_key)}"
  end

  private

  def random_token_identifier(prefix)
    [prefix, SecureRandom.uuid].compact.join('~')
  end

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
