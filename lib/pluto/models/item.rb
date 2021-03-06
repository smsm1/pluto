module Pluto
  module Models

class Item < ActiveRecord::Base
  self.table_name = 'items'

  include Pluto::ActiveRecordMethods  # e.g. read_attribute_w_fallbacks

  belongs_to :feed

  ##################################
  # attribute reader aliases
  def name()        title;    end  # alias for title
  def description() summary;  end  # alias for summary  -- also add descr shortcut??
  def link()        url;      end  # alias for url

  def self.latest
    # note: order by first non-null datetime field
    #   coalesce - supported by sqlite (yes), postgres (yes)

    # note: if not published,touched or built_at use hardcoded 1971-01-01 for now
    order( "coalesce(items.published,items.touched,'1971-01-01') desc" )
  end

  def published?()  read_attribute(:published).present?;  end

  def published
    ## todo/fix: use a new name - do NOT squeeze convenience lookup into existing
    #    db backed attribute

    read_attribute_w_fallbacks(
      :published,
      :touched       # try touched (aka updated RSS/ATOM)
    )
  end



  def debug=(value)  @debug = value;   end
  def debug?()       @debug || false;  end

  def update_from_struct!( feed_rec, data )
    ## check: new item/record?  not saved?  add guid
    #   otherwise do not add guid  - why? why not?

    item_attribs = {
      guid:         data.guid,   # todo: only add for new records???
      title:        data.title,
      url:          data.url,
      summary:      data.summary,
      content:      data.content,
      published:    data.published,
      touched:      data.updated,
      feed_id:      feed_rec.id,    # add feed_id fk_ref
      fetched:      feed_rec.fetched
    }

    if debug?
      puts "*** dump item_attribs w/ class types:"
      item_attribs.each do |key,value|
        next if [:summary,:content].include?( key )   # skip summary n content
        puts "  #{key}: >#{value}< : #{value.class.name}"
      end
    end

    update_attributes!( item_attribs )
  end

end  # class Item


  end # module Models
end # module Pluto
