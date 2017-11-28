# frozen_string_literal: true

require 'spec_helper'

describe CSI::Plugins::Pony do
  it 'should display information for authors' do
    authors_response = CSI::Plugins::Pony
    expect(authors_response).to respond_to :authors
  end

  it 'should display information for existing help method' do
    help_response = CSI::Plugins::Pony
    expect(help_response).to respond_to :help
  end

  # before(:each) do
  #   allow(CSI::Plugins::Pony).to receive(:deliver)
  # end

  # it "sends mail" do
  #   expect(CSI::Plugins::Pony).to receive(:deliver) do |mail|
  #     expect(mail.to).to eq [ 'joe@example.com' ]
  #     expect(mail.from).to eq [ 'sender@example.com' ]
  #     expect(mail.subject).to eq 'hi'
  #     expect(mail.body).to eq 'Hello, Joe.'
  #   end
  #   CSI::Plugins::Pony.mail(to: 'joe@example.com', from: 'sender@example.com', subject: 'hi', body: 'Hello, Joe.')
  # end

  # it "requires :to param" do
  #   expect{ CSI::Plugins::Pony.mail({}) }.to raise_error(ArgumentError)
  # end

  # it "doesn't require any other param" do
  #   expect{ CSI::Plugins::Pony.mail(to: 'joe@example.com') }.to_not raise_error
  # end

  # it 'can list its available options' do
  #   expect( CSI::Plugins::Pony.permissable_options ).to include(:to, :body)
  # end

  # describe "builds a Mail object with field:" do
  #   it "to" do
  #     expect(CSI::Plugins::Pony.build_mail(to: 'joe@example.com').to).to eq [ 'joe@example.com' ]
  #  end

  #  it "to with multiple recipients" do
  #    expect(CSI::Plugins::Pony.build_mail(to: 'joe@example.com, friedrich@example.com').to).to eq [ 'joe@example.com', 'friedrich@example.com' ]
  #  end

  #  it "to with multiple recipients and names" do
  #    expect(CSI::Plugins::Pony.build_mail(to: 'joe@example.com, "Friedrich Hayek" <friedrich@example.com>').to).to eq [ 'joe@example.com', 'friedrich@example.com' ]
  #  end

  #  it "to with multiple recipients and names in an array" do
  #    expect(CSI::Plugins::Pony.build_mail(to: ['joe@example.com', '"Friedrich Hayek" <friedrich@example.com>']).to).to eq [ 'joe@example.com', 'friedrich@example.com' ]
  #  end

  #  it "cc" do
  #    expect(CSI::Plugins::Pony.build_mail(cc: 'joe@example.com').cc).to eq [ 'joe@example.com' ]
  #  end

  #  it "reply_to" do
  #    expect(CSI::Plugins::Pony.build_mail(reply_to: 'joe@example.com').reply_to).to eq [ 'joe@example.com' ]
  #  end

  #  it "cc with multiple recipients" do
  #    expect(CSI::Plugins::Pony.build_mail(cc: 'joe@example.com, friedrich@example.com').cc).to eq [ 'joe@example.com', 'friedrich@example.com' ]
  #  end

  #  it "from" do
  #    expect(CSI::Plugins::Pony.build_mail(from: 'joe@example.com').from).to eq [ 'joe@example.com' ]
  #  end

  #  it "bcc" do
  #    expect(CSI::Plugins::Pony.build_mail(bcc: 'joe@example.com').bcc).to eq [ 'joe@example.com' ]
  #  end

  #  it "bcc with multiple recipients" do
  #    expect(CSI::Plugins::Pony.build_mail(bcc: 'joe@example.com, friedrich@example.com').bcc).to eq [ 'joe@example.com', 'friedrich@example.com' ]
  #  end

  #  it "charset" do
  #    mail = CSI::Plugins::Pony.build_mail(charset: 'UTF-8')
  #    expect(mail.charset).to eq 'UTF-8'
  #  end

  #  it "text_part_charset" do
  #    mail = CSI::Plugins::Pony.build_mail(attachments: {"foo.txt" => "content of foo.txt"}, body: 'test', text_part_charset: 'ISO-2022-JP')
  #    expect(mail.text_part.charset).to eq 'ISO-2022-JP'
  #  end

  #  it "default charset" do
  #    expect(CSI::Plugins::Pony.build_mail(body: 'body').charset).to eq 'UTF-8'
  #    expect(CSI::Plugins::Pony.build_mail(html_body: 'body').charset).to eq 'UTF-8'
  #  end

  #  it "from (default)" do
  #    expect(CSI::Plugins::Pony.build_mail({}).from).to eq [ 'pony@unknown' ]
  #  end

  #  it "subject" do
  #    expect(CSI::Plugins::Pony.build_mail(subject: 'hello').subject).to eq 'hello'
  #  end

  #  it "body" do
  #    expect(CSI::Plugins::Pony.build_mail(body: 'What do you know, Joe?').body)
  #      .to eq 'What do you know, Joe?'
  #  end

  #  it "html_body" do
  #    expect(CSI::Plugins::Pony.build_mail(html_body: 'What do you know, Joe?').parts.first.body)
  #      .to eq 'What do you know, Joe?'
  #    expect(CSI::Plugins::Pony.build_mail(html_body: 'What do you know, Joe?').parts.first.content_type)
  #      .to eq 'text/html; charset=UTF-8'
  #  end

  #  it 'content_type' do
  #    expect(CSI::Plugins::Pony.build_mail(content_type: 'multipart/related').content_type)
  #      .to eq 'multipart/related'
  #  end

  #  it "date" do
  #    now = Time.now
  #    expect(CSI::Plugins::Pony.build_mail(date: now).date).to eq DateTime.parse(now.to_s)
  #  end

  #  it "message_id" do
  #    expect(CSI::Plugins::Pony.build_mail(message_id: '<abc@def.com>').message_id).to eq 'abc@def.com'
  #  end

  #  it "custom headers" do
  #    expect(CSI::Plugins::Pony.build_mail(headers: {"List-ID" => "<abc@def.com>"})['List-ID'].to_s).to eq '<abc@def.com>'
  #  end

  #  it "sender" do
  #    expect(CSI::Plugins::Pony.build_mail(sender: "abc@def.com")['Sender'].to_s).to eq 'abc@def.com'
  #  end

  #  it "utf-8 encoded subject line" do
  #    mail = CSI::Plugins::Pony.build_mail(to: 'btp@foo', subject: 'Cafe', body: 'body body body')
  #    expect(mail['subject'].encoded).to match( /^Subject: =\?UTF-8/ )
  #  end

  #   it "attachments" do
  #     mail = CSI::Plugins::Pony.build_mail(attachments: {"foo.txt" => "content of foo.txt"}, body: 'test')
  #     expect(mail.parts.length).to eq 2
  #     expect(mail.parts.first.to_s).to match( /Content-Type: text\/plain/ )
  #     expect(mail.attachments.first.content_id).to eq "<foo.txt@#{Socket.gethostname}>"
  #   end

  #   it "suggests mime-type" do
  #     mail = CSI::Plugins::Pony.build_mail(attachments: {"foo.pdf" => "content of foo.pdf"})
  #     expect(mail.parts.length).to eq 1
  #     expect(mail.parts.first.to_s).to match( /Content-Type: application\/pdf/ )
  #     expect(mail.parts.first.to_s).to match( /filename=foo.pdf/ )
  #     expect(mail.parts.first.content_transfer_encoding.to_s).to eq 'base64'
  #   end

  #   it "encodes xlsx files as base64" do
  #     mail = CSI::Plugins::Pony.build_mail(attachments: {"foo.xlsx" => "content of foo.xlsx"})
  #     expect(mail.parts.length).to eq 1
  #     expect(mail.parts.first.to_s).to match( /Content-Type: application\/vnd.openxmlformats-officedocument.spreadsheetml.sheet/ )
  #     expect(mail.parts.first.to_s).to match( /filename=foo.xlsx/ )
  #     expect(mail.parts.first.content_transfer_encoding.to_s).to eq 'base64'
  #   end

  #   it "passes cc and bcc as the list of recipients" do
  #     mail = CSI::Plugins::Pony.build_mail(to: ['to'], cc: ['cc'], from: ['from'], bcc: ['bcc'])
  #     expect(mail.destinations).to eq  ['to', 'cc', 'bcc']
  #   end
  # end

  # describe "transport" do
  #   it "transports via smtp if no sendmail binary" do
  #     allow(CSI::Plugins::Pony).to receive(:sendmail_binary).and_return('/does/not/exist')
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(via: :smtp))
  #     CSI::Plugins::Pony.mail(to: 'foo@bar')
  #   end

  #   it "defaults to sendmail if no via is specified and sendmail exists" do
  #     allow(File).to receive(:executable?).and_return(true)
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(via: :sendmail))
  #     CSI::Plugins::Pony.mail(to: 'foo@bar')
  #   end

  #   describe "SMTP transport" do

  #     it "defaults to localhost as the SMTP server" do
  #       mail = CSI::Plugins::Pony.build_mail(to: "foo@bar", enable_starttls_auto: true, via: :smtp)
  #       expect(mail.delivery_method.settings[:address]).to eq 'localhost'
  #     end

  #     it "enable starttls when tls option is true" do
  #       mail = CSI::Plugins::Pony.build_mail(to: "foo@bar", enable_starttls_auto: true, via: :smtp)
  #       expect(mail.delivery_method.settings[:enable_starttls_auto]).to eq true
  #     end
  #   end
  # end

  # describe ":via option should over-ride the default transport mechanism" do
  #   it "should send via sendmail if via: sendmail" do
  #     mail = CSI::Plugins::Pony.build_mail(to: 'joe@example.com', via: :sendmail)
  #     expect(mail.delivery_method.kind_of?(Mail::Sendmail)).to eq true
  #   end

  #   it "should send via smtp if via: smtp" do
  #     mail = CSI::Plugins::Pony.build_mail(to: 'joe@example.com', via: :smtp)
  #     expect(mail.delivery_method.kind_of?(Mail::SMTP)).to eq true
  #   end

  # end

  # describe "sendmail binary location" do
  #   it "should default to /usr/sbin/sendmail if not in path" do
  #     allow(CSI::Plugins::Pony).to receive(:'`').and_return('')
  #     expect(CSI::Plugins::Pony.sendmail_binary).to eq '/usr/sbin/sendmail'
  #   end
  # end

  # describe "default options" do
  #   it "should use default options" do
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(from: 'noreply@pony'))
  #     CSI::Plugins::Pony.options = { from: 'noreply@pony' }
  #     CSI::Plugins::Pony.mail(to: 'foo@bar')
  #   end

  #   it "should merge default options with options" do
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(from: 'override@pony'))
  #     CSI::Plugins::Pony.options = { from: 'noreply@pony' }
  #     CSI::Plugins::Pony.mail(from: 'override@pony', to: "foo@bar")
  #   end

  #   it "should return the default options" do
  #     input = { from: 'noreply@pony' }
  #     CSI::Plugins::Pony.options = input
  #     output = CSI::Plugins::Pony.options
  #     expect(output).to eq input
  #   end
  # end

  # describe "override options" do
  #   it "should use the overide options" do
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(from: 'reply@pony'))

  #     CSI::Plugins::Pony.override_options = {:from: 'reply@pony' }
  #     CSI::Plugins::Pony.mail(to: 'foo@bar')
  #   end

  #   it "should use an override option instead of a default options" do
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(from: 'reply@pony.com'))

  #     CSI::Plugins::Pony.options = { from: 'other_address@pony.com' }
  #     CSI::Plugins::Pony.override_options = { from: 'reply@pony.com' }
  #     CSI::Plugins::Pony.mail(to: 'foo@bar')
  #   end

  #   it "should use an override instead of a passed in value" do
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(from: 'reply@pony.com'))

  #     CSI::Plugins::Pony.override_options = { from: 'reply@pony.com' }
  #     CSI::Plugins::Pony.mail(to: 'foo@bar', from: 'other_address@pony.com')
  #   end

  #   it "should return the override options" do
  #     input = { from: 'reply@pony' }
  #     CSI::Plugins::Pony.override_options = input
  #     output = CSI::Plugins::Pony.override_options

  #     expect(output).to eq input
  #   end
  # end

  # describe "subject prefix" do
  #   after(:all) do
  #     CSI::Plugins::Pony.subject_prefix(false)
  #   end

  #   it "should prefix email subject line with the given text" do
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(subject: 'First: Second'))

  #     CSI::Plugins::Pony.subject_prefix('First: ')
  #     CSI::Plugins::Pony.mail(to: 'foo@bar', subject: 'Second')
  #   end

  #   it "should set the prefix as the subject if no subject is given" do
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(subject: 'First: '))

  #     CSI::Plugins::Pony.subject_prefix('First: ')
  #     CSI::Plugins::Pony.mail(to: 'foo@bar')
  #   end
  # end

  # describe "append_inputs" do
  #   it "appends the options passed into Pany.mail to the body" do
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(body: "body/n {:to=>\"foo@bar\", :body=>\"body\"}"))

  #     CSI::Plugins::Pony.append_inputs

  #     CSI::Plugins::Pony.mail(to: 'foo@bar', body: 'body')
  #   end

  #   it "sets the options passed into Pany.mail as the body if one is not present" do
  #     expect(CSI::Plugins::Pony).to receive(:build_mail).with(hash_including(body: "/n {to: \"foo@bar\"}"))

  #     CSI::Plugins::Pony.append_inputs

  #     CSI::Plugins::Pony.mail(to: 'foo@bar')
  #   end

  # end

  # describe "content type" do
  #   context "mail with attachments, html_body and body " do
  #     subject(:mail) do
  #       CSI::Plugins::Pony.build_mail(
  #         body: 'test',
  #         html_body: 'What do you know, Joe?',
  #         attachments: {"foo.txt" => "content of foo.txt"},
  #       )
  #     end

  #     it { expect(mail.parts.length).to eq 2 }
  #     it { expect(mail.parts[0].parts.length).to eq 2 }
  #     it { expect(mail.content_type.to_s).to include( 'multipart/mixed' ) }
  #     it { expect(mail.parts[0].content_type.to_s).to include( 'multipart/alternative' ) }
  #     it { expect(mail.parts[0].parts[0].to_s).to include( 'Content-Type: text/html' ) }
  #     it { expect(mail.parts[0].parts[1].to_s).to include( 'Content-Type: text/plain' ) }
  #     it { expect(mail.parts[1].to_s).to include( 'Content-Type: text/plain' ) }
  #   end
  # end

  # describe "additional headers" do
  #   subject(:mail) do
  #     CSI::Plugins::Pony.build_mail(
  #       body: 'test',
  #       html_body: 'What do you know, Joe?',
  #       attachments: {"foo.txt" => "content of foo.txt"},
  #       body_part_header: { content_disposition: "inline"},
  #       html_body_part_header: { content_disposition: "inline"}
  #     )
  #   end

  #   it { expect(mail.parts[0].parts[0].to_s).to include( 'inline' ) }
  #   it { expect(mail.parts[0].parts[1].to_s).to include( 'inline' ) }

  #   context "when parts aren't present" do
  #     subject(:mail) do
  #       CSI::Plugins::Pony.build_mail(
  #         body: 'test',
  #         body_part_header: { content_disposition: "inline"},
  #         html_body_part_header: { content_disposition: "inline"}
  #       )
  #     end

  #     it { expect(mail.parts).to be_empty }
  #     it { expect(mail.to_s).to_not include( 'inline' ) }
  #   end
  # end
end
