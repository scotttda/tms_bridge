require 'iron_cacher'
module PublishesTms
  module Base
    def publishes_tms(as)
      extend PublishesTms::ClassMethods unless (class << self; included_modules; end).include?(PublishesTms::ClassMethods)
      include PublishesTms::InstanceMethods unless included_modules.include?(PublishesTms::InstanceMethods)
      
      self.as = as.to_s
      self.published_resource = self.name.split('::').last.gsub(/Controller/, '').underscore
      self.queue_name = self.as + '_'+self.published_resource

      before_filter :parse_iron_mq_json if respond_to?(:before_filter)
 
    end
  end
  
  module InstanceMethods
    include IronCacher
    
    protected
    def parse_iron_mq_json
      @json=JSON.parse(request.raw_post) unless request.raw_post.blank?
      unless @json && @json['tms_id']
        head :ok
        return false
      end
    end

    def valid_bridge_request?
      if @json && @json['cache_key']
        value = Digest::SHA2.hexdigest("---#{ENV['CC_BRIDGE_SALT']}--#{@json['tms_id']}--#{self.class.queue_name}--#{IronCacher::CACHE_NAME}--")
        return value == retrieve_from_cache(@json['cache_key'], IronCacher::CACHE_NAME)
      end
    end  
  end
  
  module ClassMethods
    def self.extended(base)
      base.class_attribute(:as)
      base.class_attribute(:published_resource)
      base.class_attribute(:queue_name)
    end
  end
end

ActionController::Base.send(:extend, PublishesTms::Base)
