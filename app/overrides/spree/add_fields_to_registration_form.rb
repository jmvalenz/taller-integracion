Deface::Override.new(:virtual_path  => "spree/signup",
                     :insert_top => "div#signup_below_password_fields",
                     :name          => "add_fields_to_registration_form",
                     :text          => "<p>
<%= f.label :id, Spree.t(:id) %><br />
<%= f.id_field :id, :class => 'title' %>
</p>
<p>
<%= f.label :first_name, Spree.t(:firstname) %><br />
<%= f.first_name_field :first, :class => 'title' %>
</p>
<p>
<%= f.label :last_name, Spree.t(:lastname) %><br />
<%= f.last_name_field :last, :class => 'title' %>
</p>
<p>
<%= f.label :street, Spree.t(:address1) %><br />
<%= f.street_field :street, :class => 'title' %>
</p>
<p>
<%= f.label :city, Spree.t(:city) %><br />
<%= f.city_field :city, :class => 'title' %>
</p>
<p>
<%= f.label :state, Spree.t(:state) %><br />
<%= f.state_field :state, :class => 'title' %>
</p>")

