#!/usr/local/bin/ruby

# MovableType 3.x converter for typo by Patrick Lenz <patrick@lenz.sh>
# 
# MAKE BACKUPS OF EVERYTHING BEFORE RUNNING THIS SCRIPT!
# THIS SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND

require File.dirname(__FILE__) + '/../config/environment'
require 'optparse'

class MTMigrate
  attr_accessor :options
  
  def initialize
    self.options = {}
    self.parse_options
    self.convert_categories
    self.convert_entries
  end

  def convert_categories
    mt_categories = ActiveRecord::Base.connection.select_all(%{
      SELECT category_label AS name
      FROM `#{self.options[:mt_db]}`.mt_category
      WHERE category_blog_id = '#{self.options[:blog_id]}'
    })

    puts "Converting #{mt_categories.size} categories.."
    
    mt_categories.each do |cat|
      Category.create(cat) unless Category.find_by_name(cat['name'])
    end
  end
  
  def convert_entries
    mt_entries = ActiveRecord::Base.connection.select_all(%{
      SELECT
        entry_id,
        entry_allow_comments AS allow_comments,
        entry_allow_pings AS allow_pings,
        entry_title AS title,
        entry_text AS body,
        entry_text_more AS extended,
        entry_excerpt AS excerpt,
        entry_keywords AS keywords,
        entry_created_on AS created_at,
        entry_modified_on AS updated_at,
        author_name AS author        
      FROM `#{self.options[:mt_db]}`.mt_entry, `#{self.options[:mt_db]}`.mt_author
      WHERE entry_blog_id = '#{self.options[:blog_id]}'
      AND author_id = entry_author_id
    })
    
    puts "Converting #{mt_entries.size} entries.."
    
    mt_entries.each do |entry|
      a = Article.new
      a.attributes = entry.reject { |k,v| k == "entry_id" }
      a.save
      
      # Fetch category assignments
      ActiveRecord::Base.connection.select_all(%{
        SELECT category_label, placement_is_primary
        FROM `#{self.options[:mt_db]}`.mt_category, `#{self.options[:mt_db]}`.mt_entry, `#{self.options[:mt_db]}`.mt_placement
        WHERE entry_id = #{entry['entry_id']}
        AND category_id = placement_category_id
        AND entry_id = placement_entry_id
      }).each do |c|
        a.categories.push_with_attributes(Category.find_by_name(c['category_label']), :is_primary => c['placement_is_primary'])
      end
      
      # Fetch comments
      ActiveRecord::Base.connection.select_all(%{
        SELECT
          comment_author AS author,
          comment_email AS email,
          comment_url AS url,
          comment_text AS body,
          comment_created_on AS created_at,
          comment_modified_on AS updated_at          
        FROM `#{self.options[:mt_db]}`.mt_comment
        WHERE comment_entry_id = #{entry['entry_id']}
      }).each do |c|
        a.comments.create(c)
      end
      
      # Fetch trackbacks
      ActiveRecord::Base.connection.select_all(%{
        SELECT
          tbping_title AS title,
          tbping_excerpt AS excerpt,
          tbping_source_url AS url,
          tbping_ip AS ip,
          tbping_blog_name AS blog_name,
          tbping_created_on AS created_at,
          tbping_modified_on AS updated_at
        FROM `#{self.options[:mt_db]}`.mt_tbping, `#{self.options[:mt_db]}`.mt_trackback
        WHERE tbping_tb_id = trackback_id
        AND trackback_entry_id = #{entry['entry_id']}
      }).each do |tb|
        a.trackbacks.create(tb)
      end
    end
  end

  def parse_options
    OptionParser.new do |opt|
      opt.banner = "Usage: mt3.rb [options]"

      opt.on('--blog-id BLOGID', Integer, 'Blog ID to import from.') { |i| self.options[:blog_id] = i }
      opt.on('--db DBNAME', String, 'Movable Type database name.') { |d| self.options[:mt_db] = d }

      opt.on_tail('-h', '--help', 'Show this message.') do
        puts opt
        exit
      end

      opt.parse!(ARGV)
    end

    unless self.options.include?(:blog_id) and self.options.include?(:mt_db)
      puts "See mt3.rb --help for help."
      exit
    end
  end
end

MTMigrate.new