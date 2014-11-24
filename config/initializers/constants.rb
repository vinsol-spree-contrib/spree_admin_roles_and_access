PARAM_ATTRIBUTE = Hash.new(:id).merge({"products" => :slug, "orders" => :number, "shipments" => :number})
NEW_ACTIONS = [:new, :create]