module Classifoclc

  URL = "http://classify.oclc.org/classify2/Classify?%s"
  
  module Id
    STDNBR  = :stdnbr
    OCLC    = :oclc
    ISBN    = :isbn
    LCCN    = :lccn
    ISSN    = :issn
    UPC     = :upc
    IDENT   = :ident
    HEADING = :heading
    OWI     = :owi
    AUTHOR  = :author
    TITLE   = :title
  end

  module OrderBy
    EDITIONS  = :mancount
    HOLDINGS  = :hold
    FIRSTYEAR = :lyr
    LASTYEAR  = :hyr
    LANGUAGE  = :ln
    HEADING   = :sheading
    WORKS     = :works
    SUBJTYPE  = :type
  end

  module Order
    ASC  = :asc
    DESC = :desc
  end
end
