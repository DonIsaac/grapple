module Grapple
	module Components
		class ColumnHeadings < HtmlComponent

			setting :alignment_classes, { left: 'text-left', center: 'text-center', right: 'text-right' }
			setting :tooltip_class, 'table-tooltip'
			setting :row_class, 'column-headers'

			def render(url_params = {})
				cols = columns.collect do |column|
					indent + column_header(column, url_params)
				end
				builder.row cols.join("\n"), :class => row_class
			end

			def column_header(column, additional_parameters = {})
				cell_classes = []
				cell_classes << alignment_classes[(column[:align] || :left).to_sym]
				
				liner_classes = []
				liner_classes << tooltip_class if column[:title].present?

				label = t(column[:label] || '')
				
				if column[:sort]
					cell_classes << 'sortable'
					if column[:sort].to_s == params[:sort]
						liner_classes << (params[:dir] == 'desc' ? 'sort-desc' : 'sort-asc')
						cell_classes << 'sorted'
					end
					url = table_url(additional_parameters.merge({sort: column[:sort]}))
					content = template.link_to(label, url)
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
