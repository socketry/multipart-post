# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2006-2013, by Nick Sieger.
# Copyright, 2010, by Tohru Hashimoto.
# Copyright, 2011, by Alex Koppel.
# Copyright, 2011, by Luke Redpath.
# Copyright, 2013, by Mislav Marohnić.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2019, by Patrick Davey.
# Copyright, 2021, by Lewis Cowles.

require 'multipart/post/composite_read_io'
require 'stringio'
require 'timeout'

MULTIBYTE = File.dirname(__FILE__) + '/../../fixtures/multibyte.txt'

RSpec.shared_context "composite io" do
  it "can close all the ios" do
    subject.close
    expect(subject.closed?).to be_truthy
    
    expect do
      subject.read
    end.to raise_error(IOError)
  end
  
  it "test_full_read_from_several_ios" do
    expect(subject.read).to be == 'the quick brown fox'
  end
  
  it "test_partial_read" do
    expect(subject.read(9)).to be == 'the quick'
  end

  it "test_partial_read_to_boundary" do
    expect(subject.read(10)).to be == 'the quick '
  end

  it "test_read_with_size_larger_than_available" do
    expect(subject.read(32)).to be == 'the quick brown fox'
  end
  
  it "test_read_into_buffer" do
    buf = String.new
    subject.read(nil, buf)
    expect(buf).to be == 'the quick brown fox'
  end

  it "test_multiple_reads" do
    expect(subject.read(4)).to be == 'the '
    expect(subject.read(4)).to be == 'quic'
    expect(subject.read(4)).to be == 'k br'
    expect(subject.read(4)).to be == 'own '
    expect(subject.read(4)).to be == 'fox'
  end

  it "test_read_after_end" do
    subject.read
    expect(subject.read).to be == ""
  end

  it "test_read_after_end_with_amount" do
    subject.read(32)
    expect(subject.read(32)).to be_nil
  end
  
  it "test_second_full_read_after_rewinding" do
    subject.read
    subject.rewind
    expect(subject.read).to be == 'the quick brown fox'
  end
  
  # Was apparently broken on JRuby due to http://jira.codehaus.org/browse/JRUBY-7109
  it "test_compatible_with_copy_stream" do
    target_io = StringIO.new
    Timeout.timeout(1) do # Not sure why we need this in the spec?
      IO.copy_stream(subject, target_io)
    end
    expect(target_io.string).to be == "the quick brown fox"
  end
end

module Multipart
  module Post
    RSpec.describe CompositeReadIO do
      describe "generic io" do
        subject {StringIO.new('the quick brown fox')}

        include_context "composite io"
      end

      describe "composite io" do
        subject {CompositeReadIO.new(StringIO.new('the '), StringIO.new('quick '), StringIO.new('brown '), StringIO.new('fox'))}

        include_context "composite io"
      end

      describe "nested composite io" do
        subject {CompositeReadIO.new(CompositeReadIO.new(StringIO.new('the '), StringIO.new('quick ')), StringIO.new('brown '), StringIO.new('fox'))}

        include_context "composite io"
      end

      describe "unicode composite io" do
        let(:utf8_io) { File.open(MULTIBYTE) }
        let(:binary_io) {StringIO.new("\x86")}

        subject {CompositeReadIO.new(binary_io, utf8_io)}

        it "test_read_from_multibyte" do
          expect(subject.read).to be == "\x86\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB\n".b
        end
      end

      it "test_convert_error" do
        expect do
          UploadIO.convert!('tmp.txt', 'text/plain', 'tmp.txt', 'tmp.txt')
        end.to raise_error(ArgumentError, /convert! has been removed/)
      end

      it "test_empty" do
        expect(subject.read).to be == ""
      end

      it "test_empty_limited" do
        expect(subject.read(1)).to be_nil
      end

      it "test_empty_parts" do
        io = CompositeReadIO.new(StringIO.new, StringIO.new('the '), StringIO.new, StringIO.new('quick'))
        expect(io.read(3)).to be == "the"
        expect(io.read(3)).to be == " qu"
        expect(io.read(3)).to be == "ick"
      end

      it "test_all_empty_parts" do
        io = CompositeReadIO.new(StringIO.new, StringIO.new)
        expect(io.read(1)).to be_nil
      end
    end
  end
end
