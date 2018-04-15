module Classifoclc

  URL = "http://classify.oclc.org/classify2/Classify?%s"

  # See http://classify.oclc.org/classify2/api_docs/classify.html
  
  # API also allows stdnbr, ident, heading, author, and title but without
  # pagination, the number of results may be too unwieldy
  module Id
    OCLC    = :oclc
    ISBN    = :isbn
    LCCN    = :lccn
    ISSN    = :issn
    UPC     = :upc
    OWI     = :owi
  end

  module OrderBy
    # number of editions
    EDITIONS  = :mancount
    # holdings
    HOLDINGS  = :hold
    # date of first edition
    FIRSTYEAR = :lyr
    # date of latest edition
    LASTYEAR  = :hyr
    # language
    LANGUAGE  = :ln
    # FAST subject heading
    HEADING   = :sheading
    # number of works with this FAST subject heading
    WORKS     = :works
    # FAST subject type
    SUBJTYPE  = :type
  end

  module Order
    ASC  = :asc
    DESC = :desc
  end
end
