RSpec.describe LineLogin do
  it "has a version number" do
    expect(LineLogin::VERSION).not_to be nil
  end

  let(:client) do
    LineLogin::Client.new(
      client_id: "client_id",
      client_secret: "client_secret",
      redirect_uri: "redirect_uri",
      api_origin: "https://api.line.me",
      access_origin: "https://access.line.me"
    )
  end

  it "get_auth_link" do
    expect(client.get_auth_link).to eq("https://access.line.me/oauth2/v2.1/authorize?scope=profile%2520openid%2520email&response_type=code&client_id=client_id&redirect_uri=redirect_uri&state=state")
  end

  it "get_auth_link with params" do
    expect(client.get_auth_link(state: "custom", scope: "profile")).to eq("https://access.line.me/oauth2/v2.1/authorize?scope=profile&response_type=code&client_id=client_id&redirect_uri=redirect_uri&state=custom")
  end

  describe "issue_access_token" do
    before do
      stub_request(:post, "https://api.line.me/oauth2/v2.1/token").to_return(body: '{
        "access_token": "bNl4YEFPI/hjFWhTqexp4MuEw5YPs...",
        "expires_in": 2592000,
        "id_token": "eyJhbGciOiJIUzI1NiJ9...",
        "refresh_token": "Aa1FdeggRhTnPNNpxr8p",
        "scope": "profile",
        "token_type": "Bearer"
      }')
    end

    it do
      expect(client.issue_access_token(code: "code")).to eq({
        "access_token": "bNl4YEFPI/hjFWhTqexp4MuEw5YPs...",
        "expires_in": 2592000,
        "id_token": "eyJhbGciOiJIUzI1NiJ9...",
        "refresh_token": "Aa1FdeggRhTnPNNpxr8p",
        "scope": "profile",
        "token_type": "Bearer"
      }.transform_keys{|key| key.to_s})

      expect(WebMock).to have_requested(:post, "https://api.line.me/oauth2/v2.1/token").
        with(
          body: "grant_type=authorization_code&code=code&redirect_uri=redirect_uri&client_id=client_id&client_secret=client_secret&code_verifier",
          headers: { 'Content-Type'=>'application/x-www-form-urlencoded' }
        )
    end
  end

  describe "verify_access_token" do
    before do
      stub_request(:get, "https://api.line.me/oauth2/v2.1/verify?access_token=access_token").to_return(body: '{
        "scope":"profile",
        "client_id":"1440057261",
        "expires_in":2591659
    }')
    end

    it do
      expect(client.verify_access_token(access_token: "access_token")).to eq({
        "scope":"profile",
        "client_id":"1440057261",
        "expires_in":2591659
      }.transform_keys{|key| key.to_s})

      expect(WebMock).to have_requested(:get, "https://api.line.me/oauth2/v2.1/verify?access_token=access_token")
    end
  end

  describe "refresh_access_token" do
    before do
      stub_request(:post, "https://api.line.me/oauth2/v2.1/token").to_return(body: '{
        "token_type":"Bearer",
        "scope":"profile",
        "access_token":"bNl4YEFPI/hjFWhTqexp4MuEw...",
        "expires_in":2591977,
        "refresh_token":"8iFFRdyxNVNLWYeteMMJ"
    }')
    end

    it do
      expect(client.refresh_access_token(refresh_token: "refresh_token")).to eq({
        "token_type":"Bearer",
        "scope":"profile",
        "access_token":"bNl4YEFPI/hjFWhTqexp4MuEw...",
        "expires_in":2591977,
        "refresh_token":"8iFFRdyxNVNLWYeteMMJ"
      }.transform_keys{|key| key.to_s})

      expect(WebMock).to have_requested(:post, "https://api.line.me/oauth2/v2.1/token").
        with(
          body: "grant_type=refresh_token&refresh_token=refresh_token&client_id=client_id&client_secret=client_secret",
          headers: { 'Content-Type'=>'application/x-www-form-urlencoded' }
        )
    end
  end

  describe "revoke_access_token" do
    before do
      stub_request(:post, "https://api.line.me/oauth2/v2.1/revoke").to_return(body: '')
    end

    it do
      expect(client.revoke_access_token(access_token: "access_token")).to eq('')

      expect(WebMock).to have_requested(:post, "https://api.line.me/oauth2/v2.1/revoke").
        with(
          body: "access_token=access_token&client_id=client_id&client_secret=client_secret",
          headers: { 'Content-Type'=>'application/x-www-form-urlencoded' }
        )
    end
  end

  describe "verify_id_token" do
    before do
      stub_request(:post, "https://api.line.me/oauth2/v2.1/verify").to_return(body: '{
        "iss": "https://access.line.me",
        "sub": "U1234567890abcdef1234567890abcdef",
        "aud": "1234567890",
        "exp": 1504169092,
        "iat": 1504263657,
        "nonce": "0987654asdf",
        "amr": [
            "pwd"
        ],
        "name": "Taro Line",
        "picture": "https://sample_line.me/aBcdefg123456",
        "email": "taro.line@example.com"
    }')
    end

    it do
      expect(client.verify_id_token(id_token: "id_token")).to eq({
        "iss": "https://access.line.me",
        "sub": "U1234567890abcdef1234567890abcdef",
        "aud": "1234567890",
        "exp": 1504169092,
        "iat": 1504263657,
        "nonce": "0987654asdf",
        "amr": [
            "pwd"
        ],
        "name": "Taro Line",
        "picture": "https://sample_line.me/aBcdefg123456",
        "email": "taro.line@example.com"
     }.transform_keys{|key| key.to_s})

     expect(WebMock).to have_requested(:post, "https://api.line.me/oauth2/v2.1/verify").
        with(
          body: "id_token=id_token&client_id=client_id",
          headers: { 'Content-Type'=>'application/x-www-form-urlencoded' }
        )
    end
  end
end
