module OpenApplicationPlatform::Rails::ModelExtensions
  FIELDS = [ 'about_me', 'activities', 'affiliations', 'birthday', 'books',
             'current_location', 'education_history', 'name', 'first_name',
             'last_name', 'hometown_location', 'hs_info', 'interests',
             'relationship_status', 'meeting_for', 'meeting_sex', 'movies',
             'music', 'notes_count', 'political', 'profile_update_time',
             'quotes', 'religion', 'sex', 'significant_other_id', 'status',
             'timezone', 'tv', 'wall_count', 'work_history', 'pic',
             'pic_big', 'pic_small', 'pic_square' ]
  
  module ActsAsPlatformUser
    module InstanceMethods
      def platform_session
        @platform_session ||= initialize_platform_session
      end
      
    private
      # api_key and api_secret may be overridden in model
      
      def api_key
        network_options[:api_key]
      end
      
      def api_secret
        network_options[:api_secret]
      end
      
      def network_options
        OPEN_APPLICATION_PLATFORM[network]
      end
      
      def network_class
        OpenApplicationPlatform::Network.from_string(network)
      end
      
      def initialize_platform_session
        session = OpenApplicationPlatform::Session.new(api_key, api_secret, network_class)
        session.activate(session_key, platform_uid)
        session
      end
      
      def get_user_info(fields)
        unless @user_info && fields.all? { |k| @user_info.keys.include?(k) }
          fields = (Array(fields) + (@user_info || {}).keys).uniq
          
          @user_info = platform_session.api.users_getInfo(:uids => [platform_uid],
                                                          :fields => fields).first
        end
      end
      
      def cache_valid?
        cache_updated_at && cache_updated_at > 24.hours.ago
      end
    end
    
    module ClassMethods
      def find_or_create_by_session(session, scope={})
        conditions = scope.merge({
          :platform_uid => session.user_id,
          :network => session.network.to_s
        })
        
        with_scope(:find => { :conditions => conditions }, :create => conditions) do
          user = find(:first)
          
          if user
            if user.session_key != session.session_key
              user.update_attribute(:session_key, session.session_key)
            end
          else
            user = create(:session_key => session.session_key)
          end
          
          user
        end
      end
      
      def field_cached?(field)
        @@cached_fields.include?(field)
      end
      
    private
      def cache_platform_fields(fields)
        raise "Table is missing field cache_updated_at" unless has_column?("cache_updated_at")
        
        fields.each do |field|
          raise "Field #{field} is not cacheable." unless cacheable?(field)
          raise "Table is missing field cached_#{field}" unless has_column?("cached_#{field}")
          
          class_eval <<-EOF
            alias_method :uncached_#{field}, :#{field}
            
            def #{field}
              unless cache_valid?
                self.cached_#{field} = uncached_#{field}
                self.cache_updated_at = Time.now
                save(false)
              end
              
              cached_#{field}
            end
          EOF
        end
        
        @@cached_fields = fields
      end
      
      def cacheable?(field)
        FIELDS.include?(field)
      end
      
      def has_column?(field)
        content_columns.map(&:name).include?(field)
      end
      
      def define_user_api_methods(fields)
        fields.each do |field|
          class_eval <<-EOF
            def #{field}
              unless self.class.field_cached?('#{field}')
                logger.warn("Accessing uncached field #{field}")
              end
            
              get_user_info('#{field}')
              @user_info['#{field}']
            end
          EOF
        end
      end
    end
  end
  
  
  # Hooks for module inclusion
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def acts_as_platform_user(options={})
      include ActsAsPlatformUser::InstanceMethods
      extend ActsAsPlatformUser::ClassMethods
      
      define_user_api_methods(FIELDS)
      cache_platform_fields(options[:cache_fields]) if options[:cache_fields]
    end
  end
end
