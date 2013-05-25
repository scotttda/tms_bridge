class MockModel
  attr_accessor :attributes, :called_save, :called_destroy
  NOT_FOUND=false
  FOUND=true
  def save(*args)
    self.called_save = true
  end
  
  def destroy
    self.called_destroy = true
  end
  def self.find_by_tms_id(tms_id)
    return tms_id == FOUND ? FoundMockPublishing.new : nil
  end    
end

class MockPublishing<MockModel
end

class FoundMockPublishing<MockModel
end

class MockController
  cattr_accessor :before_filters
  attr_accessor :json
  attr_reader :request
  
  def self.before_filter(filter)
    @@before_filters ||= []
    @@before_filters << filter
  end

  def initialize
    @request = MockRequest.new
  end

  def head(*args);end
  def render(*args);end
  
end

class MockRequest
  attr_accessor :raw_post
end