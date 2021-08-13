# frozen_string_literal: true

#--
# Copyright (c) 2007-2012 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++

require 'net/http'
require 'stringio'
require 'cgi'
require 'multipart/post/parts'
require 'multipart/post/composite_read_io'
require 'multipart/post/multipartable'

module Net
  class HTTP
    class Put
      class Multipart < Put
        include ::Multipart::Post::Multipartable
      end
    end

    class Post
      class Multipart < Post
        include ::Multipart::Post::Multipartable
      end
    end
  end
end
