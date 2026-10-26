# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2011, by Johannes Wagener.
# Copyright, 2011-2013, by Nick Sieger.
# Copyright, 2012, by Steven Davidovitz.
# Copyright, 2012, by hexfet.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2017, by Eric Hutzelman.
# Copyright, 2019, by Ethan Turkeltaub.
# Copyright, 2019, by Patrick Davey.

require 'multipart/post/parts'
require 'multipart/post/composite_read_io'
require 'stringio'
require 'tempfile'
require 'pathname'

module AssertPartLength
  def assert_part_length(part)
    bytes = part.to_io.read
    bytesize = bytes.respond_to?(:bytesize) ? bytes.bytesize : bytes.length
    expect(bytesize).to be == part.length
  end
end

module Multipart
  module Post
    RSpec.describe Parts do
      let(:string_with_content_type) do
        Class.new(String) do
          def content_type; 'application/data'; end
        end
      end

      it "test_file_with_upload_io" do
        expect(Parts::Part.file?(UploadIO.new(__FILE__, "text/plain"))).to be true
      end

      it "test_file_with_modified_string" do
        expect(Parts::Part.file?(string_with_content_type.new("Hello"))).to be false
      end

      it "test_new_with_modified_string" do
        expect(Parts::Part.new("boundary", "multibyte", string_with_content_type.new("Hello"))).to be_kind_of(Parts::ParamPart)
      end
    end

    RSpec.describe Parts::FilePart do
      include AssertPartLength

      before(:each) do
        File.open(TEMP_FILE, "w") {|f| f << "1234567890"}
        io =  UploadIO.new(TEMP_FILE, "text/plain")
        @part = Parts::FilePart.new("boundary", "afile", io)
      end

      after(:each) do
        File.delete(TEMP_FILE) rescue nil
      end

      it "test_correct_length" do
        assert_part_length @part
      end

      it "test_multibyte_file_length" do
        assert_part_length Parts::FilePart.new("boundary", "multibyte", UploadIO.new(MULTIBYTE, "text/plain"))
      end

      it "test_multibyte_filename" do
        name = File.read(MULTIBYTE, 300)
        file = Tempfile.new(name.respond_to?(:force_encoding) ? name.force_encoding("UTF-8") : name)
        assert_part_length Parts::FilePart.new("boundary", "multibyte", UploadIO.new(file, "text/plain"))
        file.close
      end

      it "test_force_content_type_header" do
        part = Parts::FilePart.new("boundary", "afile", UploadIO.new(TEMP_FILE, "text/plain"), { "Content-Type" => "application/pdf" })
        expect(part.to_io.read).to match(/Content-Type: application\/pdf/)
      end

      it "test_content_id" do
        part = Parts::FilePart.new("boundary", "afile", UploadIO.new(TEMP_FILE, "text/plain"), { "Content-ID" => "id" })
        expect(part.to_io.read).to match(/Content-ID: id/)
      end

      it "test_io_with_only_size" do
        io = Class.new do
          def initialize(string)
            @io = StringIO.new(string)
          end

          def read(*args)
            @io.read(*args)
          end

          def size
            @io.size
          end
        end.new("1234567890")

        assert_part_length Parts::FilePart.new("boundary", "afile", UploadIO.new(io, "text/plain", "afile.txt"))
      end

      it "test_file_deleted_after_open" do
        file = File.open(TEMP_FILE)
        File.delete(TEMP_FILE)
        assert_part_length Parts::FilePart.new("boundary", "afile", UploadIO.new(file, "text/plain"))
      ensure
        file&.close
      end

      it "test_io_with_nil_size_and_path" do
        io = Class.new do
          attr :path

          def initialize(path)
            @path = path
            @io = StringIO.new(File.read(path))
          end

          def read(*args)
            @io.read(*args)
          end

          def size
            nil
          end
        end.new(TEMP_FILE)

        assert_part_length Parts::FilePart.new("boundary", "afile", UploadIO.new(io, "text/plain"))
      end

      it "test_pathname" do
        io = UploadIO.new(Pathname.new(TEMP_FILE), "text/plain")
        part = Parts::FilePart.new("boundary", "afile", io)

        body = String.new
        while chunk = part.to_io.read(4)
          body << chunk
          break if body.bytesize > part.length
        end

        expect(io.original_filename).to be == TEMP_FILE
        expect(io.local_path).to be == TEMP_FILE
        expect(body.bytesize).to be == part.length
      end

      it "test_io_with_unknown_size" do
        io = Class.new do
          def read(*args)
            nil
          end

          def size
            nil
          end
        end.new

        expect do
          Parts::FilePart.new("boundary", "afile", UploadIO.new(io, "text/plain", "afile.txt"))
        end.to raise_error(ArgumentError, /afile/)
      end
    end

    RSpec.describe Parts::ParamPart do
      include AssertPartLength

      before(:each) do
        @part = Parts::ParamPart.new("boundary", "multibyte", File.read(MULTIBYTE))
      end

      it "test_correct_length" do
        assert_part_length @part
      end

      it "test_content_id" do
        part = Parts::ParamPart.new("boundary", "with_content_id", "foobar", "Content-ID" => "id")
        expect(part.to_io.read).to match(/Content-ID: id/)
      end
    end
  end
end
