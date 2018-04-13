module Classifoclc
  class BadIdentifierError < StandardError; end

  class BadIdentifierFormatError < StandardError; end

  class InfiniteLoopError < StandardError; end

  class UnexpectedError < StandardError; end
end
