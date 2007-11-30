module AttributeFu
  module AssociatedFormHelper
    def fields_for_associated(associated, *args, &block)
      associated_name = associated.class.name.underscore
      name            = associated_base_name associated_name
      conf            = args.last if args.last.is_a? Hash
      
      unless associated.new_record?
        name << "[#{associated.new_record? ? 'new' : associated.id}]"
      else
        @new_objects ||= {}
        @new_objects[associated_name] ||= -1 # we want naming to start at 0
        identifier = !conf.nil? && conf[:javascript] ? '#{number}' : @new_objects[associated_name]+=1
        
        name << "[new][#{identifier}]"
      end
      
      @template.fields_for(name, *args.unshift(associated), &block)
    end
    
    def remove_link(name, *args)
      options = args.extract_options!

      css_selector = options.delete(:selector) || ".#{@object.class.name.underscore}"
      function     = options.delete(:function) || ""
      
      function << "$(this).up(&quot;#{css_selector}&quot;).remove()"
      
      @template.link_to_function(name, function, *args.push(options))
    end
    
    def add_associated_link(name, object, opts = {})
      associated_name  = object.class.name.underscore
      variable         = "attribute_fu_#{associated_name}_count"
      
      opts.symbolize_keys!
      partial          = opts[:partial]   || associated_name
      container        = opts[:container] || associated_name.pluralize
      
      form_builder     = self # because the value of self changes in the block
      
      @template.link_to_function name do |page|
        page << "if (typeof #{variable} == 'undefined') #{variable} = 0;"
        page << "new Insertion.Bottom('#{container}', new Template("+form_builder.render_associated_form(object, :fields_for => { :javascript => true }).to_json+").evaluate({'number': --#{variable}}))"
      end
    end
    
    def render_associated_form(associated, opts = {})
      associated = associated.is_a?(Array) ? associated : [associated] # preserve association proxy if this is one
      
      opts.symbolize_keys!
      (opts[:new] - associated.select(&:new_record?).length).times { associated.build } if opts[:new]

      unless associated.empty?
        partial           = opts[:partial] || associated.first.class.name.underscore
        local_assign_name = opts[:partial] ? partial.split('/').last.split('.').first : associated.first.class.name.underscore

        associated.map do |element|
          fields_for_associated(element, opts[:fields_for]) do |f|
            @template.render({:partial => "#{partial}", :locals => {local_assign_name.to_sym => element, :f => f}.merge(opts[:locals] || {})}.merge(opts[:render] || {}))
          end
        end
      end
    end
    
    private
      def associated_base_name(associated_name)
        "#{@object_name}[#{associated_name}_attributes]"
      end
  end
end