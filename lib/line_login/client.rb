# frozen_string_literal: true

require "net/http"
require "json"

module LineLogin
  class Client
    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :redirect_uri
    attr_accessor :api_origin
    attr_accessor :access_origin

    def initialize(client_id: "client_id", client_secret: "client_secret", redirect_uri: "redirect_uri", api_origin: "https://api.line.me", access_origin: "https://access.line.me")
      self.client_id = client_id
      self.client_secret = client_secret
      self.redirect_uri = redirect_uri
      self.api_origin = api_origin
      self.access_origin = access_origin
    end

    # Get Auth Link
    #
    # Authenticating users and making authorization requests
    #
    # Initiate the process of authenticating the user with the LINE Platform and authorizing your app.
    # When the user clicks a LINE Login button, redirect them to an authorization URL with the required query parameters,
    # as shown in the example below.
    #
    def get_auth_link(options = {})
      data = {
        scope: "profile%20openid%20email",
        response_type: "code",
        client_id: self.client_id,
        redirect_uri: self.redirect_uri,
        state: "state"
      }.merge(options);
      "#{self.access_origin}/oauth2/v2.1/authorize?#{URI.encode_www_form(data)}"
    end

    # Issues access tokens.
    #
    # The access tokens managed through the LINE Login API attest that an app has been granted permission to access user data
    # (such as user IDs, display names, profile images, and status messages) saved on the LINE Platform.
    #
    # LINE Login API calls require you to provide an access token or refresh token that was sent in an earlier response.
    def issue_access_token(code: , redirect_uri: nil, code_verifier: nil)
      option = {
        url: "#{api_origin}/oauth2/v2.1/token",
        header: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        param: {
          grant_type: :authorization_code,
          code: code,
          redirect_uri: redirect_uri || self.redirect_uri,
          client_id: client_id,
          client_secret: client_secret,
          code_verifier: code_verifier
        }
      }
      response = post(option)
      JSON.parse(response.body)
    end

    # Verifies if an access token is valid.
    #
    # For general recommendations on how to securely handle user registration and login with access tokens,
    # see Creating a secure login process between your app and server in the LINE Login documentation.
    #
    def verify_access_token(access_token: )
      option = {
        url: "#{api_origin}/oauth2/v2.1/verify?access_token=#{access_token}",
      }
      response = get(option)
      JSON.parse(response.body)
    end

    # Refresh access token
    #
    # Gets a new access token using a refresh token.
    # A refresh token is returned along with an access token once user authentication is complete.
    #
    def refresh_access_token(refresh_token: )
      option = {
        url: "#{api_origin}/oauth2/v2.1/token",
        header: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        param: {
          grant_type: :refresh_token,
          refresh_token: refresh_token,
          client_id: client_id,
          client_secret: client_secret
        }
      }
      response = post(option)
      JSON.parse(response.body)
    end

    # Revoke access token
    #
    # Invalidates a user's access token.
    #
    def revoke_access_token(access_token: )
      option = {
        url: "#{api_origin}/oauth2/v2.1/revoke",
        header: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        param: {
          access_token: access_token,
          client_id: client_id,
          client_secret: client_secret
        }
      }
      response = post(option)
      response.body
    end

    # Verify ID token
    #
    # ID tokens are JSON web tokens (JWT) with information about the user.
    # It's possible for an attacker to spoof an ID token.
    # Use this call to verify that a received ID token is authentic,
    # meaning you can use it to obtain the user's profile information and email.
    #
    def verify_id_token(id_token: , nonce: nil, user_id: nil)
      param = {
        id_token: id_token,
        client_id: client_id
      }
      param[:nonce] = nonce unless nonce.nil?
      param[:user_id] = user_id unless user_id.nil?

      option = {
        url: "#{api_origin}/oauth2/v2.1/verify",
        header: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        param: param
      }
      response = post(option)
      JSON.parse(response.body)
    end

    private

    # 發送一個get
    # option: :url, :header, :param, :ssl_verify
    def get(option)
      url = URI(option[:url])
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = option[:url]["https://"].nil? == false
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless option[:ssl_verify]
      request = Net::HTTP::Get.new(url)
      option[:header]&.each do |key, value|
        request[key] = value
      end
      http.request(request)
    end

    # 發送一個post
    # option: :url, :header, :param, :ssl_verify
    def post(option)
      url = URI(option[:url])
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = option[:url]["https://"].nil? == false
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless option[:ssl_verify]
      request = Net::HTTP::Post.new(url)
      option[:header]&.each do |key, value|
        request[key] = value
      end
      request.set_form_data(option[:param] || {})
      http.request(request)
    end
  end
end