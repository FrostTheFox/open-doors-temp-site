class Author < ApplicationRecord
  audited comment_required: true
  has_associated_audits

  has_many :stories, (-> { order 'lower(title)' })
  has_many :story_links, (-> { order 'lower(title)' })
  default_scope { order 'lower(name)' }
  scope :with_stories, (-> { joins(:stories).where("stories.id IS NOT NULL") })
  scope :with_story_links, (-> { joins(:story_links).where("story_links.id IS NOT NULL") })
  scope :with_stories_or_story_links, (-> { (with_stories + with_story_links).uniq })

  validates_presence_of :name

  def coauthored_stories
    Story.where(coauthor_id: id)
  end
end
