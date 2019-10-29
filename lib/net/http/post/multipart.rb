#--
# Copyright (c) 2007-2012 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++

require 'net/http'
require 'stringio'
require 'cgi'
require 'multipartable'
require 'multipart/post/parts'
require 'multipart/post/composite_read_io'

module Net
  class HTTP
    class Put
      class Multipart < Put
        include Multipartable
      end
    end

    class Post
      class Multipart < Post
        include Multipartable
      end
    end
  end
end
