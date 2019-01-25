module Grapple
	module Components
		class RansackSearchForm < HtmlComponent

			setting :components, [:ransack_query]
			setting :form_class, 'search-form'

			##
			# Available options:
			# :query_obj => Ransack::Search - The search object used by Ransack. Defaults to @q.
			# form_class => String[] | String - CSS classes for the form tag
			def render(*options, &block)
				options = options[0] ? options[0] : {}
				# raise ArgumentError, "Missing Ransack::Search object. Specify it under the \":ransack\" option." if options[:ransack].nil?
				raise ArgumentError, "Missing search symbol. Specify it under the :search option." if !block_given? && options[:search].nil?
				# If custom form classes are passed, add them to our array of classes
				options[:form_class] = options[:form_class] ? [ form_class, options[:form_class] ].flatten.join(' ') : form_class
				options[:list_class] = options[:list_class] ? [ options[:list_class] ].flatten.join(' ') : nil
				options[:li_class] = options[:li_class] ? [ options[:li_class] ].flatten.join(' ') : nil
				# if options[:search].is_a?
				

				html = ''
				html << template.search_form_for(options[:ransack], class: options[:form_class]) do |form|
					# html << template.
					if block_given?
						yield(form)
					else # Render the default search form if no custom form is passed via the block
						template.content_tag :ul, class: options[:list_class] do
							@list = template.content_tag(:li, class: options[:li_class]) do
								form.search_field options[:search], placeholder: "Search"
							end

							@list << template.content_tag(:li, class: options[:li_class]) do
								form.submit
							end
						end
							# html << if options[:list_class] then "<ul class=\"#{options[:list_class]}\">" else '<ul>' end
							# html << wrap_items(options[:li_class]) do
							# 	form.search_field options[:search]
							# end
							# html << "</ul>"
					end
				end
				html.html_safe
			end

			protected

			def wrap_items(classes)
				_li = ''
				_li << if classes.nil? then "<li>" else "<li class=\"#{classes}\">" end
				_li << yield + "</li>"
				_li.html_safe
			end

		end
	end
end