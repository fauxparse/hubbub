class Agency < Company
  has_many :reports
  has_many :wiki_pages, :foreign_key => "company_id"
end
