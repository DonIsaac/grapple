# Ransack Search Components

This document outlines the changes I made to grapple while implementing the Ransack search Gem.
It also describes how to use the new components.

----

## Changes

* Added `RansackSearchForm` component
* Added `RansackQueryField` component
* Added styling in `assets/stylesheets/grapple.css` for the new components as needed
* `components.rb` autoloads all new components

----

## How To Use

Before you can use the `RansackSearchForm` component, you need to register it
as a helper in your table builder. It is intentionally left out of
`Grapple::AjaxDataGridBuilder` to mitigate the risk of bugs in production code.

```ruby
# lib/my_table_builder.rb
class MyTableBuilder < Grapple::DataGridBuilder
    helper :ransack_form, Grapple::Components::RansackSearchForm
    # ...
end
```

In order to use Ransack, you need to add it to your `Gemfile` and make a
`Ransack::Search` object available as an instance property. See [Ransack's Documentation](https://github.com/ActiveRecord-Hackery/Ransack) for further explanations.

```ruby
# Gemfile
gem 'ransack'
# ...
```
```ruby
# config/initializers/ransack.rb
require 'ransack' # Grant application-wide access to Ransack
# ...
```

```ruby
# app/controllers/foo_controller.rb
class FooController < ApplicationController
    def index
        # Make a Ransack::Search object from the query string
        @q = ZipCode.ransack(params[:q])
        # Use it to query the database
        @zip_codes = @q.result.includes(:state).page(params[:page])
    end
    # ...
end
```

```HTML+ERB
<!-- app/views/foo/index.html.erb -->
<%= table_for(columns, @zip_codes, html: { class: 'my-custom-class-name' }, builder: MyTableBuilder) do |t| %>
    <%= t.colgroup %>
    <%= t.header do %>
        <%= t.infobar %>
        <%= t.toolbar do %>
            <%= t.ransack_form ransack: @q, search: :name_cont %>
        <% end %>
        <%= t.column_headings %>
    <% end %>
    <%= t.footer %>
    <%= t.body do |item| %>
        <td class="actions"></td>
        <td><%= link_to item.zip, item %></td>
        <td><%= item.city %></td>
        <td><%= item.county %></td>
        <td><%= item.state.name %></td>
    <% end %>
<% end %>
```

## Available Form Options

The Ransack Search Form component is highly customizable. As a result, there are a few options.

|    Name     |       Type        | Required? |                                                                                        Description                                                                                        |
|-------------|-------------------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| :ransack    | Ransack::Search   | Yes       | The Ransack search object to use in the form.                                                                                                                                              |
| :search     | Symbol            | Yes       | The symbol describing the search as described [here](https://github.com/activerecord-hackery/ransack#ransacks-search_form_for-helper-replaces-form_for-for-creating-the-view-search-form). |
| :form_class | String[] or String | No        | Optional CSS classes to add to the form tag.                                                                                                                                               |
| :list_class | String[] or String | No        | Optional CSS classes to add to the search bar's `<ul>` list tag. Used in default search only.                                                                                               |
| :li_class   | String[] or String | No        | Optional CSS classes to add to the search bar's `<li>` tags. Used in default search only.                                                                                                   |

## Writing Custom Search Forms

`RansackSearchForm` comes with a default search form out of the box. If you want
to create your own custom search form, pass it as a block. The component will pass
a `FormBuilder` object to the block you pass. If you use your own block, you do not
need to pass in a `:search` option.

```HTML+ERB
<!-- Somewhere in your table_for... -->
<%= t.ransack_form ransack: @q do |f| %>
    <%= f.label :zip_cont %>
    <%= f.search_field :zip_cont %>
<% end %>
<!-- ... -->
```

## Column Headings

Currently, Ransack Search Forms require their own column heading component called `RansackColumnHeadings`.
You can implement it by doing the following:

```ruby
# lib/my_table_builder.rb
class MyTableBuilder < Grapple::DataGridBuilder
    helper :ransack_form, Grapple::Components::RansackSearchForm
    helper :ransack_colhead, Grapple::Components::RansackColumnHeadings
    # ...
end
```

Then simply replace the `column_headings` helper with `ransack_colhead` in your `table_for`

```HTML+ERB
<!-- app/views/foo/index.html.erb -->
<%= table_for(columns, @zip_codes, html: { class: 'my-custom-class-name' }, builder: MyTableBuilder) do |t| %>
    <%= t.colgroup %>
    <%= t.header do %>
        <%= t.infobar %>
        <%= t.toolbar do %>
            <%= t.ransack_form ransack: @q, search: :name_cont %>
        <% end %>
        <%= t.ransack_colhead ransack: @q %>
    <% end %>
    <%= t.footer %>
    <%= t.body do |item| %>
        <td class="actions"></td>
        <td><%= link_to item.zip, item %></td>
        <td><%= item.city %></td>
        <td><%= item.county %></td>
        <td><%= item.state.name %></td>
    <% end %>
<% end %>
```

## RansackColumnHeadings vs. ColumnHeadings

There are a few important, albeit small, differences between `RansackColumnHeadings`
and the original `ColumnHeadings`. `table_for` code copied from older code *should*
work with `RansackColumnHeadings` without many tweaks. However, there *are* a few 
caveats. For convenience,  `RansackColumnHeadings` and `ColumnHeadings` are shortened 
to `RCH` and `CH` respectively.

`RCH` works with the same `column` array traditionally provided to `table_for` however,
where the `sort` property originally was a snippet of SQL code, `sort` now must be the 
name of the field being sorted. Ransack handles the rest for us.

`RCH` column labels can be HTML, strings, or symbols! You can put a string containing HTML
directly into the `label` property of the `columns` array. Translation is still supported.

```HTML+ERB
<%
columns = [
        { label: "<span class="col-head">Zip Code</span>", sort: :zip, width: 120 }
        # ...
    ]
%>
```

Alternatively, you can wrap all of your labels in the same HTML. You specify that HTML
by passing a block to `t.ransack_colhead`. The block takes a single parameter, which is
the value of the `label` property in `columns`. **Make sure your block will return a string
containing the HTML code or your labels will disappear!**

```HTML+ERB
<!-- app/views/foo/index.html.erb -->
columns = [
        { },
        { label: :zip, sort: 'zip', width: 120 },
        { label: :city, sort: 'city', width: 200 },
        { label: :county, sort: 'county', width: 200 },	
        { label: :state, sort: 'states_name', width: 150 }
    ]
%>

<!-- ... -->
<!-- Inside your table_for() -->
<%= t.ransack_colhead ransack: @q do |label| %>
    <span class="column-title><%= label %></span>
<% end %>
```