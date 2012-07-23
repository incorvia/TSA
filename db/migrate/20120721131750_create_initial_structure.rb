class CreateInitialStructure < ActiveRecord::Migration
  def change
    create_table 'login_ticket', :force => true do |t|
      t.string    'ticket',          :null => false
      t.timestamp 'created_on',      :null => false
      t.datetime  'consumed',        :null => true
      t.string    'client_hostname', :null => false
    end

    create_table 'service_ticket', :force => true do |t|
      t.string    'ticket',            :null => false
      t.text      'service',           :null => false
      t.timestamp 'created_on',        :null => false
      t.datetime  'consumed',          :null => true
      t.string    'client_hostname',   :null => false
      t.string    'username',          :null => false
      t.string    'type',              :null => true
      t.integer   'granted_by_pgt_id', :null => true
      t.integer   'granted_by_tgt_id', :null => true
    end

    create_table 'ticket_granting_ticket', :force => true do |t|
      t.string    'ticket',           :null => false
      t.timestamp 'created_on',       :null => false
      t.string    'client_hostname',  :null => false
      t.string    'username',         :null => false
      t.text      'extra_attributes', :null => true
    end

    create_table 'proxy_granting_ticket', :force => true do |t|
      t.string    'ticket',            :null => false
      t.timestamp 'created_on',        :null => false
      t.string    'client_hostname',   :null => false
      t.string    'iou',               :null => false
      t.integer   'service_ticket_id', :null => false
    end
  end
end
