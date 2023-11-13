@message
Feature: Message provider
  Supports verifying a V3 message Pacts

 Scenario: Verifying a simple message
   Given a provider is started that can generate the "basic" message with "file: basic.json"
   And a Pact file for "basic":"file: basic.json" is to be verified
   When the verification is run
   Then the verification will be successful

  Scenario: Verifying multiple Pact files
    Given a provider is started that can generate the "basic" message with "file: basic.json"
    And a provider is started that can generate the "xml" message with "file: xml-body.xml"
    And a Pact file for "basic":"file: basic.json" is to be verified
    And a Pact file for "xml":"file: xml-body.xml" is to be verified
    When the verification is run
    Then the verification will be successful

  Scenario: Incorrect message is generated by the provider
    Given a provider is started that can generate the "json" message with "JSON: { \"one\": \"a\", \"two\": \"c\" }"
    And a Pact file for "json":"file: basic.json" is to be verified
    When the verification is run
    Then the verification will NOT be successful

  Scenario: Verifying an interaction with a defined provider state
    Given a provider is started that can generate the "basic" message with "file: basic.json"
    And a provider state callback is configured
    And a Pact file for "basic":"file: basic.json" is to be verified with provider state "state one"
    When the verification is run
    Then the provider state callback will be called before the verification is run
    And the provider state callback will receive a setup call with "state one" as the provider state parameter
    And the provider state callback will be called after the verification is run
    And the provider state callback will receive a teardown call "state one" as the provider state parameter

  Scenario: Verifies the message metadata
    Given a provider is started that can generate the "basic" message with "file: basic.json" and the following metadata:
      | key     | value                                           |
      | Origin  | Some Text                                       |
      | TagData | JSON: { "ID": "sjhdjkshsdjh", "weight": 100.5 } |
    And a Pact file for "basic":"file: basic.json" is to be verified with the following metadata:
      | key     | value                                           |
      | Origin  | Some Text                                       |
      | TagData | JSON: { "ID": "100", "weight": 100.5 } |
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Metadata had differences" error

  Scenario: Message with plain text body (positive case)
    Given a provider is started that can generate the "basic" message with "Hello World"
    And a Pact file for "basic":"Hello World" is to be verified
    When the verification is run
    Then the verification will be successful

  Scenario: Message with plain text body (negative case)
    Given a provider is started that can generate the "basic" message with "Hello World"
    And a Pact file for "basic":"Hello Jupiter" is to be verified
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error

  Scenario: Message with JSON body (positive case)
    Given a provider is started that can generate the "basic" message with "file: basic.json"
    And a Pact file for "basic":"file: basic.json" is to be verified
    When the verification is run
    Then the verification will be successful

  Scenario: Message with JSON body (negative case)
    Given a provider is started that can generate the "json" message with "JSON: { \"one\": \"a\", \"two\": \"c\" }"
    And a Pact file for "json":"file: basic.json" is to be verified
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error

  Scenario: Message with XML body (positive case)
    Given a provider is started that can generate the "xml" message with "file: xml-body.xml"
    And a Pact file for "xml":"file: xml-body.xml" is to be verified
    When the verification is run
    Then the verification will be successful

  Scenario: Message with XML body (negative case)
    Given a provider is started that can generate the "xml" message with "file: xml-body.xml"
    And a Pact file for "xml":"file: xml2-body.xml" is to be verified
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error

  Scenario: Message with binary body (positive case)
    Given a provider is started that can generate the "image" message with "file: rat.jpg"
    And a Pact file for "image" is to be verified with the following:
      | body           | file: spider.jpg                                                |
      | matching rules | contenttype-matcher-v3.json                                     |
    When the verification is run
    Then the verification will be successful

  Scenario: Message with binary body (negative case)
    Given a provider is started that can generate the "image" message with "file: rat.jpg"
    And a Pact file for "image" is to be verified with the following:
      | body           | file: sample.pdf                                                |
      | matching rules | contenttype-matcher-v3.json                                     |
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body type had differences" error

  Scenario: Supports matching rules for the message metadata (positive case)
  Given a provider is started that can generate the "basic" message with "file: basic.json" and the following metadata:
    | key     | value                                           |
    | Origin  | AAA-123                                         |
    | TagData | JSON: { "ID": "123", "weight": 100.5 }          |
  And a Pact file for "basic" is to be verified with the following:
    | body           | file: basic.json                                                |
    | matching rules | regex-matcher-metadata.json                                     |
    | metadata       | Origin=AXP-1000; TagData=JSON: { "ID": "123", "weight": 100.5 } |
  When the verification is run
  Then the verification will be successful

  Scenario: Supports matching rules for the message metadata (negative case)
    Given a provider is started that can generate the "basic" message with "file: basic.json" and the following metadata:
      | key     | value                                  |
      | Origin  | AAAB-123                               |
      | TagData | JSON: { "ID": "123", "weight": 100.5 } |
    And a Pact file for "basic" is to be verified with the following:
      | body           | file: basic.json                                                |
      | matching rules | regex-matcher-metadata.json                                     |
      | metadata       | Origin=AXP-1000; TagData=JSON: { "ID": "123", "weight": 100.5 } |
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Metadata had differences" error

  Scenario: Supports matching rules for the message body (positive case)
    Given a provider is started that can generate the "basic" message with "file: basic2.json"
    And a Pact file for "basic" is to be verified with the following:
      | body           | file: basic.json        |
      | matching rules | include-matcher-v3.json |
    When the verification is run
    Then the verification will be successful

  Scenario: Supports matching rules for the message body (negative case)
    Given a provider is started that can generate the "basic" message with "file: basic3.json"
    And a Pact file for "basic" is to be verified with the following:
      | body           | file: basic.json        |
      | matching rules | include-matcher-v3.json |
    When the verification is run
    Then the verification will NOT be successful
    And the verification results will contain a "Body had differences" error

  Scenario: Supports messages with body formatted for the Kafka schema registry
    Given a provider is started that can generate the "kafka" message with "file: kafka-body.xml"
    And a Pact file for "kafka":"file: kafka-expected-body.xml" is to be verified
    When the verification is run
    Then the verification will be successful
