module Grapple
	module Components
		class RansackColumnHeadings < HtmlComponent

			setting :alignment_classes, { left: 'text-left', center: 'text-center', right: 'text-right' }
			setting :tooltip_class, 'table-tooltip'
			setting :row_class, 'column-headers'

			def render(*options, &block)
				options = options[0] || {}
				url_params = options[:url_params] || {}
				@method = options[:method] || :get
				cols = columns.collect do |column|
					indent + column_header(column, options[:ransack], url_params, &block)
				end
				builder.row cols.join("\n"), :class => row_class
			end

			def column_header(column, search, additional_parameters = {}, &block)
				cell_classes = []
				cell_classes << alignment_classes[(column[:align] || :left).to_sym]
				
				liner_classes = []
				liner_classes << tooltip_class if column[:title].present?

				# label = t(column[:label] || '')
				
				if column[:sort]
					cell_classes << 'sortable'
					if column[:sort].to_s == params[:sort]
						liner_classes << (params[:dir] == 'desc' ? 'sort-desc' : 'sort-asc')
						cell_classes << 'sorted'
					end
					# TODO: Use this for backwards compatability
					url = table_url(additional_parameters.merge({sort: column[:sort]}))
					# content = template.link_to(label, url)
					# Does a URL need to be set? If so, how?
					content = template.sort_link(search, column[:sort], {}, @method) do
						# ensure the label is not nil, run translations
						_label = t(column[:label] || '')
						# If the label is a symbol, convert it to a string
						_label = if column[:label].is_a? Symbol
							column[:label].to_s
						else
							column[:label]
						end
						
						# The block should contain code to wrap all labels in html
						# (e.g. span, div, etc.)
						_label = if block_given?
							block.call(_label)
						else
							_label
						end

						# Ransack supports putting HTML into the column heading.
						# We make the label html_safe to ensure it renders.
						_label.html_safe
					end
				else
					content = label
				end
				
				if column[:class]
					column[:class].split(" ").each{|c| cell_classes << c}
				end
				
				cell_classes = ' class="' + cell_classes.join(' ') + '"'
				title = column[:title] ? " title=\"#{h(column[:title])}\"" : ''
				liner_classes = liner_classes.length ? " class=\"#{liner_classes.join(" ")}\"" : ''

				"<th#{cell_classes}><div#{title}#{liner_classes}>#{h content}</div></th>".html_safe
			end
			
		end
	end
end
