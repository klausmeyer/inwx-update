module RequestHelper
  def stub_login(code)
    stub_request(:post, 'https://api.domrobot.com/xmlrpc/')
      .with(body: %r{<methodName>account.login</methodName>})
      .to_return(status: 200, body: response_generic(code), headers: response_headers)
  end

  def stub_unlock(code)
    stub_request(:post, 'https://api.domrobot.com/xmlrpc/')
      .with(body: %r{<methodName>account.unlock</methodName>})
      .to_return(status: 200, body: response_generic(code), headers: response_headers)
  end

  def stub_info(records)
    response_body = <<~XML
      <methodResponse>
        <params>
          <param>
            <value>
              <struct>
                <member>
                  <name>code</name>
                  <value><int>1000</int></value>
                </member>
                <member>
                  <name>resData</name>
                  <value>
                    <struct>
                      <member>
                        <name>record</name>
                        <value>
                          <array>
                            <data>
                              #{response_info_records(records)}
                            </data>
                          </array>
                        </value>
                      </member>
                    </struct>
                  </value>
                </member>
              </struct>
            </value>
          </param>
        </params>
      </methodResponse>
    XML

    stub_request(:post, 'https://api.domrobot.com/xmlrpc/')
      .with(body: %r{<methodName>nameserver.info</methodName>})
      .to_return(status: 200, body: response_body, headers: response_headers)
  end

  def response_info_records(records)
    records.map { |r| response_info_record(r) }.join("\n")
  end

  def response_info_record(record)
    <<~XML
      <value>
        <struct>
          <member>
            <name>id</name>
            <value><int>#{record}</int></value>
          </member>
        </struct>
      </value>
    XML
  end

  def stub_delete(record, code)
    stub_request(:post, 'https://api.domrobot.com/xmlrpc/')
      .with(body: %r{<methodName>nameserver.deleteRecord</methodName>.*<name>id</name><value><i4>#{record}})
      .to_return(status: 200, body: response_generic(code), headers: response_headers)
  end

  def stub_create(code)
    stub_request(:post, 'https://api.domrobot.com/xmlrpc/')
      .with(body: %r{<methodName>nameserver.createRecord</methodName>})
      .to_return(status: 200, body: response_generic(code), headers: response_headers)
  end

  def response_generic(code)
    <<~XML
      <methodResponse>
        <params>
          <param>
            <value>
              <struct>
                <member>
                  <name>code</name>
                  <value><int>#{code}</int></value>
                </member>
              </struct>
            </value>
          </param>
        </params>
      </methodResponse>
    XML
  end

  def response_headers
    {
      'Content-Type' => 'text/xml'
    }
  end
end
