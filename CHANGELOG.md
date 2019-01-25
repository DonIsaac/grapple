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

### Available Options

Ransack searches are highly customizable. As a result, there are a few options.

|    Name     |       Type        | Required? |                                                                                        Description                                                                                        |
|-------------|-------------------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| :ransack    | Ransack::Search   | Yes       | The Ransack search object to use in the form.                                                                                                                                              |
| :search     | Symbol            | Yes       | The symbol describing the search as described [here](https://github.com/activerecord-hackery/ransack#ransacks-search_form_for-helper-replaces-form_for-for-creating-the-view-search-form). |
| :form_class | String[] or String | No        | Optional CSS classes to add to the form tag.                                                                                                                                               |
| :list_class | String[] or String | No        | Optional CSS classes to add to the search bar's `<ul>` list tag. Used in default search only.                                                                                               |
| :li_class   | String[] or String | No        | Optional CSS classes to add to the search bar's `<li>` tags. Used in default search only.                                                                                                   |

### Writing Custom Search Forms

`RansackSearchForm` comes with a default search form out of the box. If you want
to create your own custom search form, pass it as a block. The component will pass
a `FormBuilder` object to the block you pass. If you use your own block, you do not
need to pass in a `:search` option.

```HTML+ERB
<%= t.ransack_form ransack: @q do |f| %>
    <%= f.label :zip_cont %>
    <%= f.search_field :zip_cont %>
<% end %>
```