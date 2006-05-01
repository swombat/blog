class Page < Content
  belongs_to :user
  validates_presence_of :name, :title, :body
  validates_uniqueness_of :name

  content_fields :body

  def self.default_order
    'name ASC'
  end

  protected

  def default_text_filter_config_key; 'text_filter'; end
end
